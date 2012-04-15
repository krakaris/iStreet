//
//  SecondViewController.h
//  iStreet
//
//  Created by Rishi on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "IconDownloader.h"

@interface EventsViewController : UIViewController <LoginViewControllerDelegate, UIWebViewDelegate, IconDownloaderDelegate>
{
    UITableView *eventsTable;
    UIActivityIndicatorView *activityIndicator;
    
    NSMutableData *receivedData;
    NSMutableArray *eventsByDate; //an array of arrays of events of a given date (considered making this a dictionary (date : events array), but the events must be ordered, which a dictionary is not.
    NSMutableDictionary *iconsBeingDownloaded;
}

// will be moved...
@property (assign) BOOL loggedIn;
@property (nonatomic, retain) NSString *netid;
- (void)screenGotCancelled:(id) sender;

// actual events code
@property(nonatomic, retain) IBOutlet UITableView *eventsTable;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
