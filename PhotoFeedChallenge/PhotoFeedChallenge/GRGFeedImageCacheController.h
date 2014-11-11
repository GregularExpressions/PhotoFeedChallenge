//
//  GRGFeedImageCacheController.h
//  PhotoFeedChallenge
//
//  Created by Greg Gunner on 11/11/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GRGFeedImageCacheController : NSObject
+ (GRGFeedImageCacheController*) sharedController;
- (void) addImage:(UIImage*)image toCacheForImageID:(NSNumber*)imageID;
- (UIImage*) getImageFromCacheForImageID:(NSNumber*)imageID;
@end
