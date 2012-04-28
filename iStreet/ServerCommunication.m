//
//  ServerCommunication.m
//  iStreet
//
//  Created by Rishi on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ServerCommunication.h"
#import "AppDelegate.h"

enum connectionConstants {
    kConnectionTimeout = 8,  
};

@implementation ServerCommunication

@synthesize receivedData, viewController, delegate, serverResponse, description;

- (BOOL)sendAsynchronousRequestForDataAtRelativeURL:(NSString *)rel withPOSTBody:(NSString *)p forViewController:(UIViewController *)vc withDelegate:(id <ServerCommunicationDelegate>)del andDescription:(NSString *)d;
{
    static NSString *serverURL = @"http://localhost:5000";
    //static NSString *serverURL = @"http://istreetsvr.herokuapp.com";
    NSString *absoluteURL = [serverURL stringByAppendingString:rel];
    [self setViewController:vc];
    [self setDescription:d];
    [self setDelegate:del];
    relativeURL = rel;
    post = p;
    
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setTimeoutInterval:kConnectionTimeout];
    [request setURL:[NSURL URLWithString:absoluteURL]];
    
    if(!p)
        [request setHTTPMethod:@"GET"];
    else {
        [request setHTTPMethod:@"POST"];
        NSMutableData *body = [NSMutableData data];
        [body appendData:[p dataUsingEncoding:NSISOLatin1StringEncoding]];
        [request setHTTPBody:body];
    }
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn)
    {
        receivedData = [NSMutableData data];
        return YES;
    }
    else
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        // TELL DELEGATE THE MISSION FAILED.
        return NO;
    }
}


/*
 Runs when the sufficient server response data has been received.
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{  
    [receivedData setLength:0];
    [self setServerResponse:response];
}  

/*
 Runs as the connection loads data from the server.
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data  
{  
    [receivedData appendData:data];
} 

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed (ServerCommunication.m): %@", [error localizedDescription]);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if(self.delegate && [self.delegate respondsToSelector: @selector(connectionFailed::)])
        [self.delegate connectionFailed:description];
}

/*
 Runs when the connection has successfully finished loading all data
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // if CAS Login is required
    if ([[[serverResponse URL] absoluteString] rangeOfString:@"fed.princeton.edu/cas/"].location != NSNotFound) 
    {
        NSLog(@"Requesting new cookie through CAS");
        LoginViewController *lvc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil andHTMLString:[[NSString alloc] initWithData:receivedData encoding:NSISOLatin1StringEncoding] withDelegate:self];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        //LoginViewController *lvc = [[LoginViewController alloc] init];
//        UIWebView *webView = [[UIWebView alloc] initWithFrame:lvc.view.frame];
//        [lvc.view addSubview:webView];
//        lvc.loginWebView = webView;

        [lvc setHtml:[[NSString alloc] initWithData:receivedData encoding:NSISOLatin1StringEncoding]];
        [lvc setDelegate:self];

        lvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self.viewController presentModalViewController:lvc animated:YES];
    }
    else if ([[[serverResponse URL] absoluteString] rangeOfString:@"/login?ticket="].location != NSNotFound)
    {
        // if the server redirected to CAS Login and got an immediate redirect back because of a CAS cookie, 
        NSString *netid = [[[NSString alloc] initWithData:receivedData encoding:NSISOLatin1StringEncoding] substringFromIndex:[@"SUCCESS: " length]];
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] setNetID:netid];
        [self userLoggedIn:self];
    }
    else 
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if(self.delegate && [self.delegate respondsToSelector:@selector(connectionWithDescription:finishedReceivingData:) ])
            [self.delegate connectionWithDescription:description finishedReceivingData:receivedData];
    }
}


- (void)userLoggedIn:(id)sender;
{
    NSLog(@"Successful authentication and cookie recieved! Sending the call again.");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:post forViewController:viewController withDelegate:self.delegate andDescription:description];
}

@end
