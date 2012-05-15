//
//  ChatViewControllerViewController.h
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//

#import <UIKit/UIKit.h>
#import "ServerCommunication.h"

@interface ChatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ServerCommunicationDelegate>
{
    UITextField *messageField;
    UIButton *sendButton;
    UITableView *messagesTable;
    UIActivityIndicatorView *activityIndicator;
    UIScrollView *scrollView;
    NSDate *secondLastMessage;
    NSDate *lastMessage;
    
    NSMutableData *receivedData;
    NSMutableArray *messages;
    NSTimer *timer;
    int lastMessageID;
    BOOL gettingNewMessages; // in the process of getting messages (used to prevent duplicate requests)
    BOOL failedLastRequest;
    BOOL drunk;
}

@property (nonatomic, retain) IBOutlet UITextField *messageField;
@property (nonatomic, retain) IBOutlet UIButton *sendButton;
@property (nonatomic, retain) IBOutlet UITableView *messagesTable;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *drunkButton;

// The user hit send
- (IBAction)sendClicked:(id)sender;

// The user selected the drunk/sober button
- (IBAction)toggleDrunk:(id)sender;

@end
