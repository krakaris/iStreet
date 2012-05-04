//
//  EventsAttendingTableViewController.h
//  iStreet
//
//  Created by Akarshan Kumar on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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

@interface EventsAttendingTableViewController : UITableViewController <ServerCommunicationDelegate>
{
    
    NSMutableDictionary *iconsBeingDownloaded;
    EventDetailsViewController *eventDetailsController;
    UIButton *starButton;
}

@property (nonatomic, retain) NSString *fbid;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *firstname;
@property (nonatomic, retain) NSArray *nameComponents;
@property (nonatomic, retain) NSArray *eventsAttendingIDs;
@property (nonatomic, retain) NSMutableArray *eligibleEvents;
@property (nonatomic, retain) EventDetailsViewController *eventDetailsController;
@property (nonatomic, retain) Event *currentlySelectedEvent;

@property (nonatomic, retain) IBOutlet UIButton *favButton;

@property (assign) BOOL isStarSelected;
@property (assign) BOOL isAlreadyFavorite;

@end
