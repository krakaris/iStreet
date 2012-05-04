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
#import "ServerCommunication.h"

@interface ClubEventsViewController : UITableViewController <IconDownloaderDelegate, ServerCommunicationDelegate>
{
    //Information we want to get from server    
    NSMutableArray *eventsArray;
   // Event *selectedEvent;
    
    NSMutableData *receivedData;
    NSMutableDictionary *iconsBeingDownloaded;
}

@property(nonatomic, retain) Club *club;

- (void) getServerEventsData;

@end
