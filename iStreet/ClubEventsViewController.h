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
#import "IconDownloader.h"

@interface ClubEventsViewController : UITableViewController <UIWebViewDelegate, IconDownloaderDelegate>
{
    //Information we want to get from server
    UITableView *eventsList;
    UIActivityIndicatorView *activityIndicator;
    
    NSMutableArray *events;
    Event *selectedEvent;
    
    NSMutableData *receivedData;
    NSMutableDictionary *iconsBeingDownloaded;
    
    IBOutlet EventDetailsViewController *edvController;
    
//    NSString *clubName;
//    UIImage *clubCrest;

}

@property(nonatomic, retain) Club *club;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UITableView *eventsList;
//@property (nonatomic, retain) NSMutableDictionary *sections;

- (void) getListOfEvents: (NSString *) clubName;
- (void) getImageForEvent: (Event *) event;

@end
