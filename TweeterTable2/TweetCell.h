//
//  TweetCell.h
//  TweeterTable2
//
//  Created by Alexey Grabik on 24.08.13.
//  Copyright (c) 2013 Alexey Grabik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetCell : UITableViewCell
@property (retain) IBOutlet UIImageView *avatarView;
@property (retain) IBOutlet UILabel *nameLabel;
@property (retain) IBOutlet UITextView *messageTextField;
@property (retain) IBOutlet UILabel *timeLabel;

@end
