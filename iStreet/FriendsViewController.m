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
@synthesize spinner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    
    alreadyLoadedFriends = NO;
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    /*
    NSString *relativeURL = [NSString stringWithFormat:@"/updateUser"];
    
    ServerCommunication *sc = [[ServerCommunication alloc] init];
    
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:@"fb_id=1186954339" forViewController:self withDelegate:self andDescription:@"updating name"];
    */
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
    [self.spinner startAnimating];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //[self.view addSubview:self.spinner];
    //[self.spinner startAnimating];
    
    //self.facebook = [(AppDelegate *)[[UIApplication sharedApplication] delegate] facebook];
    
    if (alreadyLoadedFriends && [facebook isSessionValid])
    {
        NSLog(@"Already loaded friends is YES!");
        
        [self.fConnectButton setHidden:YES];
        self.fConnectButton.hidden = YES;
        [self.spinner stopAnimating];
        [self performSegueWithIdentifier:@"FriendsSegue" sender:self];
    }
    else        
        //doing initial fb setup
    {
        NSLog(@"Already loaded friends is NO!");
        NSLog(@"Initial fb setup");
        
        alreadyLoadedFriends = YES;
        
        //Facebook *fb = [(AppDelegate *)[[UIApplication sharedApplication] delegate] facebook];
        //facebook;

        if (!facebook)
        {
            NSLog(@"Alloc-ing fb instance if none exists.");
            facebook = [[Facebook alloc] initWithAppId:appID andDelegate:self];
            self.facebook.sessionDelegate = self;
        }
        
        
        //Setting defaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if ([defaults objectForKey:@"FBAccessTokenKey"] 
            && [defaults objectForKey:@"FBExpirationDateKey"]) 
        {
            facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
            facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        }
        
        
        // Now check that the URL scheme fb[app_id]://authorize is in the .plist and can
        // be opened, doing a simple check without local app id factored in here
        NSString *url = [NSString stringWithFormat:@"fb%@://authorize",appID];
        BOOL bSchemeInPlist = NO; // find out if the sceme is in the plist file.
        NSArray* aBundleURLTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
        if ([aBundleURLTypes isKindOfClass:[NSArray class]] &&
            ([aBundleURLTypes count] > 0)) 
        {
            NSDictionary* aBundleURLTypes0 = [aBundleURLTypes objectAtIndex:0];
            if ([aBundleURLTypes0 isKindOfClass:[NSDictionary class]]) 
            {
                NSArray* aBundleURLSchemes = [aBundleURLTypes0 objectForKey:@"CFBundleURLSchemes"];
                if ([aBundleURLSchemes isKindOfClass:[NSArray class]] &&
                    ([aBundleURLSchemes count] > 0)) 
                {
                    NSString *scheme = [aBundleURLSchemes objectAtIndex:0];
                    if ([scheme isKindOfClass:[NSString class]] &&
                        [url hasPrefix:scheme]) 
                    {
                        bSchemeInPlist = YES;
                    }
                }
            }
        }
        
        // Check if the authorization callback will work
        BOOL bCanOpenUrl = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString: url]];
        if (!bSchemeInPlist || !bCanOpenUrl) 
        {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Setup Error"
                                      message:@"Invalid or missing URL scheme. You cannot run the app until you set up a valid URL scheme in your .plist."
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil,
                                      nil];
            [alertView show];
        }
        
        //Setting the global facebook variable to this one
        //[(AppDelegate *)[[UIApplication sharedApplication] delegate] setFacebook:self.facebook];
        
        [facebook requestWithGraphPath:@"me/friends?limit=10000" andDelegate:self];
        NSLog(@"Asking for friends!!");
    }
    
    
    /*
    //#DEBUGGING
    //Build url for server
    
    NSString *relativeURL = [NSString stringWithFormat:@"/attendEvent?fb_id=571438200"];
    relativeURL = [relativeURL stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];    
    
    ServerCommunication *sc = [[ServerCommunication alloc] init];
    
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:@"name=Rishi Narang" forViewController:self withDelegate:self andDescription:@"updating name"];

    //sc = [[ServerCommunication alloc] init];
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:@"event_id=99" forViewController:self withDelegate:self andDescription:@"adding event 99"];
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:@"event_id=88" forViewController:self withDelegate:self andDescription:@"adding event 88"];
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:@"event_id=100" forViewController:self withDelegate:self andDescription:@"adding event 100"];
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:@"event_id=101" forViewController:self withDelegate:self andDescription:@"adding event 101"];
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:@"event_id=71" forViewController:self withDelegate:self andDescription:@"adding event 71"];
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:@"event_id=111" forViewController:self withDelegate:self andDescription:@"adding event 111"];
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:@"event_id=97" forViewController:self withDelegate:self andDescription:@"adding event 97"];

    NSLog(@"user updated!");
     */
}

- (void) connectionWithDescription:(NSString *)description finishedReceivingData:(NSData *)data
{
    NSLog(@"received data!");
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
    //logging JSON string received.
    //NSLog(@"%@", [result objectForKey:@"data"]);

    NSArray *dataWeGot = [result objectForKey:@"data"];
    
    friendsArray = dataWeGot;
    
    //Setting global array
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setAllfbFriends:friendsArray];

    //allFriends = friendsArray;
    
    alreadyLoadedFriends = YES;
    
    [self.spinner stopAnimating];
    [self performSegueWithIdentifier:@"FriendsSegue" sender:self];
    
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
