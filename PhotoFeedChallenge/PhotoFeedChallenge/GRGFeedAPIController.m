//
//  GRGFeedAPIController.m
//  PhotoFeedChallenge
//
//  Created by Greg on 08/11/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import "GRGFeedAPIController.h"

static NSString* kFeedItemAPIEndPoint = @"http://challenge.superfling.com";

@implementation GRGFeedAPIController
- (void) downloadAndStoreFeedItemsWithCompletion:(void (^)(NSError* error, NSArray* feedItems))completion
{
    // On cold launch the user will be waiting for this, so it's high priority.
    // Given the simplicity of the download we can avoid anything more complex
    // like a dedicated dispatch queue or NSOperation
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSArray* results = [self downloadJSON];
        if (results) {
            NSLog(@"results = \n%@",results);
        }
        
        if (completion) {
            //completion(nil,results);
        }
        
    });
}

- (NSArray*) downloadJSON
{
    // Hit the endpoint for data:
    NSHTTPURLResponse *response = nil;
    NSURL *url = [NSURL URLWithString:kFeedItemAPIEndPoint];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
    NSError* connectionError;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    NSMutableArray *result;
    if (!connectionError && responseData) {
        // Parse the response:
        result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        
        for (NSMutableDictionary *dic in result)
        {
            NSString *string = dic[@"array"];
            if (string)
            {
                NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
                dic[@"array"] = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            }
        }
    } else {
        NSLog(@"Error downloading content from %@: %@",kFeedItemAPIEndPoint,connectionError);
        // TODO: Handle obvious errors like timeouts, lack of connectivity and report to the user.
    }
    
    return result;
}
@end
