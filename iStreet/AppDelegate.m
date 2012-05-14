//
//  AppDelegate.m
//  iStreet
//
//  Created by Rishi on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
// 

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "Club+Create.h"
#import "Club.h"
#import "User.h"
#import "User+Create.h"
#import "Event.h"  

NSString *const DataLoadedNotificationString = @"Application data finished loading";
NSString *const netIDLoadedNotificationString = @"NetID was just set";
UIColor *orangeTableColor = nil;
#define AUTOMATIC_DISMISS -1


@interface AppDelegate ()
- (void)setupCoreData;
@end

static NSString *appID = @"128188007305619";

@implementation AppDelegate

@synthesize window = _window, netID = _netID, fbID = _fbID, allfbFriends = _allfbFriends, document = _document, appDataLoaded = _appDataLoaded, facebook = _facebook, connectionFailureAlert = _connectionFailureAlert;

// Set global orange table color
+ (void)initialize {
    
    if(!orangeTableColor)
        // These numbers may be perceived as magic numbers – however, it is a well-tested combination RGB combination that we found most to our liking, and we found no logical way to replace the numbers with enums or defines
        orangeTableColor = [[UIColor alloc] initWithRed:255.0/255.0 green:141.0/255.0 blue:17.0/255.0 alpha:1.0];
}

//Set up application for launch. Initialize Core Data document
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [_window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkCoreDataAndSetUpFacebook) name:DataLoadedNotificationString object:nil];
    
    _appDataLoaded = NO;
    _networkActivityIndicatorCount = 0;
    [(UITabBarController *)[_window rootViewController] setDelegate:self];
    
    
    // This code runs only if in DEBUG mode, since the simulator's NSFileManager takes time to startup.
#ifdef DEBUG
    NSLog(@"going to sleep for NSFileManager startup (only for simulator)...");
    [NSThread sleepForTimeInterval:3]; 
    NSLog(@"wakie wakie eggs and bakie");
#endif
    
    //Set up Core Data Document and connect to database
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *dataURL = [[fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    dataURL = [dataURL URLByAppendingPathComponent:@"database"];
    self.document = [[UIManagedDocument alloc] initWithFileURL:dataURL];
    
    // get the user for this netid
    _netID = [[NSUserDefaults standardUserDefaults] objectForKey:@"netid"]; //or nil
    
    if ([fm fileExistsAtPath:[dataURL path]]) 
    {
        [self.document openWithCompletionHandler:^(BOOL success) {
            if (success) 
            {
                NSLog(@"successfully opened database!");
                _appDataLoaded = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:DataLoadedNotificationString object:self];
            }}]; 
    } 
    else 
    {
        [self.document saveToURL:dataURL forSaveOperation:UIDocumentSaveForCreating
               completionHandler:^(BOOL success) {if (success) [self setupCoreData];}];        
    }
    
    //Creating Facebook object
    self.facebook = [[Facebook alloc] initWithAppId:appID andDelegate:self];
    
    //Retrieving values to check if valid session
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        self.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        self.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
        
    return YES;
}

// Generally, a tab bar button goes to the root view controller when clicked when already on that view controller. However, we overrode this behavior so that when a user is on the friends screen and clicks the friends tab, instead of going to the root navigation view controller, nothing happens. This is because the root view controller is the login screen, and not overriding this causes odd behavior where the the root view controller appears and then immediately pushes a new screen.
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController 
{    
    return !([tabBarController.selectedViewController isEqual:viewController] && tabBarController.selectedIndex == 3);
}

// Called when the FB request fails
- (void) request:(FBRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Failed!");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading Friends Failed." message:@"Failed to load friends, possibly due to lack of an internet connection. Please try again later through the Friends tab." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

// Called when the FB request is loading
- (void) requestLoading:(FBRequest *)request
{
    NSLog(@"it's loading!!!");
}

// Called when the FB request for friends loaded.
- (void) request:(FBRequest *)request didLoad:(id)result
{
    NSLog(@"request done, request url is %@", request.url);    
    NSLog(@"This is the request for friends!");
    NSArray *friendsDataReceived = [result objectForKey:@"data"];
    self.allfbFriends = friendsDataReceived;
    NSLog(@"Friends retrieved in the background, count %d", [self.allfbFriends count]);
}


// Called the first time that the application runs in order to create the database.
- (void)setupCoreData
{
    NSLog(@"setting up core data...");
    NSLog(@"sending request for clubs list...");
    [[[ServerCommunication alloc] init] sendAsynchronousRequestForDataAtRelativeURL:@"/clubslist" withPOSTBody:nil forViewController:self.window.rootViewController  withDelegate:self andDescription:nil];
}

- (void)connectionWithDescription:(NSString *)description finishedReceivingData:(NSData *)data
{
    NSLog(@"data recieved!");
    NSArray *clubs = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    // WHAT IF THIS FAILS??
    for (NSDictionary *clubInformation in clubs)
    {
        NSLog(@"%@", [clubInformation objectForKey:@"name"]);
        [Club clubWithData:clubInformation];
    }
    
    NSLog(@"successfully created database!");  
    _appDataLoaded = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:DataLoadedNotificationString object:self];
}

// Called by ServerCommunication when the connection fails
- (void)connectionFailed:(NSString *)description
{
    NSLog(@"clubs list connection failed");
    if(self.connectionFailureAlert)
        return;
    
    self.connectionFailureAlert = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"There was a problem connecting to our server. Please ensure that your device has internet access, and select \"Okay\" to try again." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [self.connectionFailureAlert show];
}

// Called when an alert view (namely the connection failure alert) is dismissed.
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.connectionFailureAlert = nil;   
    
    if(buttonIndex != AUTOMATIC_DISMISS) //
        [self setupCoreData];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Apple's comments:
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Apple's comments:
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    if(self.connectionFailureAlert)
        [self.connectionFailureAlert dismissWithClickedButtonIndex:AUTOMATIC_DISMISS animated:NO];
    
    // if the user closes the application when the database has not been set up, delete it so that it can be properly started next time. this is a special case for when the user is setting up the app first time and there is no internet connection, and the user closes out of the app through multitasking and reopens it.
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Club"];
    NSError *error;
    NSArray *clubs = [_document.managedObjectContext executeFetchRequest:request error:&error];
    if([clubs count] == 0)
    {
        [self.document closeWithCompletionHandler:NULL];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSURL *dataURL = [[fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        dataURL = [dataURL URLByAppendingPathComponent:@"database"];
        [fm removeItemAtURL:dataURL error:NULL];
        NSLog(@"deleting the database :(");
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Apple's comments:
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

    
    //if the database does not exist, set it up. this is a special case for when the user is setting up the app first time and there is no internet connection, and the user closes out of the app through multitasking and reopens it.
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *dataURL = [[fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    dataURL = [dataURL URLByAppendingPathComponent:@"database"];

    if (![fm fileExistsAtPath:[dataURL path]]) 
    {
        self.document = [[UIManagedDocument alloc] initWithFileURL:dataURL];
        [self.document saveToURL:dataURL forSaveOperation:UIDocumentSaveForCreating
               completionHandler:^(BOOL success) {[self setupCoreData];}];        
    }
}

// Check core data to see if the user is logged in, and setup Facebook by retrieving friends if so.
- (void) checkCoreDataAndSetUpFacebook
{
    NSLog(@"checking core data and set up facebook called!");
    
    User *targetUser = [User userWithNetid:_netID];

    NSLog(@"Retrieved fb id FROM CORE DATA is %@", targetUser.fb_id);
    NSLog(@"Access token is %@", self.facebook.accessToken);
    
    if (![self.facebook isSessionValid] || targetUser.fb_id == nil)
    {
        NSLog(@"Session is not valid, nullifying fbid!");
        
        //nullifying fbid
        self.fbID = nil;
        targetUser.fb_id = nil;
        
        //logout if session valid
        if ([self.facebook isSessionValid])
            [self.facebook logout];
    }
    else 
    {
        NSLog(@"FB Session is valid, retrieving friends!");
        //NSLog(@"access token is %@", [self.facebook accessToken]);
        
        //Setting fbid
        if (targetUser != nil)
            self.fbID = targetUser.fb_id;
        
        self.facebook.sessionDelegate = self;
        
        //Just call this the first time - otherwise, friends are refreshed everytime the friends tab is opened
        [self.facebook requestWithGraphPath:@"me/friends?limit=10000&fields=name,id,picture" andDelegate:self];
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Apple's comments:
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.    

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Apple's comments:
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// Set the netid, and enter it into core data if/when core data has loaded
- (void)setNetID:(NSString *)netID
{
    // only set the instance variable if netID is a new netid. netID could be the notification sender.
    if([netID isKindOfClass:[NSString class]])
    {
        _netID = netID;
        [[NSUserDefaults standardUserDefaults] setObject:netID forKey:@"netid"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    
    NSError *error;
    NSArray *clubs = [_document.managedObjectContext executeFetchRequest:request error:&error];
    if(!clubs)
    {
        NSLog(@"%@", [error localizedDescription]);
        return;
    }
    if([clubs count] == 0)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNetID:) name:DataLoadedNotificationString object:self];
        NSLog(@"registering for notification for setting net id");
    }
    else 
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        NSLog(@"setting netid!");
        [User userWithNetid:_netID];
        [self checkCoreDataAndSetUpFacebook];
    }
    
    
}

// Show the network activity indicator
- (void)useNetworkActivityIndicator
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    _networkActivityIndicatorCount++;
}

// Stop using the network activity indicator, but keep showing it if it is being used elsewhere
- (void)stopUsingNetworkActivityIndicator
{
    _networkActivityIndicatorCount--;
    
    if(_networkActivityIndicatorCount < 0)
        _networkActivityIndicatorCount = 0;
    
    if(_networkActivityIndicatorCount == 0)
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

//Facebook delegate methods -- These just need to be defined with a minimal body since they are not relevant to this
//ViewController - not defining them results in warnings
//FBSessionDelegate

- (void) fbDidLogin
{
    //NSLog(@"FB did log in.");
}

- (void) fbDidLogout
{
    //NSLog(@"FB did log out.");
}

- (void) fbSessionInvalidated
{
    //NSLog(@"FB Session Invalidated.");
}

- (void) fbDidNotLogin:(BOOL)cancelled
{
    //NSLog(@"FB did not login.");
}

- (void) fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt
{
    //NSLog(@"FB did extend token.");
}

@end
