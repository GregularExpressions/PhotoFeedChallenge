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

@interface GRGFeedViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic,strong) UITableView* feedTableView;
@end

static NSString* kFeedCellReuseIdentifier = @"kFeedCellReuseIdentifier";

@implementation GRGFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create the TableView we'll show the FeedItems in:
    self.feedTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.feedTableView.delegate = self;
    self.feedTableView.dataSource = self;
    [self.view addSubview:self.feedTableView];
    
    GRGFeedAPIController* apiController = [[GRGFeedAPIController alloc] init];
    [apiController downloadAndStoreFeedItemsWithCompletion:^(NSError *error, NSArray *feedItems) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // TODO: Purge local image cache
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GRGFeedTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kFeedCellReuseIdentifier forIndexPath:indexPath];
    
    // TODO: Set Cell Content
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Image animation
}


@end
