//
//  GRGFeedImageController.h
//  PhotoFeedChallenge
//
//  Created by Greg on 10/11/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import "FeedItem.h"
@interface GRGFeedImageController : NSObject
/**
 *  Download, resize and cache the image.
 *  The method will return the resized version
 *  from cache if we've already got it.
 */
- (void) getImageFromFeedItem:(FeedItem*)feedItem
           forIndexPath:(NSIndexPath*)indexPath
         withCompletion:(void (^)(NSError* error, UIImage* image, BOOL fromCache))completion;
- (void) cancelImageForIndexPath:(NSIndexPath*)indexPath;
@end
