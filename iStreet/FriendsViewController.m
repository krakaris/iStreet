//
//  FriendsViewController.m
//  iStreet
//
//  Created by Akarshan Kumar on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendsViewController.h"
#import "FriendsTableViewController.h"

@interface FriendsViewController ()

@end


static NSString *appID = @"128188007305619";

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
    [self.navigationItem setHidesBackButton:YES animated:NO];
    //if ([facebook isSessionValid])
    {

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
    
    if (alreadyLoadedFriends && [facebook isSessionValid])
    {
        [self performSegueWithIdentifier:@"FriendsSegue" sender:self];
    }
    else {
        NSLog(@"Did load!");
        
        //doing initial fb setup
        NSLog(@"Initial fb setup");
        if (!facebook)
        {
            NSLog(@"Alloc-ing fb instance if none exists.");
            facebook = [[Facebook alloc] initWithAppId:appID andDelegate:self];
            self.facebook.sessionDelegate = self;
            //[facebook setSessionDelegate:self];
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if ([defaults objectForKey:@"FBAccessTokenKey"] 
            && [defaults objectForKey:@"FBExpirationDateKey"]) {
            facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
            facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        }
        
        // Now check that the URL scheme fb[app_id]://authorize is in the .plist and can
        // be opened, doing a simple check without local app id factored in here
        NSString *url = [NSString stringWithFormat:@"fb%@://authorize",appID];
        BOOL bSchemeInPlist = NO; // find out if the sceme is in the plist file.
        NSArray* aBundleURLTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
        if ([aBundleURLTypes isKindOfClass:[NSArray class]] &&
            ([aBundleURLTypes count] > 0)) {
            NSDictionary* aBundleURLTypes0 = [aBundleURLTypes objectAtIndex:0];
            if ([aBundleURLTypes0 isKindOfClass:[NSDictionary class]]) {
                NSArray* aBundleURLSchemes = [aBundleURLTypes0 objectForKey:@"CFBundleURLSchemes"];
                if ([aBundleURLSchemes isKindOfClass:[NSArray class]] &&
                    ([aBundleURLSchemes count] > 0)) {
                    NSString *scheme = [aBundleURLSchemes objectAtIndex:0];
                    if ([scheme isKindOfClass:[NSString class]] &&
                        [url hasPrefix:scheme]) {
                        bSchemeInPlist = YES;
                    }
                }
            }
        }
        
        // Check if the authorization callback will work
        BOOL bCanOpenUrl = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString: url]];
        if (!bSchemeInPlist || !bCanOpenUrl) {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Setup Error"
                                      message:@"Invalid or missing URL scheme. You cannot run the app until you set up a valid URL scheme in your .plist."
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil,
                                      nil];
            [alertView show];
        }
        
        [facebook requestWithGraphPath:@"me/friends" andDelegate:self];
        NSLog(@"Asking for friends!!");
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
    else {
        self.fConnectButton.enabled = NO;
        NSLog(@"Valid Session!");
    }
    
}

- (void) request:(FBRequest *)request didLoad:(id)result
{
    //NSLog(@"Received response! Yay! %@", result);
    
  
    NSLog(@"%@", [result objectForKey:@"data"]);

    NSArray *dataWeGot = [result objectForKey:@"data"];
    
    friendsArray = dataWeGot;
    
    alreadyLoadedFriends = YES;
    
    [self performSegueWithIdentifier:@"Friendseg" sender:self];
    
    //NSString *className = NSStringFromClass([dataWeGot class]);
    //NSLog(@"%@", className);
    
    /*for (NSDictionary *user in dataWeGot)
     {
     NSLog(@"%@ and %@", [user valueForKey:@"id"], [user valueForKey:@"name"]);
     }
     */
    
    //FriendsTableViewController *ftvc = [[FriendsTableViewController alloc] init];
    //[self presentModalViewController:ftvc animated:YES];
     
    //NSData *onlyDataString = [result objectForKey:@"data"];
    //NSDictionary *friends = [NSJSONSerialization JSONObjectWithData:onlyDataString options:NSJSONReadingMutableContainers error:nil];
    //NSDictionary *results = [responseString JSONValue];
    
     //NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableContainers error:nil];
     
     //SBJSON *parser = [[SBJSON alloc] init];
     //NSDictionary *allData = (NSDictionary *) [parser objectWithString:result error:nil];
     //NSArray *relevantData = [allData objectForKey:@"data"];
     
     
     //NSData *responseData = result;
     //NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    //SBJsonParser *parser = [SBJsonParser alloc];
    
    //NSData *response = [result objectForKey:@"data"];
    //NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    //NSMutableArray *friends = [json_string JSONValue]; //[parser objectWithString:json_string];
    
    
    //Getting only the friends portion
    //NSString *friendsData = [result objectForKey:@"data"];
    
    //SBJsonParser *parser = [[SBJSON alloc] init];

    //NSMutableArray *myFriends = [parser objectWithString:[result objectForKey:@"data"]];
    //NSDictionary *friendsList = [parser objectWithString:result error:nil];
    
    //NSArray *
    
    //NSArray *friendsList = [parser objectWithString:friendsData error:nil];
    //NSDictionary *jsonContents = [parser objectWithString:result error:nil];
    //NSString friendsData = [jsonContents objectForKey:@"data"];
    
    /*for (NSDictionary *friend in friendsList)
    {
        //NSString *id = [friend objectForKey:@"id"];
        NSLog(@"%@ and %@", [friend objectForKey:@"id"], [friend objectForKey:@"name"]);
    }*/
    
    //[self performSegueWithIdentifier:@"Friendslist" sender:self];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    FriendsTableViewController *ftvc = (FriendsTableViewController *) segue.destinationViewController;
    ftvc.friendslist = friendsArray;
}

     
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.facebook handleOpenURL:url];
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
