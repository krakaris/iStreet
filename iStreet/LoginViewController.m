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
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andHTMLString: (NSString *)h;
@end

@implementation LoginViewController

static LoginViewController *sharedLoginViewController = nil;

@synthesize loginWebView, delegates, html;

+ (void)presentSharedLoginViewControllerWithHTMLString:(NSString *)markup andDelegate:(id <LoginViewControllerDelegate>)delegate inViewController:(UIViewController *)parentViewController;
{
    BOOL needToPresent = NO;
    if (sharedLoginViewController == nil) 
    {
        needToPresent = YES;
        sharedLoginViewController = [[self alloc] initWithNibName:@"LoginViewController" bundle:nil andHTMLString:markup];
        [sharedLoginViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    }
    
    [sharedLoginViewController.delegates addObject:delegate]; 
    
    if(needToPresent)
        [parentViewController presentModalViewController:sharedLoginViewController animated:YES];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andHTMLString: (NSString *)markup
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setHtml:markup];
        [self setDelegates:[NSMutableArray array]];
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
    
    if(html)
    {
        [self.loginWebView loadHTMLString:html baseURL:[NSURL URLWithString:@"https://fed.princeton.edu/cas/login"]];
    }
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] useNetworkActivityIndicator];
}

-(void) webViewDidFinishLoad:(UIWebView *)webView
{
    static NSString *prefix = @"SUCCESS: ";
    int prefixLength = [prefix length];

    NSString *textContent = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.textContent"];
    if([textContent length] >= prefixLength && [[textContent substringToIndex:prefixLength] isEqualToString:prefix])
    {
        NSLog(@"logged in, telling delegates!");
        NSString *netid = [textContent substringFromIndex:prefixLength];
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] setNetID:netid];
        
        for(id <LoginViewControllerDelegate> delegate in self.delegates)
            [delegate userLoggedIn:self];
        
        [self dismissViewControllerAnimated:YES completion:^{sharedLoginViewController = nil;}];
    }    
    
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] stopUsingNetworkActivityIndicator];
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
