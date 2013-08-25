//
//  TweetCell.m
//  TweeterTable2
//
//  Created by Alexey Grabik on 24.08.13.
//  Copyright (c) 2013 Alexey Grabik. All rights reserved.
//

#import "TweetCell.h"

@implementation TweetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    self.messageTextView.userInteractionEnabled = NO;
    self.messageTextView.editable = NO;
    self.messageTextView.dataDetectorTypes = UIDataDetectorTypeLink;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (void)setName:(NSString *)name message:(NSString *)message time:(NSString *)time avatar:(UIImage *)image
{
    self.imageView.image = image;
    self.nameLabel.text = name;
    self.messageTextView.text = message;
    self.timeLabel.text = time;
}

@end
