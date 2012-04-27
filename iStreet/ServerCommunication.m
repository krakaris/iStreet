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

@synthesize receivedData, viewController;

- (BOOL)sendAsynchronousRequestForDataAtRelativeURL:(NSString *)relativeURL withPOSTBody:(NSString *)post forViewController:(UIViewController <ServerCommunicationDelegate> *)vc
{
    static NSString *serverURL = @"http://istreetsvr.herokuapp.com";
    NSString *absoluteURL = [serverURL stringByAppendingString:relativeURL];
    [self setViewController:vc];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
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
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn)
    {
        receivedData = [NSMutableData data];
        return YES;
    }
    else
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        return NO;
    }
}


/*
 Runs when the sufficient server response data has been received.
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{  
    [receivedData setLength:0];
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
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if(self.viewController)
        [self.viewController connectionFailed];
}

/*
 Runs when the connection has successfully finished loading all data
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if(self.viewController)
        [self.viewController finishedReceivingData:receivedData];
}

- (NSData *)sendSynchronousRequestForDataAtRelativeURL:(NSString *)relativeURL withPOSTBody:(NSString *)post forViewController:(UIViewController <ServerCommunicationDelegate> *)vc
{
    static NSString *serverURL = @"http://istreetsvr.herokuapp.com";
    NSString *absoluteURL = [serverURL stringByAppendingString:relativeURL];
    [self setViewController:vc];
        
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
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
    return returnedData;
}

@end
