//
//  FriendsViewController.m
//  iStreet
//
//  Created by Akarshan Kumar on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendsViewController.h"

@interface FriendsViewController ()

@end

@implementation FriendsViewController

@synthesize fConnectButton;
@synthesize facebook;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    //if ([facebook isSessionValid])
    {
        [facebook requestWithGraphPath:@"me/friends" andDelegate:self];
        NSLog(@"Asking for friends!!");
    }
}

//Not being called - #weird behavior
- (void)fbDidLogin 
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    NSLog(@"defaults just synchronized!");
    [self loggedInLoadFriendsNow];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSLog(@"Did load!");
    
    //doing initial fb setup
    NSLog(@"Initial fb setup");
    if (!facebook)
    {
        NSLog(@"Alloc-ing fb instance if none exists.");
        facebook = [[Facebook alloc] initWithAppId:@"128188007305619" andDelegate:self];
        [facebook setSessionDelegate:self];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)fbconnect:(id)sender
{
    NSLog(@"Did click!");
    if (![facebook isSessionValid]) 
    {
        [facebook authorize:nil];
    }
    
}

- (void) request:(FBRequest *)request didLoad:(id)result
{
    NSLog(@"Received response! Yay!");

    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation 
{
    return [facebook handleOpenURL:url]; 
}


- (void) loggedInLoadFriendsNow
{
    NSLog(@"Guess I'm logged in now!");
}

@end
