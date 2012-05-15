//
//  AppDelegate.h
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//

#import <UIKit/UIKit.h>
#import "ServerCommunication.h"
#import "Facebook.h"

extern NSString *const DataLoadedNotificationString;
extern UIColor *orangeTableColor;

@interface AppDelegate : UIResponder <UIApplicationDelegate, ServerCommunicationDelegate, FBRequestDelegate, FBSessionDelegate, UIAlertViewDelegate, UITabBarControllerDelegate>
{
    int _networkActivityIndicatorCount;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSString *netID;
@property (nonatomic, retain) NSNumber *fbID;
@property (nonatomic, retain) NSArray *allfbFriends;
@property (nonatomic, retain) UIManagedDocument *document;
@property (nonatomic, assign) BOOL appDataLoaded;
@property (nonatomic, retain) UIAlertView *connectionFailureAlert;
@property (nonatomic, retain) Facebook *facebook;


// Show the network activity indicator
- (void)useNetworkActivityIndicator;

// Stop using the network activity indicator, but keep showing it if it is being used elsewhere
- (void)stopUsingNetworkActivityIndicator;

// Check core data to see if the user is logged in, and setup Facebook by retrieving friends if so.
- (void)checkCoreDataAndSetUpFacebook;

@end
