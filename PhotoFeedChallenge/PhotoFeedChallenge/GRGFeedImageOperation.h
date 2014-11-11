//
//  GRGFeedImageOperation.h
//  PhotoFeedChallenge
//
//  Created by Greg Gunner on 11/11/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GRGFeedImageOperation : NSOperation
@property (nonatomic,strong) NSNumber* imageID;
@property (nonatomic,strong) NSString* imageURL;
@property (nonatomic,copy) void (^storedCompletion)(NSError* error, UIImage* image);
- (instancetype) initWithImageID:(NSNumber*)newImageID
                        imageURL:(NSString*)newImageURL
                   andCompletion:(void (^)(NSError* error, UIImage* image))completion;
@end
