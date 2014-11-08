//
//  FeedItem.h
//  PhotoFeedChallenge
//
//  Created by Greg on 08/11/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FeedItem : NSManagedObject

@property (nonatomic, retain) NSNumber * feedID;
@property (nonatomic, retain) NSNumber * imageID;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * imageURL;

@end
