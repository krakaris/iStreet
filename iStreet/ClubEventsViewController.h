//
//  ClubEventsViewController.h
//  iStreet
//
//  Created by Alexa Krakaris on 4/9/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClubEventsViewController : UITableViewController
{
    //Information we want to get from server
    NSMutableArray *eventTitles;
    NSMutableArray *eventImages;
    NSMutableArray *eventDates;

}

@end
