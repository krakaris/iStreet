//
//  SeeFriendsAttendingTableViewController.h
//  iStreet
//
//  Created by Akarshan Kumar on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerCommunication.h"
#import "AppDelegate.h"

@interface SeeFriendsAttendingTableViewController : UITableViewController <ServerCommunicationDelegate, UIAlertViewDelegate>

@property NSString * fbid_loggedInUser;
@property NSArray * friendsFbidArray;
@property NSMutableArray *listOfAttendingFriends;
//@property NSArray *idListOfAttendingFriends;
@property NSString *eventID;
@property IBOutlet UIActivityIndicatorView *spinner;


@end
