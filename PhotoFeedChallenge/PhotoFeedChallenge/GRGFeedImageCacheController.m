//
//  GRGFeedImageCacheController.m
//  PhotoFeedChallenge
//
//  Created by Greg Gunner on 11/11/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import "GRGFeedImageCacheController.h"

@interface GRGFeedImageCacheController()
@property (nonatomic,strong) NSCache* imageCache;
@end

@implementation GRGFeedImageCacheController

+ (GRGFeedImageCacheController*) sharedController
{
    static GRGFeedImageCacheController *sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedController = [[self alloc] init];
    });
    return sharedController;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.imageCache = [[NSCache alloc]init];
    }
    return self;
}

- (void) addImage:(UIImage*)image toCacheForImageID:(NSNumber*)imageID
{
    [self.imageCache setObject:image forKey:imageID];
}

- (UIImage*) getImageFromCacheForImageID:(NSNumber*)imageID
{
    return [self.imageCache objectForKey:imageID];
}

@end
