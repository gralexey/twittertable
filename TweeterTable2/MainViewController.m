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
    
    NSString *text = [[self.tweets objectAtIndex:indexPath.row] objectForKey:@"text"];
    NSString *name = [[[self.tweets objectAtIndex:indexPath.row] objectForKey:@"user"] objectForKey:@"name"];
    NSString *time = [[[self.tweets objectAtIndex:indexPath.row] objectForKey:@"user"] objectForKey:@"created_at"];
    NSString *avatarURL = [[self.tweets objectAtIndex:indexPath.row] objectForKey:@"profile_image_url"];
    UIImage *image = [UIImage imageNamed:@"im"]; //[UIImage imageWithData:[[self.tweetTable objectAtIndex:indexPath.row] objectForKey:@"avatarData"]];

    [cell setName:name message:text time:time avatar:image];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SingleTweetViewController *vc = [[[SingleTweetViewController alloc] init] autorelease];
    vc.tweet = [self.tweets objectAtIndex:indexPath.row];
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

@end
