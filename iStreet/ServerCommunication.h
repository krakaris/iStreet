//
//  ServerCommunication.h
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//

#import <Foundation/Foundation.h>
#import "LoginViewController.h"

@protocol ServerCommunicationDelegate;

@interface ServerCommunication : NSObject <NSURLConnectionDelegate, LoginViewControllerDelegate>
{    
    // for duplicate call after authentication
    NSString *_relativeURL;
    NSString *_post;
    
    int accessFailCount;
}

@property(nonatomic, retain) NSMutableData *receivedData;
@property(nonatomic, retain) NSURLResponse *serverResponse;
@property(nonatomic, retain) NSString *description;
@property __weak UIViewController *viewController;
@property __weak id <ServerCommunicationDelegate> delegate;



/* Asynchronously send a request for istreetsvr.heroku.com/<url>, and when the data 
 has been received, send it to viewController by calling the delegate method.
 If post is nil, the request will be HTTP GET. If post has a, the request will 
 be HTTP POST, with post as the body of the request. Returns YES if the connection
 was made successfully, or NO otherwise. The description is simply for the caller to differentiate between
 different connections in the same class. May be nil. */
- (BOOL)sendAsynchronousRequestForDataAtRelativeURL:(NSString *)relativeURL withPOSTBody:(NSString *)post forViewController:(UIViewController *)viewController withDelegate:(id <ServerCommunicationDelegate>)delegate andDescription:(NSString *)description;


@end

@protocol ServerCommunicationDelegate <NSObject>

@required
- (void)connectionWithDescription:(NSString *)description finishedReceivingData:(NSData *)data;
@required
- (void)connectionFailed:(NSString *)description;

@end
