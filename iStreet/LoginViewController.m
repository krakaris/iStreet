//
//  LoginViewController.m
//  iStreet
//
//  Created by Akarshan Kumar on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "ClubsViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize loginWebView;
@synthesize urlToLoad;
@synthesize cancelButton;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andURL: (NSURL *) thisURL
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.urlToLoad = thisURL;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void) webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"Finished Loading!!");
   
    NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    //NSLog(html);
        
    NSString *stringToMatch = @"successfully logged into";
    
    if ([html rangeOfString:stringToMatch].location == NSNotFound)
    {
        NSLog(@"Not found");
    }
    else {
        NSLog(@"Found it!");
        [self.delegate screenGotCancelled:self];
    }
    
    NSLog(webView.request.URL.absoluteString);
    
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    NSString *netid;
    
    if ([(ClubsViewController *)self.delegate loggedIn] == NO)
    {
        netid = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('username').value;"];

        ClubsViewController *cvc = (ClubsViewController *) self.delegate;
        cvc.netid = netid;

        NSLog(@"Net id is this -- %@", netid);
     
        NSLog(@"Bazinga!");
    }
    else {
        NSLog(@"YAMAHA!");
    }
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    //Declaring itself as the delegate
    self.loginWebView.delegate = self;
    
    self.loginWebView.scalesPageToFit = YES;
    self.loginWebView.scrollView.scrollEnabled = NO;
    //We DON'T want them to scroll down
    
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:self.urlToLoad];
    [self.loginWebView loadRequest:req];
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

- (IBAction)cancelThisScreen:(id)sender
{
    NSLog(@"Canceling!!");
    [self.delegate screenGotCancelled:self];
}

@end
