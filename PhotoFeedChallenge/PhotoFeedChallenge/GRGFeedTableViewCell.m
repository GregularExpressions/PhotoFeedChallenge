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
        [self setBackgroundColor:[GRGFeedTableViewCell cellBackgroundColor]];
        [self.contentView setBackgroundColor:[GRGFeedTableViewCell cellBackgroundColor]];
        
        self.photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kFeedTableViewCellHeight)];
        [self.photoImageView setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:1.0]];
        [self.photoImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.photoImageView setClipsToBounds:YES];
        [self.photoImageView setAlpha:0];
        [self.contentView addSubview:self.photoImageView];
        
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 20.0f)];
        [self.titleLabel setBackgroundColor:[GRGFeedTableViewCell titleLabelBackgroundColor]];
        [self.titleLabel setOpaque:YES];
        [self.titleLabel setNumberOfLines:0];
        [self.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.titleLabel setTextColor:[UIColor whiteColor]];
        [self.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.titleLabel setUserInteractionEnabled:NO];
        [self.contentView addSubview:self.titleLabel];
        
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [self.titleLabel setBackgroundColor:[GRGFeedTableViewCell titleLabelBackgroundColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self.titleLabel setBackgroundColor:[GRGFeedTableViewCell titleLabelBackgroundColor]];
}

- (void)prepareForReuse
{
    [self.photoImageView setImage:nil];
    [self.photoImageView setAlpha:0];
    [self.photoImageView setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kFeedTableViewCellHeight)];
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

- (void) performTapAnimation
{
    // I'm not a big fan of this animation:
    if (self.photoImageView.alpha == 1) {
        [UIView animateWithDuration:0.5 animations:^{
            self.photoImageView.transform = CGAffineTransformMakeScale(-1, 1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                self.photoImageView.transform = CGAffineTransformMakeScale(1, 1);
            }];
        }];
        
    }
}

#pragma mark - UIColors

+ (UIColor*) titleLabelBackgroundColor
{
    return [UIColor colorWithWhite:0.1 alpha:0.5];
}

+ (UIColor*) cellBackgroundColor
{
    return [UIColor colorWithWhite:0.9 alpha:1.0];
}

@end
