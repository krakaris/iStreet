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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    NSString *casURL = @"https://fed.princeton.edu/cas/login";
    
    LoginViewController *loginView = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil andURL:[NSURL URLWithString:casURL]];
    
    //LoginViewController *loginView = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil andURL:[NS
    loginView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;   
    loginView.delegate = self;

    [self presentModalViewController:loginView animated:YES];

}

- (void) screenGotCancelled:(id) sender
{
    NSLog(@"WHAZOO!");
    [self dismissModalViewControllerAnimated:YES];
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
