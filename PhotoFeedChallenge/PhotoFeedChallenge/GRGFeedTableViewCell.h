//
//  FeedTableViewCell.h
//  PhotoFeedChallenge
//
//  Created by Greg on 08/11/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGFloat kFeedTableViewCellHeight = 140.0f;
@interface GRGFeedTableViewCell : UITableViewCell
- (void) setTitleText:(NSString*)newText;
- (void) setPhotoImage:(UIImage*)newPhotoImage;
@end
