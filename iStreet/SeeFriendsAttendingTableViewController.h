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
#import "IconDownloader.h"

@interface SeeFriendsAttendingTableViewController : UITableViewController <ServerCommunicationDelegate, UIAlertViewDelegate, IconDownloaderDelegate>
{
    dispatch_queue_t downloadFriendsAttendingQ;
    NSMutableDictionary *_iconsBeingDownloaded;
}

@property NSString * fbid_loggedInUser;
@property NSArray * friendsFbidArray;
@property NSMutableArray *listOfAttendingFriends;
//@property NSArray *idListOfAttendingFriends;
@property NSString *eventID;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;


@end
