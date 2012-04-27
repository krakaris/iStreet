//
//  ChatViewControllerViewController.h
//  iStreet
//
//  Created by Rishi on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerCommunication.h"
//#import "SBJsonParser.h"

@interface ChatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ServerCommunicationDelegate>
{
    UITextField *messageField;
    UIButton *sendButton;
    UITableView *messagesTable;
    UIActivityIndicatorView *activityIndicator;
    UIScrollView *scrollView;
    
    NSMutableData *receivedData;
    NSMutableArray *messages;
    NSTimer *timer;
    int lastMessageID;
    BOOL gettingNewMessages; // in the process of getting messages (used to prevent duplicate requests)
    BOOL receivedNewMessages; // new messages were received at the last update
    //SBJsonParser *parser;
}

@property (nonatomic, retain) IBOutlet UITextField *messageField;
@property (nonatomic, retain) IBOutlet UIButton *sendButton;
@property (nonatomic, retain) IBOutlet UITableView *messagesTable;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

- (IBAction)sendClicked:(id)sender;
- (void)getNewMessages;

@end
