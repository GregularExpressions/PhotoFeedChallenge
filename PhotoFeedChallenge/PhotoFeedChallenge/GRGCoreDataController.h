//
//  GRGCoreDataController.h
//  PhotoFeedChallenge
//
//  Created by Greg on 08/11/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface GRGCoreDataController : NSObject
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
+ (GRGCoreDataController*) sharedController;
- (BOOL) save:(NSError**)saveError onContext:(NSManagedObjectContext*)context isBackgroundContext:(BOOL)background;
@end
