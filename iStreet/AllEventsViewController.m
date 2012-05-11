//
//  AllEventsViewController.m
//  iStreet
//
//  Created by Rishi on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AllEventsViewController.h"
#import "AppDelegate.h"
#import "Event.h"
#import "User+Create.h"

@interface AllEventsViewController ()

@end

@implementation AllEventsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if([(AppDelegate *)[[UIApplication sharedApplication] delegate] appDataLoaded])
    {
        NSLog(@"repeat request");
        [self requestServerEventsData];
    }
}

- (void)logout
{
    ServerCommunication *sc = [[ServerCommunication alloc] init];
    [sc sendAsynchronousRequestForDataAtRelativeURL:@"/logout" withPOSTBody:nil forViewController:self withDelegate:self andDescription:@"logout"];
}

- (NSArray *)getCoreDataEvents
{
    UIManagedDocument *document = [(AppDelegate *)[[UIApplication sharedApplication] delegate] document];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];   
    
    NSArray *events = [document.managedObjectContext executeFetchRequest:request error:NULL];
    
    return events;
}

- (void)requestServerEventsData
{    
    ServerCommunication *sc = [[ServerCommunication alloc] init];
    [sc sendAsynchronousRequestForDataAtRelativeURL:@"/eventslist" withPOSTBody:nil forViewController:self  withDelegate:self andDescription:nil];
}

- (void)connectionWithDescription:(NSString *)description finishedReceivingData:(NSData *)data
{
    if(![description isEqualToString:@"logout"])
    {
        [super connectionWithDescription:description finishedReceivingData:data];
        _serverLoadedOnce = YES;
    }
    else 
    {
        // need aki's code to log out
        if([(AppDelegate *)[[UIApplication sharedApplication] delegate] fbID])
        {
            Facebook *fb = [(AppDelegate *)[[UIApplication sharedApplication] delegate] facebook];
            fb.sessionDelegate = self;
            [fb logout];
        }
        else 
            [self login];
    }
}

- (void) fbDidLogout
{
    NSLog(@"Logged Out!");
    [(AppDelegate *) [[UIApplication sharedApplication] delegate] setAllfbFriends:nil];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setFbID:nil];
    
    //Setting fbid to nil in core data    
    User *targetUser = [User userWithNetid:[(AppDelegate *)[[UIApplication sharedApplication] delegate] netID]];
    
    //Setting fbid
    if (targetUser != nil)
        targetUser.fb_id = nil;
    
    //Clearing user defaults
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:nil forKey:@"FBAccessTokenKey"];
    [prefs setObject:nil forKey:@"FBExpirationDateKey"];
    [prefs synchronize];
    
    //Show alert to confirm logout -- if needed!
    
    //Pop Friends screen to root view controller - taken care of in FriendsTableViewController
    
    [self login];
}

- (void)connectionFailed:(NSString *)description
{
#warning - logout failure?
    if([[self.navigationItem.rightBarButtonItem tintColor] isEqual:[UIColor redColor]])
        return; 
    
    [[[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"There was a problem retrieving the latest event information. If the error persists, make sure you are connected to the internet" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
    
    [super connectionFailed:description];
}

- (void)login
{
    
     [(AppDelegate *)[[UIApplication sharedApplication] delegate] setNetID:nil];
     ServerCommunication *sc = [[ServerCommunication alloc] init];
     [sc sendAsynchronousRequestForDataAtRelativeURL:@"/login" withPOSTBody:nil forViewController:self withDelegate:nil andDescription:@"login"];
}

//Facebook delegate methods
//FBSessionDelegate

- (void) fbDidLogin
{
    NSLog(@"FB did log in.");
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
