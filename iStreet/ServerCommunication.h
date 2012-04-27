//
//  ServerCommunication.h
//  iStreet
//
//  Created by Rishi on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServerCommunicationDelegate;

@interface ServerCommunication : NSObject <NSURLConnectionDelegate>
{
    NSMutableData *receivedData;
}

@property __weak UIViewController <ServerCommunicationDelegate> *viewController;
@property(nonatomic, retain) NSMutableData *receivedData;


/* Asynchronously send a request for istreetsvr.heroku.com/<url>, and when the data 
 has been received, send it to viewController by calling the delegate method.
 If post is nil, the request will be HTTP GET. If post has a, the request will 
 be HTTP POST, with post as the body of the request. Returns YES if the connection
 was made successfully, or NO otherwise. */
- (BOOL)sendAsynchronousRequestForDataAtRelativeURL:(NSString *)relativeURL withPOSTBody:(NSString *)post forViewController:(UIViewController <ServerCommunicationDelegate> *)viewController;

/* Synchronously send a request for istreetsvr.heroku.com/<url>, and when the data 
 has been received, send it to viewController by calling the delegate method.
 If post is nil, the request will be HTTP GET. If post has a, the request will 
 be HTTP POST, with post as the body of the request. Returns YES if the connection
 was made successfully, or NO otherwise. */
- (NSData *)sendSynchronousRequestForDataAtRelativeURL:(NSString *)relativeURL withPOSTBody:(NSString *)post forViewController:(UIViewController <ServerCommunicationDelegate> *)viewController;


@end

@protocol ServerCommunicationDelegate

@optional
- (void)finishedReceivingData:(NSData *)data;
@optional
- (void)connectionFailed;

@end
