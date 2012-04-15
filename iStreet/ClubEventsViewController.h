//
//  ClubEventsViewController.h
//  iStreet
//
//  Created by Alexa Krakaris on 4/9/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Club.h"
#import "EventDetailsViewController.h"

@interface ClubEventsViewController : UITableViewController
{
    //Information we want to get from server
    NSMutableArray *events;
    NSMutableArray *eventImages;
    UITableView *eventsList;
    Event *selectedEvent;
    
    //Not sure if I need these two...
    NSMutableArray *eventTitles;
    NSMutableArray *eventStartDates;
    NSMutableArray *eventStartTimes;
    NSMutableArray *eventEndTimes;
    
    NSMutableData *receivedData;
    
    IBOutlet EventDetailsViewController *edvController;
    
//    NSString *clubName;
//    UIImage *clubCrest;

}

@property(nonatomic, retain) Club *club;
@property (nonatomic, retain) IBOutlet UITableView *eventsList;
@property (nonatomic, retain) NSMutableDictionary *sections;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBarItem;

- (void) getListOfEvents: (NSString *) clubName;

@end
