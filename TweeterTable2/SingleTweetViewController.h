//
//  SingleTweetViewController.h
//  TweeterTable2
//
//  Created by Alexey Grabik on 24.08.13.
//  Copyright (c) 2013 Alexey Grabik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SingleTweetViewController : UIViewController
@property (retain) NSDictionary *tweet;
@property (retain) IBOutlet UIView *tweetAreaView;

- (IBAction)back:(id)sender;

@end
