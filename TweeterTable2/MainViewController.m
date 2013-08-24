//
//  MainViewController.m
//  TweeterTable2
//
//  Created by Alexey Grabik on 24.08.13.
//  Copyright (c) 2013 Alexey Grabik. All rights reserved.
//

#import "MainViewController.h"
#import "STTwitter/STTwitter.h"
#import "TweetCell.h"
#import "SingleTweetViewController.h"

#define CONSUMER_KEY @"ifMXK02FOviMepgfPx9yQ"
#define CONSUMER_SECRET @"IymtABNgu9DZMwbo472vzsPwP8vizrZzmC78iEpfkfE"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.avatarUrlsAndIamges = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"id"];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    self.tweets = [NSArray array];
    [self requestStatuses];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)updateClicked:(id)sender
{
    [self requestStatuses];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tweets count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id"];
    NSString *text = [[self.tweets objectAtIndex:indexPath.row] objectForKey:@"text"];
    cell.messageTextView.text = text;
    CGFloat v = cell.messageTextView.contentSize.height;
    return v + 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id"];
    if (!cell)
    {
        cell = [[TweetCell alloc] init];
    }
    
    NSDictionary *tweet = [self.tweets objectAtIndex:indexPath.row];
    NSString *text = tweet[@"text"];
    NSString *name = tweet[@"user"][@"name"];
    NSString *time = tweet[@"user"][@"created_at"];
    NSString *avatarURL = tweet[@"user"][@"profile_image_url"];
    
    UIImage *image = nil;
    if (self.avatarUrlsAndIamges[avatarURL])
    {
        image = self.avatarUrlsAndIamges[avatarURL];
    }
    else
    {
        image = [UIImage imageNamed:@"im"];
    }
    
    //UIImage *image = self.avatarUrlsAndIamges[avatarURL] ? self.avatarUrlsAndIamges[avatarURL] : [UIImage imageNamed:@"im"];

    [cell setName:name message:text time:time avatar:image];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SingleTweetViewController *vc = [[[SingleTweetViewController alloc] init] autorelease];
    vc.tweet = [self.tweets objectAtIndex:indexPath.row];
    vc.avatarImage = self.avatarUrlsAndIamges[vc.tweet[@"user"][@"profile_image_url"]];
    [self.navigationController pushViewController:vc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)requestStatuses
{
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:CONSUMER_KEY consumerSecret:CONSUMER_SECRET];
    
    [self.activityIndicatorView startAnimating];
    
    [twitter verifyCredentialsWithSuccessBlock:^(NSString *bearerToken)
     {
         
         [twitter getUserTimelineWithScreenName:@"barackobama" successBlock:^(NSArray *statuses)
          {
              NSLog(@"%@", statuses);
              self.tweets = statuses;
              [self.tableView reloadData];
              [self.activityIndicatorView stopAnimating];
              [self requstAvatars];
              
          } errorBlock:^(NSError *error)
          {
              NSLog(@"%@", [error description]);
              
          }];
         
     }
     errorBlock:^(NSError *error)
     {
         NSLog(@"%@", [error description]);
     }];
}

- (void)requstAvatars
{
    dispatch_async(dispatch_queue_create("new queue", 0), ^{
    
        for (NSDictionary *dict in self.tweets)
        {
            NSString *avatarUrl = dict[@"user"][@"profile_image_url"];
            if (!self.avatarUrlsAndIamges[avatarUrl])
            {
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrl]];
                self.avatarUrlsAndIamges[avatarUrl] = [UIImage imageWithData:data];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

@end
