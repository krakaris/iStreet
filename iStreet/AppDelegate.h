//
//  AppDelegate.h
//  iStreet
//
//  Created by Rishi on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerCommunication.h"

extern NSString *const DataLoadedNotificationString;

@interface AppDelegate : UIResponder <UIApplicationDelegate, ServerCommunicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (assign) BOOL loggedIn;
@property (nonatomic, retain) NSString *netID;

@property (nonatomic, retain) UINavigationController *navController;

@property (nonatomic, retain) UIManagedDocument *document;
@property (nonatomic, assign) BOOL appDataLoaded;

- (void) screenGotCancelled:(id) sender;

@end
