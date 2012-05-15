//
//  EventsAttendingTableViewController.h
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//

#import <UIKit/UIKit.h>
#import "ServerCommunication.h"
#import "AppDelegate.h"
#import "Event.h"
#import "EventCell.h"
#import "User.h"
#import "IconDownloader.h"
#import "EventDetailsViewController.h"
#import <CoreData/CoreData.h>
#import "EventsViewController.h"

@interface EventsAttendingTableViewController : EventsViewController <UIAlertViewDelegate>
{
    UIButton *starButton;
}

@property (nonatomic, retain) NSNumber *fbid;
@property (nonatomic, retain) NSString *name;

@property (nonatomic, retain) IBOutlet UIButton *favButton;
@property (assign) BOOL isStarSelected;
@property (assign) BOOL isAlreadyFavorite;

@end
