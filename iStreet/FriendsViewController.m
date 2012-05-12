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
    if (self) {
        // Custom initialization
        
    }
    
    alreadyLoadedFriends = NO;
    return self;
}

- (void) animateLoadingFriendsLabel
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

//fb delegate method
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
    NSLog(@"defaults just synchronized!");
    
    NSLog(@"access token is %@", [self.fb accessToken]);
    
    //Requesting friends
    [self.fb requestWithGraphPath:@"me/friends?limit=10000&fields=name,id,picture,email,education" andDelegate:self];
    NSLog(@"Asking for friends after login!!");
    
    //Requesting fb id
    [self.fb requestWithGraphPath:@"me" andDelegate:self];
    NSLog(@"sent the request");
}

/*
- (BOOL) tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    NSLog(@"Should select?");
    id nextVC = [(UINavigationController *)viewController topViewController];
    id currentVC = [(UINavigationController *)tabBarController.selectedViewController topViewController];

    if (nextVC != currentVC)
    {
        NSLog(@"They are equal!");
        return YES;
    }
    else 
    {
        NSLog(@"They aren't equal!");
        return NO;
    }
}
*/

- (void) viewWillAppear:(BOOL)animated
{
    NSLog(@"Facebook's viewWillAppear!!");
    self.fConnectButton.enabled = YES;
    self.loadingFriendsLabel.hidden = YES;
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self.spinner stopAnimating];
    self.fb = [(AppDelegate *)[[UIApplication sharedApplication] delegate] facebook];
    NSArray *allFBfriends = [(AppDelegate *)[[UIApplication sharedApplication] delegate] allfbFriends];

    if ([self.fb isSessionValid]) //if friends isn't empty and session is valid
    {
        self.fConnectButton.enabled = NO;
        
        if ([allFBfriends count] != 0)
        {
            NSLog(@"Performing viewWillAppear Segue!");
            [self performSegueWithIdentifier:@"FriendsSegue" sender:self];
        }
        else
        {
            [self animateLoadingFriendsLabel];
            NSLog(@"Spinner starts, requesting friends!");
            [self.spinner startAnimating];
            //Requesting friends
            [self.fb requestWithGraphPath:@"me/friends?limit=10000&fields=name,id,picture,email,education" andDelegate:self];
            NSLog(@"Asking for friends after login!!");
        }
    }
}

- (void)viewDidLoad
{
    NSLog(@"Facebook's viewDidLoad!!");
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //[self.view addSubview:self.spinner];
    //[self.spinner startAnimating];
    
    self.fb = [(AppDelegate *)[[UIApplication sharedApplication] delegate] facebook];
    NSArray *allFBfriends = [(AppDelegate *)[[UIApplication sharedApplication] delegate] allfbFriends];
    
    if (([allFBfriends count] != 0) && [self.fb isSessionValid]) //if friends isn't empty and session is valid
    {
        NSLog(@"Friends not empty, session valid.");
        
        //[self.fConnectButton setHidden:YES];
        self.fConnectButton.enabled = YES;
        [self.spinner stopAnimating];
        
        NSLog(@"Performing viewDidLoad Segue!");
        [self performSegueWithIdentifier:@"FriendsSegue" sender:self];
    }
    else        
    //doing initial fb setup
    {
        NSLog(@"Initial FB setup");
        
        //alreadyLoadedFriends = YES;
        
        self.fb = [(AppDelegate *)[[UIApplication sharedApplication] delegate] facebook];

        if (!self.fb)
        {
            NSLog(@"Improbable, since facebook allocated on app's launch.");
            NSLog(@"Alloc-ing fb instance if none exists.");
            self.fb = [[Facebook alloc] initWithAppId:appID andDelegate:self];
            [(AppDelegate *) [[UIApplication sharedApplication] delegate] setFacebook:self.fb];
            //self.fb.sessionDelegate = self;
        }

        
        //Setting defaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if ([defaults objectForKey:@"FBAccessTokenKey"] 
            && [defaults objectForKey:@"FBExpirationDateKey"]) 
        {
            self.fb.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
            self.fb.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
            
            //Saving in global
            [(AppDelegate *) [[UIApplication sharedApplication] delegate] setFacebook:self.fb];
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
        [(AppDelegate *) [[UIApplication sharedApplication] delegate] setFacebook:self.fb];
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
    NSLog(@"received data! %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    if (description == @"updating user with fbid")
    {
        NSLog(@"Done updating user's fbid on server.");
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

    self.fb.sessionDelegate = self;
    if (![self.fb isSessionValid]) 
    {
        //Setting up permissions
        NSArray *permissions = [[NSArray alloc] initWithObjects:@"email", @"user_education_history", nil];
        [self.fb authorize:permissions];
    }
    else 
    {
        self.fConnectButton.enabled = NO;
        NSLog(@"Valid Session!");

        //Requesting friends
        [self.fb requestWithGraphPath:@"me/friends?limit=10000&fields=name,id,picture,email,education" andDelegate:self];
        NSLog(@"Asking for friends after login!!");
    }
}

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response 
{
    NSLog(@"request:didReceiveResponse:");
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"request:didFailWithError: %@, %d, %@", error.domain, error.code, [error localizedDescription]);
}
- (void) request:(FBRequest *)request didLoad:(id)result
{   
    if([result isKindOfClass:[NSDictionary class]])
    {
        NSLog(@"got back dictionary!");
    }
    else 
    {
        NSLog(@"uh oh...");
        //if request was for fbid, resend request
        //if request was for friends, resend friend request
    }
    
       
    // NS LOG THE REQUEST TYPE
    NSLog(@"request loaded!");
    NSLog(@"result: %@", result);
    if ([request.url isEqualToString:@"https://graph.facebook.com/me"]) //request for fbid
    {
        NSLog(@"This is the request for fb id");
        NSLog(@"access token is %@", [self.fb accessToken]);
        if (result != nil)
        {
            if ([result valueForKey:@"id"])
            {
                NSString *relativeURL = @"/updateUser";
                relativeURL = [relativeURL stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];    
                
                ServerCommunication *sc = [[ServerCommunication alloc] init];
                [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL
                                                   withPOSTBody:[NSString stringWithFormat:@"fb_id=%@", [result valueForKey:@"id"]] forViewController:self withDelegate:self andDescription:@"updating user with fbid"];
                
                //Setting the global variable
                NSString *fbid = [result valueForKey:@"id"];
                [(AppDelegate *)[[UIApplication sharedApplication] delegate] setFbID:fbid];
                NSLog(@"fbid set to %@", fbid);
                
                userInCoreData = [User userWithNetid:[(AppDelegate *)[[UIApplication sharedApplication] delegate] netID]];
                
                //Setting fbid
                if (userInCoreData != nil)
                {
                    userInCoreData.fb_id = fbid;
                    NSLog(@"STORED FBID IN CORE DATA DATABASE! fbid is %@", fbid);
                    //[document.managedObjectContext save:nil];
                }
            }
            else 
            {
                NSLog(@"No key received, handle this case.");
            }
        }
    }
    else 
    {
        NSLog(@"This is the request for friends");

        NSLog(@"result: %@", result);
        NSArray *dataWeGot = [result valueForKey:@"data"];
        friendsArray = dataWeGot;
        
        NSLog(@"Friends received!");
        
        //Setting global array
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] setAllfbFriends:friendsArray];
        
        //alreadyLoadedFriends = YES;
        
        for (NSDictionary *user in dataWeGot)
        {
            
            NSLog(@"%@ and %@ and picture is %@, email is %@, education is %@", [user valueForKey:@"id"], [user valueForKey:@"name"], [user valueForKey:@"picture"], [user valueForKey:@"email"], [user valueForKey:@"education"]);
        }
        
        [self.spinner stopAnimating];
        
        NSLog(@"Performing didLoad Segue!");
        [self performSegueWithIdentifier:@"FriendsSegue" sender:self];
    }
    
    //NSString *className = NSStringFromClass([dataWeGot class]);
    //NSLog(@"%@", className);
    
    /*
    for (NSDictionary *friend in friendsArray)
    {
        NSLog(@"email, education, picture are %@, %@, %@", [friend objectForKey:@"email"], [friend objectForKey:@"education"], [friend objectForKey:@"picture"]);
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
    NSArray *allFBfriends = [(AppDelegate *)[[UIApplication sharedApplication] delegate] allfbFriends];

    FriendsTableViewController *ftvc = (FriendsTableViewController *) segue.destinationViewController;
    
    if (allFBfriends != 0)
        ftvc.friendslist = (NSMutableArray *) allFBfriends;
    else 
        ftvc.friendslist = (NSMutableArray *) friendsArray;
}

     
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.fb handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation 
{
    return [self.fb handleOpenURL:url]; 
}


//Facebook delegate methods
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
