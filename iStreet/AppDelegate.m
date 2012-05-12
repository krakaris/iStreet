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

@interface AppDelegate ()
- (void)setupCoreData;
@end

static NSString *appID = @"128188007305619";

@implementation AppDelegate

@synthesize window = _window, netID = _netID, fbID = _fbID, allfbFriends = _allfbFriends, document = _document, appDataLoaded = _appDataLoaded, facebook = _facebook, connectionFailureAlert = _connectionFailureAlert;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [_window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkCoreDataAndSetUpFacebook) name:DataLoadedNotificationString object:nil];
    
    _appDataLoaded = NO;
    _networkActivityIndicatorCount = 0;
    [(UITabBarController *)[_window rootViewController] setDelegate:self];

    // Override point for customization after application launch.
    //UIView *loginWebView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //[self.view presentModalViewController:loginWebView animated:YES completion:^{}];
    //[self.window.subviews.lastObject presentModalViewController:loginWebView animated:YES];
    
#ifdef DEBUG
    NSLog(@"going to sleep for NSFileManager startup (only for simulator)...");
    [NSThread sleepForTimeInterval:3]; 
    NSLog(@"wakie wakie eggs and bakie");
#endif
    
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *dataURL = [[fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    dataURL = [dataURL URLByAppendingPathComponent:@"database"];
    self.document = [[UIManagedDocument alloc] initWithFileURL:dataURL];
    
    if ([fm fileExistsAtPath:[dataURL path]]) 
    {
        [self.document openWithCompletionHandler:^(BOOL success) {
            if (success) 
            {
                NSLog(@"successfully opened database!");
                _appDataLoaded = YES;
                
                // get the user for this netid
                _netID = [[NSUserDefaults standardUserDefaults] objectForKey:@"netid"]; //or nil

                [[NSNotificationCenter defaultCenter] postNotificationName:DataLoadedNotificationString object:self];
            }
            if (!success) 
                NSLog(@"couldn’t open document at %@", [dataURL path]);}]; 
    } 
    else 
    {
        [self.document saveToURL:dataURL forSaveOperation:UIDocumentSaveForCreating
               completionHandler:^(BOOL success) {
                   if (success) 
                       [self setupCoreData];
                   
                   if (!success) 
                       NSLog(@"couldn’t create document at %@", [dataURL path]);}];        
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

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController 
{    
    return !([tabBarController.selectedViewController isEqual:viewController] && tabBarController.selectedIndex == 3);
}

- (void) request:(FBRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Failed!");
}

- (void) requestLoading:(FBRequest *)request
{
    NSLog(@"it's loading!!!");
}

- (void) request:(FBRequest *)request didLoad:(id)result
{
    NSLog(@"request done, request url is %@", request.url);
    
    /*
    if ([request.url isEqualToString:@"https://graph.facebook.com/me"])
    {
        NSLog(@"This is the request for fb id!");
        self.fbID = [result objectForKey:@"id"];
        NSLog(@"fb ID is %@", self.fbID);
    }
    else
     */
    {
        NSLog(@"This is the request for friends!");
        NSArray *friendsDataReceived = [result objectForKey:@"data"];
        //NSLog(friendsDataReceived);
        self.allfbFriends = friendsDataReceived;
        NSLog(@"Friends retrieved in the background, count %d", [self.allfbFriends count]);
    }
}


/*
 Is called the first time that the application runs in order to create the database.
 */
- (void)setupCoreData
{
    NSLog(@"setting up core data...");
    NSLog(@"sending request for clubs list...");
    [[[ServerCommunication alloc] init] sendAsynchronousRequestForDataAtRelativeURL:@"/clubslist" withPOSTBody:nil forViewController:self.window.rootViewController  withDelegate:self andDescription:nil];
}

- (void)connectionFailed:(NSString *)description
{
    NSLog(@"clubs list connection failed");
    if(self.connectionFailureAlert)
        return;
    
    self.connectionFailureAlert = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"There was a problem connecting to our server. Please ensure that your device has internet access, and select \"Okay\" to try again." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [self.connectionFailureAlert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.connectionFailureAlert = nil;   
    
    if(buttonIndex != -1)
        [self setupCoreData];
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
    
    //OR HERE??
    
    //[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:_document.managedObjectContext];
    
    NSLog(@"successfully created database!");  
    _appDataLoaded = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:DataLoadedNotificationString object:self];
 
    //[self checkCoreDataAndSetUpFacebook];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    if(self.connectionFailureAlert)
        [self.connectionFailureAlert dismissWithClickedButtonIndex:-1 animated:NO];
    
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
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //[self checkCoreDataAndSetUpFacebook];
    
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


- (void) checkCoreDataAndSetUpFacebook
{
    NSLog(@"checking core data and set up facebook called!");
    
    //Facebook Initialization
    //Finding the user in the core data database    
    //NSFetchRequest *usersRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    //NSArray *users = [_document.managedObjectContext executeFetchRequest:usersRequest error:nil];
    
    //There should be only 1 user entity - and with matching netid
    
    User *targetUser = [User userWithNetid:_netID];

    /*for (User *user in users)
    {
        NSLog(@"Displaying user info for %@", user.netid);
        if ([self.netID isEqualToString:user.netid])
        {
            targetUser = user;
            NSLog(@"Found target!");
        }
    }*/
    
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
        [self.facebook requestWithGraphPath:@"me/friends?limit=10000&fields=name,id,picture,email,education" andDelegate:self];
        
         dispatch_queue_t downloadFriendsQ = dispatch_queue_create("friends downloader", NULL);
         dispatch_async(downloadFriendsQ, ^{
         });
         dispatch_release(downloadFriendsQ);
         
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.    

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

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

- (void)useNetworkActivityIndicator
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    _networkActivityIndicatorCount++;
}

- (void)stopUsingNetworkActivityIndicator
{
    _networkActivityIndicatorCount--;
    
    if(_networkActivityIndicatorCount < 0)
        _networkActivityIndicatorCount = 0;
    
    if(_networkActivityIndicatorCount == 0)
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

//Facebook delegate methods
//FBSessionDelegate

- (void) fbDidLogin
{
    NSLog(@"FB did log in.");
}

- (void) fbDidLogout
{
    NSLog(@"FB did log out.");
}

- (void) fbSessionInvalidated
{
    NSLog(@"FB Session Invalidated.");
}

- (void) fbDidNotLogin:(BOOL)cancelled
{
    NSLog(@"FB did not login.");
}

- (void) fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt
{
    NSLog(@"FB did extend token.");
}

@end
