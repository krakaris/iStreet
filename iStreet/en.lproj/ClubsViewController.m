//
//  SecondViewController.m
//  iStreet
//
//  Created by Rishi on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ClubsViewController.h"
#import "LoginViewController.h"

@interface ClubsViewController ()

@end

@implementation ClubsViewController

@synthesize loggedIn;
@synthesize netid;

- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    loggedIn = NO;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    if (loggedIn != YES)
    {
    NSString *casURL = @"https://fed.princeton.edu/cas/login";
    
    LoginViewController *loginView = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil andURL:[NSURL URLWithString:casURL]];
    
    //LoginViewController *loginView = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil andURL:[NS
    loginView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;   
    loginView.delegate = self;

    [self presentModalViewController:loginView animated:YES];
    }
}


- (void) screenGotCancelled:(id) sender
{
    NSLog(@"WHAZOO!");
    loggedIn = YES;
    
   // NSString *netid;
   // netid = self.loginView.
    
    [self dismissModalViewControllerAnimated:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logged In!" message:[NSString stringWithFormat:@"Welcome to iStreet, %@!", self.netid] delegate:self cancelButtonTitle:@"Start!" otherButtonTitles:nil];
    [alert show];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
