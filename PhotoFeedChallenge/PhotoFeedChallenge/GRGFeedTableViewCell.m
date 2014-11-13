//
//  FeedTableViewCell.m
//  PhotoFeedChallenge
//
//  Created by Greg on 08/11/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import "GRGFeedTableViewCell.h"

@interface GRGFeedTableViewCell()
@property (nonatomic,strong) UIImageView* photoImageView;
@property (nonatomic,strong) UILabel* titleLabel;
@end

@implementation GRGFeedTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithRed:200.0/255.0 green:222.0/255.0 blue:227.0/255.0 alpha:1.0]];
        [self.contentView setBackgroundColor:[UIColor colorWithRed:200.0/255.0 green:222.0/255.0 blue:227.0/255.0 alpha:1.0]];
        
        
        self.photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20.0f, [[UIScreen mainScreen] bounds].size.width, 120.0f)];
        [self.photoImageView setBackgroundColor:[UIColor colorWithRed:200.0/255.0 green:222.0/255.0 blue:227.0/255.0 alpha:1.0]];
        //[self.photoImageView setOpaque:YES];
        [self.photoImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.photoImageView setClipsToBounds:YES];
        [self.photoImageView setAlpha:0];
        [self.contentView addSubview:self.photoImageView];
        
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 20.0f)];
        [self.titleLabel setBackgroundColor:[UIColor whiteColor]];
        [self.titleLabel setOpaque:YES];
        [self.titleLabel setNumberOfLines:0];
        [self.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.titleLabel setTextColor:[UIColor colorWithRed:3.0/255.0 green:22.0/255.0 blue:52.0/255.0 alpha:1.0]];
        [self.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)prepareForReuse
{
    [self.photoImageView setImage:nil];
    [self.photoImageView setAlpha:0];
    [self.photoImageView setFrame:CGRectMake(0, 20.0f, [[UIScreen mainScreen] bounds].size.width, 120.0f)];
}

- (void) setTitleText:(NSString*)newText
{
    [self.titleLabel setText:newText];
}

- (void) setPhotoImage:(UIImage*)newPhotoImage withAnimation:(BOOL)animation
{
    
    [self.photoImageView setImage:newPhotoImage];
    
    if (animation) {
        CGRect endFrame = self.photoImageView.frame;
        CGPoint endCentre = self.photoImageView.center;
        
        CGRect startFrame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width/3, endFrame.size.width/3);
        [self.photoImageView setFrame:startFrame];
        [self.photoImageView setCenter:endCentre];
        
        [UIView animateWithDuration:0.5 animations:^{
            [self.photoImageView setAlpha:1.0];
            [self.photoImageView setFrame:endFrame];
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [self.photoImageView setAlpha:1.0];
    }
}

@end
