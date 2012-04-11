//
//  ClubEventsViewController.h
//  iStreet
//
//  Created by Alexa Krakaris on 4/9/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Club.h"

@interface ClubEventsViewController : UITableViewController
{
    //Information we want to get from server
    NSMutableArray *events;
    NSMutableArray *eventImages;
    
    //Not sure if I need these two...
    NSMutableArray *eventTitles;
    NSMutableArray *eventDates;
    
    NSMutableData *receivedData;
    
//    NSString *clubName;
//    UIImage *clubCrest;

}

@property(nonatomic) Club *club;

@end
