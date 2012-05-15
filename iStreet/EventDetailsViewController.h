//
//  EventDetailsViewController.h
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "User.h"
#import "SeeFriendsAttendingTableViewController.h"
#import "ServerCommunication.h"
#import "FriendsViewController.h"

extern UIColor *lightOrangeColor;

@interface EventDetailsViewController : UIViewController <ServerCommunicationDelegate, UIAlertViewDelegate>
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
@property (nonatomic, retain) IBOutlet UILabel *eventEntry;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *toggleAttendingIndicator;

//Add Event to the user's list of events. Place Check mark next to this event in the table view
- (IBAction)attend:(UIButton *)sender;
//See all Facebook friends that are also attending this event. Must be logged into Facebook. 
- (IBAction)seeFriends:(id)sender;

@end
