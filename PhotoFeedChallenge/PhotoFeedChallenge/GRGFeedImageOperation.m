//
//  GRGFeedImageOperation.m
//  PhotoFeedChallenge
//
//  Created by Greg Gunner on 11/11/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import "GRGFeedImageOperation.h"
#import "GRGFeedImageCacheController.h"
@interface GRGFeedImageOperation()

@end

@implementation GRGFeedImageOperation

- (instancetype) initWithImageID:(NSNumber*)newImageID
                        imageURL:(NSString*)newImageURL
                   andCompletion:(void (^)(NSError* error, UIImage* image))completion
{
    self = [super init];
    if (self) {
        self.imageID = newImageID;
        self.imageURL = newImageURL;
        self.storedCompletion = completion;
    }
    return self;
}

- (void) main {
    @autoreleasepool {
        
        // Check the cache
        GRGFeedImageCacheController* cache = [GRGFeedImageCacheController sharedController];
        UIImage* cachedImage = [cache getImageFromCacheForImageID:self.imageID];
        if (cachedImage) {
            if (self.storedCompletion) {
                dispatch_async (dispatch_get_main_queue(), ^{
                    self.storedCompletion(nil,cachedImage);
                });
            }
        } else {
            // Download the big image, resize and cache it:
            NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:self.imageURL]];
            if (imageData) {
                UIImage* image = [UIImage imageWithData: imageData];
                image = [GRGFeedImageOperation imageWithImage:image scaledToWidth:[[UIScreen mainScreen] bounds].size.width];
                [cache addImage:image toCacheForImageID:self.imageID];
                if (self.storedCompletion) {
                    dispatch_async (dispatch_get_main_queue(), ^{
                        self.storedCompletion(nil,image);
                    });
                }
            } else {
                if (self.storedCompletion) {
                    NSError* error = [NSError errorWithDomain:@"Failed to download image" code:0 userInfo:@{@"url":self.imageURL}];
                    dispatch_async (dispatch_get_main_queue(), ^{
                        self.storedCompletion(error,nil);
                    });
                }
            }
        }
    }
}

+(UIImage*)imageWithImage: (UIImage*)sourceImage scaledToWidth:(float) imageWidth
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
