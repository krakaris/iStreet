//
//  MessageTableViewCell.h
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
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
