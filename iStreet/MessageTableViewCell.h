//
//  MessageTableViewCell.h
//  iStreet
//
//  Created by Rishi on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

enum messageBubbleValues 
{
    PADDING = 17,
    MAX_WIDTH = 200,
    MAX_HEIGHT = 500
};

@interface MessageTableViewCell : UITableViewCell 
{    
    UIImageView *backgroundImage;
    UILabel *messageView;
    UILabel *infoLabel;
}

@property(nonatomic, retain) UIImageView *backgroundImage;
@property(nonatomic, retain) UILabel *messageView;
@property(nonatomic, retain) UILabel *infoLabel;

- (void)packCellWithMessage:(Message *)m andFont:(UIFont *)font;

@end
