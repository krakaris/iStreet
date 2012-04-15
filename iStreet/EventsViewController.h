//
//  SecondViewController.h
//  iStreet
//
//  Created by Rishi on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"

@interface EventsViewController : UIViewController <LoginViewControllerDelegate, UIWebViewDelegate>
{
    UITableView *eventsTable;
    UIActivityIndicatorView *activityIndicator;
    
    NSMutableData *receivedData;
    NSMutableArray *eventsByDate; //an array of arrays of events of a given date
}

// will be moved...
@property (assign) BOOL loggedIn;
@property (nonatomic, retain) NSString *netid;
- (void)screenGotCancelled:(id) sender;

// actual events code
@property(nonatomic, retain) IBOutlet UITableView *eventsTable;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
