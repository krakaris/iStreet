//
//  EventsAttendingTableViewController.h
//  iStreet
//
//  Created by Akarshan Kumar on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerCommunication.h"

@interface EventsAttendingTableViewController : UITableViewController <ServerCommunicationDelegate>

@property (nonatomic, retain) NSString *fbid;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *firstname;
@property (nonatomic, retain) NSArray *nameComponents;
@property (nonatomic, retain) NSArray *eventsAttending;

@end
