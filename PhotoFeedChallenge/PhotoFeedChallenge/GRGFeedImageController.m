//
//  GRGFeedImageController.m
//  PhotoFeedChallenge
//
//  Created by Greg on 10/11/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//
#import "GRGFeedImageController.h"
#import "GRGFeedImageCacheController.h"
#import "GRGCoreDataController.h"

@interface GRGFeedImageController()
@property (nonatomic,strong) NSMutableDictionary* indexPathToDataTaskDict;
@property (nonatomic,strong) dispatch_queue_t imageQueue;
@property (nonatomic,strong) NSManagedObjectContext* backgroundContext;
@property (nonatomic,strong) NSArray* existingFeedImages;
@end

@implementation GRGFeedImageController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.indexPathToDataTaskDict = [NSMutableDictionary dictionary];
        self.imageQueue = dispatch_queue_create("com.greggunner.FeedImageQueue", NULL);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) appDidEnterBackground:(NSNotification*)notif
{
    dispatch_async(self.imageQueue, ^{
        if (self.backgroundContext) {
            [[GRGCoreDataController sharedController] save:nil onContext:self.backgroundContext isBackgroundContext:YES];
        }
    });
}

- (void) getImageFromFeedItem:(FeedItem*)feedItem
                 forIndexPath:(NSIndexPath*)indexPath
               withCompletion:(void (^)(NSError* error, UIImage* image, BOOL fromCache))completion
{
    dispatch_async(self.imageQueue, ^{
        
        if (!self.backgroundContext) {
            self.backgroundContext = [[GRGCoreDataController sharedController] getNewBackgroundManagedObjectContext];
        }
        
        // Return it from the cache if we've got it:
        GRGFeedImageCacheController* cache = [GRGFeedImageCacheController sharedController];
        UIImage* cachedImage = [cache getImageFromCacheForImageID:feedItem.imageID];
        if (cachedImage) {
            if (completion) {
                dispatch_async (dispatch_get_main_queue(), ^{
                    completion(nil,cachedImage,YES);
                });
            }
        } else {
            // Download, resize, return and store it in the cache:
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask* dataTask = [session dataTaskWithURL:[NSURL URLWithString:feedItem.imageURL]
                                                    completionHandler:^(NSData *data,
                                                                        NSURLResponse *response,
                                                                        NSError *error) {
                                                        
                                                        if (!error && data) {
                                                            UIImage* downloadedImage = [UIImage imageWithData:data];
                                                            
                                                            [self updateStatsForImage:downloadedImage fromData:data andFeedItem:feedItem];
                                                            downloadedImage = [GRGFeedImageController imageWithImage:downloadedImage scaledToWidth:[[UIScreen mainScreen] bounds].size.width];
                                                            
                                                            if (completion) {
                                                                dispatch_async (dispatch_get_main_queue(), ^{
                                                                    completion(nil,downloadedImage,NO);
                                                                });
                                                            }
                                                            
                                                            [[GRGFeedImageCacheController sharedController] addImage:downloadedImage toCacheForImageID:feedItem.imageID];
                                                        }
                                                        
                                                    }];
            
            [self.indexPathToDataTaskDict setObject:dataTask forKey:indexPath];
            [dataTask resume];
        }

    });
}

- (void) cancelImageForIndexPath:(NSIndexPath*)indexPath
{
    if (self.indexPathToDataTaskDict[indexPath]) {
        NSURLSessionDataTask* dataTask = self.indexPathToDataTaskDict[indexPath];
        [dataTask cancel];
    }
}

#pragma mark - Stats

- (void) updateStatsForImage:(UIImage*)image fromData:(NSData*)data andFeedItem:(FeedItem*)feedItem
{
    
    if (!self.existingFeedImages) {
        self.existingFeedImages = [[GRGCoreDataController sharedController] getAllFeedImageItemsOnManagedObjectContext:self.backgroundContext];
    }
    
    for (FeedImageItem* imageItem in self.existingFeedImages) {
        if (imageItem.imageID.integerValue == feedItem.imageID.integerValue) {
            // We've already got it.
            return;
        }
    }
    
    NSUInteger imageSizeInBytes = data.length;
    CGFloat imageWidth = image.size.width;
    
    FeedImageItem* imageItem = [[GRGCoreDataController sharedController] getNewFeedImageItemOnManagedObjectContext:self.backgroundContext];
    imageItem.imageID = feedItem.imageID;
    imageItem.imageFileSize = @(imageSizeInBytes);
    imageItem.username = feedItem.userName;
    imageItem.imageWidth = @(imageWidth);

    // Avoid saving to disk on every image
    if (self.backgroundContext.insertedObjects.count >= 10) {
        [[GRGCoreDataController sharedController] save:nil onContext:self.backgroundContext isBackgroundContext:YES];
    }
    
}

#pragma mark - Image Utilities

+ (UIImage*)imageWithImage: (UIImage*)sourceImage scaledToWidth:(float) imageWidth
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = imageWidth / oldWidth;
    
    float newHeight = (sourceImage.size.height * scaleFactor) * [UIScreen mainScreen].scale;
    float newWidth = (oldWidth * scaleFactor) * [UIScreen mainScreen].scale;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
