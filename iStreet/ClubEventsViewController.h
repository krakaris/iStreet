//
//  ClubEventsViewController.h
//  iStreet
//
//  Created by Alexa Krakaris on 4/9/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OldClub.h"
#import "EventDetailsViewController.h"

@interface ClubEventsViewController : UITableViewController
{
    //Information we want to get from server
    NSMutableArray *events;
    NSMutableArray *eventImages;
    UITableView *eventsList;
    OldEvent *selectedEvent;
    
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

@property(nonatomic, retain) OldClub *club;
@property (nonatomic, retain) IBOutlet UITableView *eventsList;
@property (nonatomic, retain) NSMutableDictionary *sections;

- (void) getListOfEvents: (NSString *) clubName;
- (void) getImageForEvent: (OldEvent *) event;

@end
