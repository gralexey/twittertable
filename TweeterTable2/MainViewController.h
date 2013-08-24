//
//  MainViewController.h
//  TweeterTable2
//
//  Created by Alexey Grabik on 24.08.13.
//  Copyright (c) 2013 Alexey Grabik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (retain) IBOutlet UITableView *tableView;
@property (retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (retain) NSArray *tweets;

- (IBAction)updateClicked:(id)sender;

@end
