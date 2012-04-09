//
//  SecondViewController.h
//  iStreet
//
//  Created by Rishi on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"

@interface EventsViewController : UITableViewController <LoginViewControllerDelegate, UIWebViewDelegate>

@property (assign) BOOL loggedIn;
@property (nonatomic, retain) NSString *netid;

- (void) screenGotCancelled:(id) sender;
@end
