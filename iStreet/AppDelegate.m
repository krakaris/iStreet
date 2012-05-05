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
#import "User.h"
#import "Event.h"  

NSString *const DataLoadedNotificationString = @"Application data finished loading";

@interface AppDelegate ()
- (void)setupCoreData;
@end

@implementation AppDelegate

@synthesize window = _window, netID = _netID, allfbFriends = _allfbFriends, document = _document, appDataLoaded = _appDataLoaded; //, facebook = _facebook;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [_window makeKeyAndVisible];
    
    _appDataLoaded = NO;
    _networkActivityIndicatorCount = 0;

    // Override point for customization after application launch.
    //UIView *loginWebView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //[self.view presentModalViewController:loginWebView animated:YES completion:^{}];
    //[self.window.subviews.lastObject presentModalViewController:loginWebView animated:YES];
    
    NSLog(@"going to sleep for NSFileManager startup (only for simulator)...");
    [NSThread sleepForTimeInterval:3];
    NSLog(@"wakie wakie eggs and bakie");
    
    
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
                NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
                
                NSError *error;
                NSArray *clubs = [_document.managedObjectContext executeFetchRequest:request error:&error];
                if(clubs)
                {
                    User *thisUser = [clubs objectAtIndex:0];
                    _netID = [thisUser netid];
                }
                
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
    
    return YES;
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
    
    [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:_document.managedObjectContext];
    
    NSLog(@"successfully created database!");  
    _appDataLoaded = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:DataLoadedNotificationString object:self];
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
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
        _netID = netID;
    
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
        User *thisUser = [clubs objectAtIndex:0];
        [thisUser setNetid:_netID];
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

@end
