//
//  MessageTableViewCell.m
//  iStreet
//
//  Created by Rishi on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "AppDelegate.h"

@implementation MessageTableViewCell

@synthesize messageView, infoLabel, backgroundImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, 300, 20)];
        infoLabel.textAlignment = UITextAlignmentCenter;
        infoLabel.textColor = [UIColor lightGrayColor];
        infoLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:infoLabel];
        
        
        // Background image will be sized later depending on length of text.
        backgroundImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:backgroundImage];
        
        // Message text view will be sized later depending on length of text.
        messageView = [[UILabel alloc] init];
        messageView.backgroundColor = [UIColor clearColor];
        messageView.lineBreakMode = UILineBreakModeWordWrap;
        messageView.numberOfLines = 0;
        
        //messageView.editable = NO;
        //messageView.scrollEnabled = NO;
        [self.contentView addSubview:messageView];

        [self setAccessoryType:UITableViewCellAccessoryNone];
    }
    return self;
}

- (void)packCellWithMessage:(Message *)m andFont:(UIFont *)font
{
    CGSize maxTextSize = CGSizeMake(MAX_WIDTH, CGFLOAT_MAX);
    NSString *messageText = [NSString stringWithFormat:@"%@: %@", m.user, m.message];
    CGSize fittedSize = [messageText sizeWithFont:font
                              constrainedToSize:maxTextSize];
        
    UIImage *bgImage = nil;
    NSString *myNetID = [(AppDelegate *)[[UIApplication sharedApplication] delegate] netID];
    
    if ([m.user isEqualToString:myNetID]) 
    { 
        // sent messages
        bgImage = [[UIImage imageNamed:@"grey.png"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
        
        [self.messageView setFrame:CGRectMake(320 - fittedSize.width - PADDING,
                                                     PADDING*2,
                                                     fittedSize.width,
                                                     fittedSize.height)];
        
        [self.backgroundImage setFrame:CGRectMake(self.messageView.frame.origin.x - PADDING/2 + 2,
                                              self.messageView.frame.origin.y - PADDING/2,
                                              fittedSize.width + PADDING,
                                              fittedSize.height + PADDING)];
    } 
    else 
    {
        bgImage = [[UIImage imageNamed:@"light_orange.png"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
        
        [self.messageView setFrame:CGRectMake(PADDING, PADDING*2 , fittedSize.width, fittedSize.height)];
        
        [self.backgroundImage setFrame:CGRectMake( self.messageView.frame.origin.x - PADDING/2 - 2,
                                                  self.messageView.frame.origin.y - PADDING/2 + 1,
                                                  fittedSize.width + PADDING,
                                                  fittedSize.height + PADDING)];
    }
    [self.backgroundImage setImage:bgImage];
    
    [self.messageView setText:messageText];
    [self.messageView setFont:font];

    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDate *date = [formatter dateFromString:m.timestamp];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:@"MMMM d, yyyy h:mm a"];
    NSString *timestamp = [formatter stringFromDate:date];
    
    UIFont *infoLabelFont = [UIFont fontWithName:font.fontName size:font.pointSize - 1];
    //CGSize infoLabelSize = [timestamp sizeWithFont:infoLabelFont constrainedToSize:maxTextSize];
    //[self.infoLabel setFrame:CGRectMake(10, 0, 300, infoLabelSize.height)];
    [self.infoLabel setFont:infoLabelFont];
    [self.infoLabel setText:timestamp];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
