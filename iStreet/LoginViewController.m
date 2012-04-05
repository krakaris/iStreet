//
//  LoginViewController.m
//  iStreet
//
//  Created by Akarshan Kumar on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"

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
    NSLog(webView.request.URL.absoluteString);
    
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
