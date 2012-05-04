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
#import "EventsViewController.h"

@interface ClubEventsViewController : EventsViewController

@property(nonatomic, retain) Club *club;

@end
