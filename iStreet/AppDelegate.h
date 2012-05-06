//
//  AppDelegate.h
//  iStreet
//
//  Created by Rishi on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerCommunication.h"
#import "Facebook.h"

extern NSString *const DataLoadedNotificationString;

@interface AppDelegate : UIResponder <UIApplicationDelegate, ServerCommunicationDelegate, FBRequestDelegate, FBSessionDelegate>
{
    int _networkActivityIndicatorCount;
    Facebook *facebook;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSString *netID;
@property (nonatomic, retain) NSString *fbID;
@property (nonatomic, retain) NSArray *allfbFriends;
@property (nonatomic, retain) UIManagedDocument *document;
@property (nonatomic, assign) BOOL appDataLoaded;

@property (nonatomic, retain) Facebook *facebook;

- (void)useNetworkActivityIndicator;
- (void)stopUsingNetworkActivityIndicator;
- (void)checkCoreDataAndSetUpFacebook;

@end
