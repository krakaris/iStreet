//
//  LoginViewController.m
//  iStreet
//
//  Created by Akarshan Kumar on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "EventsViewController.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize loginWebView, delegate, html;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andHTMLString: (NSString *)markup withDelegate:(id <LoginViewControllerDelegate>)theDelegate
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setHtml:markup];
        [self setDelegate:theDelegate];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"view loaded!");
    // Do any additional setup after loading the view from its nib.
    
    //Declaring itself as the delegate
    self.loginWebView.delegate = self;
    
    self.loginWebView.scalesPageToFit = YES;
    self.loginWebView.scrollView.scrollEnabled = NO;
    //We DON'T want them to scroll down
    
    if(html)
    {
        [self.loginWebView loadHTMLString:html baseURL:[NSURL URLWithString:@"https://fed.princeton.edu/cas/login"]];
    }
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    /*
    NSString *netid;
    
    if ([(AppDelegate *)self.delegate loggedIn] == NO)
    {
        netid = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('username').value;"];
        
        EventsViewController *cvc = (EventsViewController *) self.delegate;
        cvc.netid = netid;
        
        NSLog(@"Net id is this -- %@", netid);
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] setNetID:netid];
        NSLog(@"Bazinga!");
    }
    else {
        NSLog(@"YAMAHA!");
    }
     */
    
}

-(void) webViewDidFinishLoad:(UIWebView *)webView
{
    static NSString *prefix = @"SUCCESS: ";
    int prefixLength = [prefix length];

    NSString *textContent = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.textContent"];
    if([textContent length] >= prefixLength && [[textContent substringToIndex:prefixLength] isEqualToString:prefix])
    {
        NSLog(@"logged in, telling delegate!");
        NSString *netid = [textContent substringFromIndex:prefixLength];
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] setNetID:netid];
        [self.delegate userLoggedIn:self];
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
