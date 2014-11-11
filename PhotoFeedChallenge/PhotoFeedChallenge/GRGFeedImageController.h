//
//  GRGFeedImageController.h
//  PhotoFeedChallenge
//
//  Created by Greg on 10/11/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

@interface GRGFeedImageController : NSObject
/**
 *  Download, resize and cache the image.
 *  The method will return the resized version
 *  from cache if we've already got it.
 */
- (void) getImageWithID:(NSNumber*)imageID
                  atURL:(NSString*)url
           forIndexPath:(NSIndexPath*)indexPath
         withCompletion:(void (^)(NSError* error, UIImage* image))completion;
- (void) cancelOperationForIndexPath:(NSIndexPath*)indexPath;
@end
