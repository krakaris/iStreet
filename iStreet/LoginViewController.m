//
//  LoginViewController.m
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
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

// Present a loginviewcontroller - called from ServerCommunication. If multiple requests call this method, multiple login view controllers are NOT presented; instead, the caller is added as a delegate, and once the user has successfully logged in, all delegates are informed.
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
    if([sharedLoginViewController.delegates count] > 1)
        NSLog(@"Multiple delegates YAY: %d", [sharedLoginViewController.delegates count]);
    
    if(needToPresent)
        [parentViewController presentModalViewController:sharedLoginViewController animated:YES];
}

// Init the LoginViewController with pre-loaded HTML for the CAS login page
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

// Called when the view has loaded, sets parameters for the webview
- (void)viewDidLoad
{
    [super viewDidLoad];
   
    self.loginWebView.delegate = self;
    self.loginWebView.scalesPageToFit = YES;
    self.loginWebView.scrollView.scrollEnabled = NO;
    
    if(html)
        [self.loginWebView loadHTMLString:html baseURL:[NSURL URLWithString:@"https://fed.princeton.edu/cas/login"]];
}


- (void) webViewDidStartLoad:(UIWebView *)webView
{
    //[(AppDelegate *)[[UIApplication sharedApplication] delegate] useNetworkActivityIndicator];
}

// Called when the webview finishes loading, dismisses and tells delegate if the user has successfully logged in
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
    
    //[(AppDelegate *)[[UIApplication sharedApplication] delegate] stopUsingNetworkActivityIndicator];
}

// Only support portrait orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
