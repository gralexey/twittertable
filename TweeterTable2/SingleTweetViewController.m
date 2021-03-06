//
//  SingleTweetViewController.m
//  TweeterTable2
//
//  Created by Alexey Grabik on 24.08.13.
//  Copyright (c) 2013 Alexey Grabik. All rights reserved.
//

#import "SingleTweetViewController.h"
#import "TweetCell.h"

@interface SingleTweetViewController ()

@end

@implementation SingleTweetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //TweetCell *cell = [[TweetCell alloc] init];
    
    NSString *text = [self.tweet objectForKey:@"text"];
    NSString *name = [[self.tweet objectForKey:@"user"] objectForKey:@"name"];
    NSString *time = [[self.tweet objectForKey:@"user"] objectForKey:@"created_at"];
    NSString *avatarURL = [self.tweet objectForKey:@"profile_image_url"];
    
    UIImage *image = self.avatarImage ? self.avatarImage : [UIImage imageNamed:@"im"];
    
    self.messageTextView.text = text;
    self.timeLabel.text = time;
    self.nameLabel.text = name;
    [self.avatarView setImage:image];
    
    //[cell setName:name message:text time:time avatar:image];
    //[self.tweetAreaView addSubview:cell];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
