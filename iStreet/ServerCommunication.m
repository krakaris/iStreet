//
//  ServerCommunication.m
//  iStreet
//
//  Created by Rishi on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ServerCommunication.h"
#import "AppDelegate.h"
#import <CommonCrypto/CommonDigest.h>

enum connectionConstants {
    kConnectionTimeout = 10,  
};

@interface ServerCommunication()
+ (NSString *)md5HexDigest:(NSString *)input;
@end

@implementation ServerCommunication

@synthesize receivedData, viewController, delegate, serverResponse, description;


- (id)init;
{
    self = [super init];
    accessFailCount = 0;
    
    return self;
}
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
    
    
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] useNetworkActivityIndicator];
    
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
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] stopUsingNetworkActivityIndicator];
        NSLog(@"failed to make connection completely");
        if(self.delegate && [self.delegate respondsToSelector: @selector(connectionFailed:)])
            [self.delegate connectionFailed:description];
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
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] stopUsingNetworkActivityIndicator];
    if(self.delegate && [self.delegate respondsToSelector: @selector(connectionFailed:)])
        [self.delegate connectionFailed:description];
}

/*
 Runs when the connection has successfully finished loading all data
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] stopUsingNetworkActivityIndicator];

    // if CAS Login is required
    if ([[[serverResponse URL] absoluteString] rangeOfString:@"fed.princeton.edu/cas/"].location != NSNotFound) 
    {
        NSLog(@"Requesting new cookie through CAS");
        [LoginViewController presentSharedLoginViewControllerWithHTMLString:[[NSString alloc] initWithData:receivedData encoding:NSISOLatin1StringEncoding] andDelegate:self inViewController:self.viewController];
    }
    else if ([[[serverResponse URL] absoluteString] rangeOfString:@"/login?ticket="].location != NSNotFound)
    {
        // if the server redirected to CAS Login and got an immediate redirect back because of a CAS cookie, 
        NSString *netid = [[[NSString alloc] initWithData:receivedData encoding:NSISOLatin1StringEncoding] substringFromIndex:[@"SUCCESS: " length]];
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] setNetID:netid];
        [self userLoggedIn:self];
    }
    else if ([[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding] isEqualToString:@"Access failed."])
    {
        if(accessFailCount++ < 5)
            [self sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:post forViewController:viewController withDelegate:self.delegate andDescription:description];
        else 
            [self.delegate connectionWithDescription:description finishedReceivingData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else 
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(connectionWithDescription:finishedReceivingData:) ])
            [self.delegate connectionWithDescription:description finishedReceivingData:receivedData];
    }
}


- (void)userLoggedIn:(id)sender;
{
    NSLog(@"Successful authentication and cookie recieved! Sending the call again.");
    [self sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:post forViewController:viewController withDelegate:self.delegate andDescription:description];
}


#pragma mark NSURLConnectionDelegate methods

/*
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSLog(@"for some reason, wrong method called!");
    [self connection:connection sendRequestForAuthenticationChallenge:challenge];
}

 */

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSString *host = [[challenge protectionSpace] host];
    NSLog(@"YOU HAVE BEEN CHALLENGED!: %@", host);
    if(!([host isEqualToString:@"localhost"] || [host isEqualToString:@"istreetsvr.herokuapp.com"]))
    {
        NSLog(@"skipping without credentials");
        [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
        return;
    }
    NSLog(@"using CR credentials");
    if ([challenge previousFailureCount] > 50) 
    {   
        NSLog(@"CANCELLING :(");
        [[challenge sender] cancelAuthenticationChallenge:challenge];
        return;
    }
    
    static NSString *PRIVATE_KEY = @"q{4fI&druS9Rz:)!o@0i";

    NSString *contents = [[challenge protectionSpace] realm]; // of the form "user_message: <challenge_key>"
    NSString *challengeKey = [contents substringFromIndex:([contents rangeOfString:@": "].location + 2)];
    NSString *unencodedResponse = [challengeKey stringByAppendingString:PRIVATE_KEY];
    NSString *encodedResponse = [ServerCommunication md5HexDigest:unencodedResponse];
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:@"" password:encodedResponse persistence:NSURLCredentialPersistenceNone];
    
    [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
}

// From Facebook Connect source code (
+ (NSString *)md5HexDigest:(NSString *)input 
{
    const char *str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);

    NSMutableString *hash = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) 
        [hash appendFormat:@"%02x", result[i]];
    
    return hash;
}

@end
