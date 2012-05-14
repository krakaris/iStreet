//
//  FriendsViewController.m
//  iStreet
//
//  Created by Akarshan Kumar on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendsViewController.h"
#import "FriendsTableViewController.h"
#import "User+Create.h"

@interface FriendsViewController ()

@end

static NSString *appID = @"128188007305619";

@implementation FriendsViewController

@synthesize fb;
@synthesize fConnectButton;
@synthesize loadingFriendsLabel;
@synthesize spinner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        alreadyLoadedFriends = NO;
    }
    
    return self;
}

//Animate the "Loading Friends.." Label
- (void)animateLoadingFriendsLabel
{
    self.loadingFriendsLabel.hidden = NO;
    
    // Add transition (must be called after myLabel has been displayed)
    CATransition *animation = [CATransition animation];
    animation.duration = 3.0;
    animation.type = kCATransitionMoveIn;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.loadingFriendsLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
    
    // Change the text
    self.loadingFriendsLabel.text = @"Loading Friends..";
}


//fb delegate method - gets called when log in is successful
- (void)fbDidLogin 
{
    NSLog(@"Call to delegate, did log in!");
    self.fConnectButton.enabled = NO;
    [self.spinner startAnimating];
    [self animateLoadingFriendsLabel];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.fb accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[self.fb expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    [(AppDelegate *) [[UIApplication sharedApplication] delegate] setFacebook:self.fb];
    
    //Requesting fb id (then friends, once fbid is received)
    [self.fb requestWithGraphPath:@"me" andDelegate:self];
    NSLog(@"sent the request for fbid");
}


//Function gets called every time ViewController is loaded.
- (void) viewWillAppear:(BOOL)animated
{
    self.fConnectButton.enabled = YES;
    self.loadingFriendsLabel.hidden = YES;
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self.spinner stopAnimating];
    
    //Obtaining global Facebook variable and friends array
    self.fb = [(AppDelegate *)[[UIApplication sharedApplication] delegate] facebook];
    NSArray *allFBfriends = [(AppDelegate *)[[UIApplication sharedApplication] delegate] allfbFriends];

    if ([self.fb isSessionValid]) //if friends isn't empty and session is valid
    {
        self.fConnectButton.enabled = NO;
        
        if ([allFBfriends count] != 0)
        {
            //If friends array isn't empty, load next view controller
            [self performSegueWithIdentifier:@"FriendsSegue" sender:self];
        }
        else
        {
            [self animateLoadingFriendsLabel];
            [self.spinner startAnimating];
            
            //Requesting friends
            [self.fb requestWithGraphPath:@"me/friends?limit=10000&fields=name,id,picture" andDelegate:self];
            NSLog(@"Asking for friends after login!!");
        }
    }
}

//Gets called the first time this view is loaded.
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //Obtaining global variables - Facebook and array of friends
    self.fb = [(AppDelegate *)[[UIApplication sharedApplication] delegate] facebook];
    NSArray *allFBfriends = [(AppDelegate *)[[UIApplication sharedApplication] delegate] allfbFriends];
    
    if (([allFBfriends count] != 0) && [self.fb isSessionValid]) //if friends isn't empty and session is valid
    {
        //NSLog(@"Friends not empty, session valid.");
        
        self.fConnectButton.enabled = YES;
        [self.spinner stopAnimating];
        
        //NSLog(@"Performing viewDidLoad Segue!");
        //friends are loaded and session is valid - push next ViewController containing table of friends
        [self performSegueWithIdentifier:@"FriendsSegue" sender:self];
    }
    else        
    //doing initial fb setup
    {
        NSLog(@"Initial FB setup");
                
        self.fb = [(AppDelegate *)[[UIApplication sharedApplication] delegate] facebook];

        if (!self.fb) //if the facebook object doesn't exist, allocate it.
        {
            self.fb = [[Facebook alloc] initWithAppId:appID andDelegate:self];
            [(AppDelegate *) [[UIApplication sharedApplication] delegate] setFacebook:self.fb]; //setting global variable
        }
        
        
        //Setting defaults in Facebook object from local defaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if ([defaults objectForKey:@"FBAccessTokenKey"] 
            && [defaults objectForKey:@"FBExpirationDateKey"]) 
        {
            self.fb.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
            self.fb.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
            
            //Saving in global
            [(AppDelegate *) [[UIApplication sharedApplication] delegate] setFacebook:self.fb];
        }
        
        
        //Following block of code is to check for robustness, from
        //https://github.com/facebook/facebook-ios-sdk/blob/master/sample/Hackbook/Hackbook/HackbookAppDelegate.m
        
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
        [(AppDelegate *) [[UIApplication sharedApplication] delegate] setFacebook:self.fb];
    }
}

//Delegate method of ServerCommunication - gets called if request is successful
- (void) connectionWithDescription:(NSString *)description finishedReceivingData:(NSData *)data
{    
    if (description == @"updating user with fbid")
    {
        NSLog(@"Done updating user's fbid on server.");
    }
}

//Delegate method of ServerCommunication - gets called if request fails
- (void) connectionFailed:(NSString *)description
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed." message:@"Failed to communicate with server. Please close the app and re-launch." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

//Called when view gets unloaded
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

//Restrict orientation to portrait mode
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//Gets called when user clicks on FConnect button
- (IBAction)fbconnect:(id)sender
{
    self.fb.sessionDelegate = self;
    
    if (![self.fb isSessionValid]) 
    {
        //if session isn't valid, bring up login box
        [self.fb authorize:nil];
    }
    else 
    {
        //disable button
        self.fConnectButton.enabled = NO;

        //Requesting friends
        [self.fb requestWithGraphPath:@"me/friends?limit=10000&fields=name,id,picture" andDelegate:self];
    }
}

//FBRequest Delegate method - called when request fails
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"there was an error in the request!: %@", [error localizedDescription]);
}

//FBRequest Delegate method - called when complete response is received
- (void) request:(FBRequest *)request didLoad:(id)result
{       

    NSLog(@"request loaded, result: %@", result);
    
    if ([request.url isEqualToString:@"https://graph.facebook.com/me"]) //request for fbid
    {
        if (![result isKindOfClass:[NSDictionary class]])   //if result is not a dictionary
        {
            NSLog(@"Not a dictionary, request for fb_id again.");
            
            //Requesting fb id again
            [self.fb requestWithGraphPath:@"me" andDelegate:self];
            NSLog(@"sent the request for fbid again, response was not a dictionary");
        }
        else    //result returned is a dictionary
        {
            NSLog(@"Returned result is a dictionary, This is the request for fb id");
            
            if (result != nil)
            {
                if ([result valueForKey:@"id"])
                {
                    //Calling server method to update user's credentials on server
                    NSString *relativeURL = @"/updateUser";
                    relativeURL = [relativeURL stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];    
                    
                    ServerCommunication *sc = [[ServerCommunication alloc] init];
                    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL
                                                       withPOSTBody:[NSString stringWithFormat:@"fb_id=%@", [result valueForKey:@"id"]] forViewController:self withDelegate:self andDescription:@"updating user with fbid"];
                    
                    //Setting the global variable
                    NSNumber *fbid = [NSNumber numberWithInt:[[result valueForKey:@"id"] intValue]];
                    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setFbID:fbid];
                    NSLog(@"fbid set to %d", [fbid intValue]);
                    
                    userInCoreData = [User userWithNetid:[(AppDelegate *)[[UIApplication sharedApplication] delegate] netID]];
                    
                    //Setting fbid in Core Data
                    if (userInCoreData != nil)
                    {
                        userInCoreData.fb_id = fbid;
                        //NSLog(@"STORED FBID IN CORE DATA DATABASE! fbid is %@", fbid);
                        //[document.managedObjectContext save:nil];
                    }
                    
                    /* Experiment to extract Princeton-only friends */
                    /*
                    NSLog(@"FQL FQL FQL FQL FQL FQL!!!");
                    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    @"SELECT name,uid,pic_square FROM user WHERE uid IN (SELECT uid1 FROM friend WHERE uid2=me()) AND 'Princeton' IN affiliations", @"query",
                                                    nil];
                    [self.fb    requestWithMethodName: @"fql.query"
                                            andParams: params
                                        andHttpMethod: @"POST"
                                          andDelegate: self];
                    */
                    
                    //Now, requesting friends from Facebook
                    [self.fb requestWithGraphPath:@"me/friends?limit=10000&fields=name,id,picture" andDelegate:self];
                }
                else 
                {
                    NSLog(@"No key received.");
                }
            }
        }
    }
    else //this is the request for friends
    {
        if(![result isKindOfClass:[NSDictionary class]])
        {
            NSLog(@"Not a dictionary, request for friends again!");
            
            //Requesting friends from Facebook
            [self.fb requestWithGraphPath:@"me/friends?limit=10000&fields=name,id,picture" andDelegate:self];
            NSLog(@"Asking for friends from Facebook again, due to dictionary error!!");
        }
        else 
        {
            NSLog(@"Returned response is a proper dictionary, this is the request for friends");
            //NSLog(@"result: %@", result);
            
            NSArray *dataWeGot = [result valueForKey:@"data"];
            friendsArray = dataWeGot;
                       
            //Setting global array
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] setAllfbFriends:friendsArray];
                
            // Logging results
            /*
            for (NSDictionary *user in dataWeGot)
            {
                NSLog(@"%@ and %@ and picture is %@, email is %@, education is %@", [user valueForKey:@"id"], [user valueForKey:@"name"], [user valueForKey:@"picture"], [user valueForKey:@"email"], [user valueForKey:@"education"]);
            }
            */
            
            [self.spinner stopAnimating];
            
            NSLog(@"Performing didLoad Segue!");
            [self performSegueWithIdentifier:@"FriendsSegue" sender:self];
        }
    }
}

//Called before the next view controller is pushed - any setup is done here
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSArray *allFBfriends = [(AppDelegate *)[[UIApplication sharedApplication] delegate] allfbFriends];

    FriendsTableViewController *ftvc = (FriendsTableViewController *) segue.destinationViewController;
    
    //Setting array in destination view controller
    if (allFBfriends != 0)
        ftvc.friendslist = (NSMutableArray *) allFBfriends;
    else 
        ftvc.friendslist = (NSMutableArray *) friendsArray;
}

//Method that Facebook calls in this delegate
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.fb handleOpenURL:url];
}

//Method that Facebook calls in this delegate
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation 
{
    return [self.fb handleOpenURL:url]; 
}


//Facebook delegate methods -- These just need to be defined with a minimal body since they are not relevant to this
//ViewController - not defining them results in warnings
//FBSessionDelegate

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
