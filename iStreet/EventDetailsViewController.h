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
#import "SeeFriendsAttendingTableViewController.h"
#import "ServerCommunication.h"

@interface EventDetailsViewController : UIViewController <ServerCommunicationDelegate>
{
    User *user;
    NSArray *friendsList;
    BOOL userIsAttending;
}

@property (nonatomic, retain) Event *myEvent;
@property (nonatomic, retain) IBOutlet UILabel *eventTitle;
@property (nonatomic, retain) IBOutlet UILabel *eventDate;
@property (nonatomic, retain) IBOutlet UILabel *eventTime;
@property (nonatomic, retain) IBOutlet UIImageView *eventImage;
@property (nonatomic, retain) IBOutlet UIButton *attendButton;
@property (nonatomic, retain) IBOutlet UITextView *descriptionText;
@property (nonatomic, retain) IBOutlet UIButton *seeAllFriendsAttending;
@property (nonatomic, retain) IBOutlet UILabel *eventEntry;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *toggleAttendingIndicator;

- (IBAction)attend:(UIButton *)sender;

@end
