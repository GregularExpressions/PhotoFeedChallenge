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

@interface GRGFeedViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic,strong) UITableView* feedTableView;
@property (nonatomic,strong) NSArray* tableFeedItems;
@property (nonatomic,strong) GRGFeedImageController* imageController;
@end

static NSString* kFeedCellReuseIdentifier = @"kFeedCellReuseIdentifier";

@implementation GRGFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageController = [[GRGFeedImageController alloc] init];
    
    // Create the TableView we'll show the FeedItems in:
    self.feedTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.feedTableView.delegate = self;
    self.feedTableView.dataSource = self;
    [self.feedTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.feedTableView registerClass:[GRGFeedTableViewCell class] forCellReuseIdentifier:kFeedCellReuseIdentifier];
    [self.feedTableView setRowHeight:kFeedTableViewCellHeight];
    [self.view addSubview:self.feedTableView];
    
    GRGFeedAPIController* apiController = [[GRGFeedAPIController alloc] init];
    __weak GRGFeedViewController* weakSelf = self;
    [apiController downloadAndStoreFeedItemsWithCompletion:^(NSError *error, NSArray *feedItems) {
        if (!error) {
            weakSelf.tableFeedItems = feedItems;
            [self.feedTableView reloadData];
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
    FeedItem* feedItem = self.tableFeedItems[indexPath.row];
    [cell setTitleText:feedItem.title];
        
    [self.imageController getImageWithID:feedItem.imageID atURL:feedItem.imageURL forIndexPath:indexPath withCompletion:^(NSError *error, UIImage *image) {
        if (!error) {
            if ([tableView.indexPathsForVisibleRows containsObject:indexPath]) {
                [cell setPhotoImage:image];
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
    // TODO: Image animation
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
