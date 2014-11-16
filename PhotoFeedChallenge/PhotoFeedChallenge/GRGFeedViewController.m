//
//  ViewController.m
//  PhotoFeedChallenge
//
//  Created by Greg on 08/11/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import "GRGFeedViewController.h"
#import "GRGFeedTableViewCell.h"
#import "GRGFeedAPIController.h"
#import "GRGFeedImageController.h"
#import "FeedItem.h"

@interface GRGFeedViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (nonatomic,strong) UITableView* feedTableView;
@property (nonatomic,strong) UIActivityIndicatorView* activityView;
@property (nonatomic,strong) NSArray* tableFeedItems;
@property (nonatomic,strong) GRGFeedImageController* imageController;
@property (nonatomic) CGFloat previousScrollViewYOffset;
@property (nonatomic,strong) NSDate* statsLastTriggeredDate;
@end

static NSString* kFeedCellReuseIdentifier = @"kFeedCellReuseIdentifier";

@implementation GRGFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Photo Feed";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.imageController = [[GRGFeedImageController alloc] init];
    
    // Create the TableView we'll show the FeedItems in and push it offscreen:
    self.feedTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                                       self.view.frame.size.height,
                                                                       self.view.frame.size.width,
                                                                       self.view.frame.size.height)
                                                      style:UITableViewStylePlain];
    self.feedTableView.delegate = self;
    self.feedTableView.dataSource = self;
    [self.feedTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.feedTableView registerClass:[GRGFeedTableViewCell class] forCellReuseIdentifier:kFeedCellReuseIdentifier];
    [self.feedTableView setRowHeight:kFeedTableViewCellHeight];
    [self.view addSubview:self.feedTableView];
    
    // We introduce an UIActivityIndicatorView for when the webservice takes a few seconds to respond on first launch.
    // it could certainly be more imaginative:
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityView setTintColor:self.navigationController.navigationBar.barTintColor];
    [self.activityView startAnimating];
    [self.activityView setCenter:self.view.center];
    [self.view addSubview:self.activityView];
    
    GRGFeedAPIController* apiController = [[GRGFeedAPIController alloc] init];
    __weak GRGFeedViewController* weakSelf = self;
    [apiController downloadAndStoreFeedItemsWithCompletion:^(NSError *error, NSArray *feedItems) {
        if (!error) {
            weakSelf.tableFeedItems = feedItems;
            [weakSelf.feedTableView reloadData];
            [weakSelf.activityView removeFromSuperview];
            [UIView animateWithDuration:0.3 animations:^{
                [weakSelf.feedTableView setFrame:CGRectMake(self.view.frame.origin.x,
                                                        self.view.frame.origin.y,
                                                        self.view.frame.size.width,
                                                        self.view.frame.size.height)];
            }];
        } else {
            NSLog(@"Error downloading and storing FeedItems: %@",error);
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableFeedItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GRGFeedTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kFeedCellReuseIdentifier forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    FeedItem* feedItem = self.tableFeedItems[indexPath.row];
    [cell setTitleText:feedItem.title];
        
    [self.imageController getImageFromFeedItem:feedItem forIndexPath:indexPath withCompletion:^(NSError *error, UIImage *image, BOOL fromCache) {
        if (!error) {
            if ([tableView.indexPathsForVisibleRows containsObject:indexPath]) {
                [cell setPhotoImage:image withAnimation:!fromCache];
            }
        }
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.imageController cancelImageForIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GRGFeedTableViewCell* cell = (GRGFeedTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell performTapAnimation];
}

#pragma mark - UINavigationBar Retreat

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect frame = self.navigationController.navigationBar.frame;
    CGFloat size = frame.size.height - 21;
    CGFloat framePercentageHidden = ((20 - frame.origin.y) / (frame.size.height - 1));
    CGFloat scrollOffset = scrollView.contentOffset.y;
    CGFloat scrollDiff = scrollOffset - self.previousScrollViewYOffset;
    CGFloat scrollHeight = scrollView.frame.size.height;
    CGFloat scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom;
    
    if (scrollOffset <= -scrollView.contentInset.top) {
        frame.origin.y = 20;
    } else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight) {
        frame.origin.y = -size;
    } else {
        frame.origin.y = MIN(20, MAX(-size, frame.origin.y - scrollDiff));
    }
    
    [self.navigationController.navigationBar setFrame:frame];
    [self updateBarAlpha:(1 - framePercentageHidden)];
    self.previousScrollViewYOffset = scrollOffset;
    
    [self checkIfTableBottom:scrollView];
}

- (void) checkIfTableBottom:(UIScrollView*)scrollView
{
    CGFloat height = scrollView.frame.size.height;
    CGFloat contentYoffset = scrollView.contentOffset.y;
    CGFloat distanceFromBottom = scrollView.contentSize.height - contentYoffset;

    if(distanceFromBottom <= height && self.tableFeedItems.count > 0)
    {
        
        if (!self.statsLastTriggeredDate) {
            self.statsLastTriggeredDate = [NSDate dateWithTimeIntervalSince1970:0];
        }
        
        if ([[NSDate date] timeIntervalSinceDate:self.statsLastTriggeredDate] > 5) {
            self.statsLastTriggeredDate = [NSDate date];
            
            // Stats will be generated based on the full size images we have downloaded
            // thus far, even if that's not all of them we'll continue anyway:
            [GRGFeedAPIController calculateAndOutputStats];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self stoppedScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self stoppedScrolling];
    }
}

- (void)stoppedScrolling
{
    CGRect frame = self.navigationController.navigationBar.frame;
    if (frame.origin.y < 20) {
        [self animateNavBarTo:-(frame.size.height - 21)];
    }
}

- (void)updateBarAlpha:(CGFloat)alpha
{
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[[UIColor whiteColor] colorWithAlphaComponent:alpha]}];
}

- (void)animateNavBarTo:(CGFloat)y
{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.navigationController.navigationBar.frame;
        CGFloat alpha = (frame.origin.y >= y ? 0 : 1);
        frame.origin.y = y;
        [self.navigationController.navigationBar setFrame:frame];
        [self updateBarAlpha:alpha];
    }];
}

@end
