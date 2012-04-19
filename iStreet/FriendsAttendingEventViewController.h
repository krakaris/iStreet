//
//  FriendsAttendingEventViewController.h
//  iStreet
//
//  Created by Alexa Krakaris on 4/18/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Event.h"


@interface FriendsAttendingEventViewController : UITableViewController
{
    UITableView *friendsTable;
    UIActivityIndicatorView *activityIndicator;
    
    NSMutableDictionary *iconsBeingDownloaded;

}
@property (nonatomic, retain) NSArray *friendsList;
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) User *user;

@end
