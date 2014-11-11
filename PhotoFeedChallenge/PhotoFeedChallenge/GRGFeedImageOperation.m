//
//  GRGFeedImageOperation.m
//  PhotoFeedChallenge
//
//  Created by Greg Gunner on 11/11/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import "GRGFeedImageOperation.h"
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
        
        // TODO: check the cache
        
        // Download the big image:
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:self.imageURL]];
        if (imageData) {
            UIImage* image = [UIImage imageWithData: imageData];
            image = [GRGFeedImageOperation imageWithImage:image scaledToWidth:[[UIScreen mainScreen] bounds].size.width];
            // TODO: Cache image
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

+(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
