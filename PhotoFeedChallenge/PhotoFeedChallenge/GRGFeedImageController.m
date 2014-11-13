//
//  GRGFeedImageController.m
//  PhotoFeedChallenge
//
//  Created by Greg on 10/11/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//
#import "GRGFeedImageController.h"
#import "GRGFeedImageCacheController.h"

@interface GRGFeedImageController()
@property (nonatomic,strong) NSMutableDictionary* indexPathToDataTaskDict;
@property (nonatomic, strong) dispatch_queue_t imageQueue;
@end

@implementation GRGFeedImageController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.indexPathToDataTaskDict = [NSMutableDictionary dictionary];
        self.imageQueue = dispatch_queue_create("com.greggunner.FeedImageQueue", NULL);
    }
    return self;
}

- (void) getImageWithID:(NSNumber*)imageID
                  atURL:(NSString*)url
           forIndexPath:(NSIndexPath*)indexPath
         withCompletion:(void (^)(NSError* error, UIImage* image))completion
{
    dispatch_async(self.imageQueue, ^{
        
        // Return it from the cache if we've got it:
        GRGFeedImageCacheController* cache = [GRGFeedImageCacheController sharedController];
        UIImage* cachedImage = [cache getImageFromCacheForImageID:imageID];
        if (cachedImage) {
            if (completion) {
                dispatch_async (dispatch_get_main_queue(), ^{
                    completion(nil,cachedImage);
                });
            }
        } else {
            // Download, resize, return and store it in the cache:
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask* dataTask = [session dataTaskWithURL:[NSURL URLWithString:url]
                                                    completionHandler:^(NSData *data,
                                                                        NSURLResponse *response,
                                                                        NSError *error) {
                                                        
                                                        if (!error && data) {
                                                            UIImage* downloadedImage = [UIImage imageWithData:data];
                                                            downloadedImage = [GRGFeedImageController imageWithImage:downloadedImage scaledToWidth:[[UIScreen mainScreen] bounds].size.width];
                                                            
                                                            if (completion) {
                                                                dispatch_async (dispatch_get_main_queue(), ^{
                                                                    completion(nil,downloadedImage);
                                                                });
                                                            }
                                                            
                                                            [[GRGFeedImageCacheController sharedController] addImage:downloadedImage toCacheForImageID:imageID];
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
