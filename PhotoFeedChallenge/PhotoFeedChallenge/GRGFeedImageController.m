//
//  GRGFeedImageController.m
//  PhotoFeedChallenge
//
//  Created by Greg on 10/11/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//
#import "GRGFeedImageController.h"
#import "GRGFeedImageOperation.h"

@interface GRGFeedImageController()
@property (nonatomic,strong) NSOperationQueue* imageOperationQueue;
@property (nonatomic,strong) NSMutableDictionary* indexPathToOperationDict;
@end

@implementation GRGFeedImageController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.imageOperationQueue = [[NSOperationQueue alloc] init];
        [self.imageOperationQueue setName:@"FeedImageOperationQueue"];
        self.indexPathToOperationDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void) getImageWithID:(NSNumber*)imageID
                  atURL:(NSString*)url
           forIndexPath:(NSIndexPath*)indexPath
         withCompletion:(void (^)(NSError* error, UIImage* image))completion
{
    GRGFeedImageOperation* newOperation = [[GRGFeedImageOperation alloc] initWithImageID:imageID imageURL:url andCompletion:completion];
    [self.imageOperationQueue addOperation:newOperation];
    [self.indexPathToOperationDict setObject:newOperation forKey:indexPath];
}

- (void) cancelOperationForIndexPath:(NSIndexPath*)indexPath
{
    if (self.indexPathToOperationDict[indexPath]) {
        GRGFeedImageOperation* operation = self.indexPathToOperationDict[indexPath];
        [operation cancel];
    }
}

@end
