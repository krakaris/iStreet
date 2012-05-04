//
//  EventDetailsViewController.h
//  iStreet
//
//  Created by Alexa Krakaris on 4/14/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "User.h"
#import "ServerCommunication.h"

@interface EventDetailsViewController : UIViewController <ServerCommunicationDelegate>
{
    User *user;
    NSArray *friendsList;
    BOOL userIsAttending;
}

@property (nonatomic, retain) Event *myEvent;
@property (weak, nonatomic) IBOutlet UILabel *eventTitle;
@property (weak, nonatomic) IBOutlet UILabel *eventDate;
@property (weak, nonatomic) IBOutlet UILabel *eventTime;
@property (weak, nonatomic) IBOutlet UIImageView *eventImage;
@property (weak, nonatomic) IBOutlet UIButton *attendButton;
@property (weak, nonatomic) IBOutlet UITextView *descriptionText;
@property (weak, nonatomic) IBOutlet UIButton *seeAllFriendsAttending;
@property (weak, nonatomic) IBOutlet UILabel *eventEntry;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *toggleAttendingIndicator;

- (IBAction)attend:(UIButton *)sender;

@end
