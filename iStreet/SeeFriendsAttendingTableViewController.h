//
//  SeeFriendsAttendingTableViewController.h
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//

#import <UIKit/UIKit.h>
#import "ServerCommunication.h"
#import "AppDelegate.h"
#import "IconDownloader.h"

@interface SeeFriendsAttendingTableViewController : UITableViewController <ServerCommunicationDelegate, UIAlertViewDelegate, IconDownloaderDelegate>
{
    dispatch_queue_t downloadFriendsAttendingQ;
    NSMutableDictionary *_iconsBeingDownloaded;
}

@property NSString * fbid_loggedInUser;
@property NSArray * friendsFbidArray;
@property NSMutableArray *listOfAttendingFriends;
@property NSString *eventID;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;


@end
