//
//  ClubEventsViewController.h
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//

#import <UIKit/UIKit.h>
#import "Club.h"
#import "EventDetailsViewController.h"
#import "IconDownloader.h"
#import "ServerCommunication.h"
#import "EventsViewController.h"

@interface ClubEventsViewController : EventsViewController

@property(nonatomic, retain) NSString *clubName;

@end
