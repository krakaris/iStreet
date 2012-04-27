//
//  ServerCommunication.m
//  iStreet
//
//  Created by Rishi on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ServerCommunication.h"

enum connectionConstants {
    kConnectionTimeout = 8,  
};

@implementation ServerCommunication

@synthesize receivedData, viewController, delegate, serverResponse, description;

- (BOOL)sendAsynchronousRequestForDataAtRelativeURL:(NSString *)rel withPOSTBody:(NSString *)p forViewController:(UIViewController *)vc withDelegate:(id <ServerCommunicationDelegate>)del andDescription:(NSString *)d;
{
    //static NSString *serverURL = @"http://localhost:5000";
    static NSString *serverURL = @"http://istreetsvr.herokuapp.com";
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
    NSLog(@"%@", [error localizedDescription]);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if(self.delegate /*&& [self.delegate respondsToSelector: @selector(connectionFailed::)]*/)
        [self.delegate connectionFailed:description];
}

/*
 Runs when the connection has successfully finished loading all data
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // if the url is CAS, log in, and do the connection until it succeeds.
    if ([[[serverResponse URL] absoluteString] rangeOfString:@"fed.princeton.edu/cas/"].location != NSNotFound) 
    {
        NSLog(@"Creating LVC");
        LoginViewController *lvc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil andHTMLString:[[NSString alloc] initWithData:receivedData encoding:NSISOLatin1StringEncoding] withDelegate:self];
        //LoginViewController *lvc = [[LoginViewController alloc] init];
//        UIWebView *webView = [[UIWebView alloc] initWithFrame:lvc.view.frame];
//        [lvc.view addSubview:webView];
//        lvc.loginWebView = webView;

        [lvc setHtml:[[NSString alloc] initWithData:receivedData encoding:NSISOLatin1StringEncoding]];
        [lvc setDelegate:self];

        lvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self.viewController presentModalViewController:lvc animated:YES];
    }
    else 
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        //BOOL shouldSend = [self.delegate respondsToSelector: @selector(connectionWithDescription:finishedReceivingData:)];
        BOOL shouldSend = YES;
        if(self.delegate && shouldSend)
            [self.delegate connectionWithDescription:description finishedReceivingData:receivedData];
    }
}


- (void)userLoggedIn:(id)sender
{
    NSLog(@"duplicate call from delegate!!! HOORAY");
    [self sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:post forViewController:viewController withDelegate:self.delegate andDescription:description];
    NSLog(@"that was it.");
}


/*
- (NSData *)sendSynchronousRequestForDataAtRelativeURL:(NSString *)relativeURL withPOSTBody:(NSString *)post forViewController:(UIViewController <ServerCommunicationDelegate> *)vc
{
    static NSString *serverURL = @"http://localhost:5000";
    NSString *absoluteURL = [serverURL stringByAppendingString:relativeURL];
    [self setViewController:vc];
        
    request = [[NSMutableURLRequest alloc] init];
    [request setTimeoutInterval:kConnectionTimeout];
    [request setURL:[NSURL URLWithString:absoluteURL]];
    
    if(!post)
        [request setHTTPMethod:@"GET"];
    else {
        [request setHTTPMethod:@"POST"];
        NSMutableData *body = [NSMutableData data];
        [body appendData:[post dataUsingEncoding:NSISOLatin1StringEncoding]];
        [request setHTTPBody:body];
    }
    
    NSHTTPURLResponse *response = nil;
    NSError *error = [[NSError alloc] init];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSData *returnedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"%@", [[NSString alloc] initWithData:returnedData encoding:NSISOLatin1StringEncoding]);
    NSLog(@"%@", [response URL]);
    
    // if the url is CAS, log in, and do the connection until it succeeds
    if ([[[response URL] absoluteString] rangeOfString:@"fed.princeton.edu/cas/"].location != NSNotFound) 
    {
        // launch aki's login view controller
        LoginViewController *lvc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil andHTMLString:[[NSString alloc] initWithData:returnedData encoding:NSISOLatin1StringEncoding]];
        lvc.delegate = self;
        lvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self.viewController presentModalViewController:lvc animated:YES];
        return nil;
    }
    else
        return returnedData;
}
*/
@end
