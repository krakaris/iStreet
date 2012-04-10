//
//  ChatViewControllerViewController.h
//  iStreet
//
//  Created by Rishi on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    UITextField *messageText;
    UIButton *sendButton;
    UITableView *messagesList;
    
    NSMutableData *receivedData;
    NSMutableArray *messages;
    int lastMessageID;
    NSTimer *timer;
    
    NSString *msgAdded;
    NSMutableString *msgUser;
    NSMutableString *msgText;
    int msgId;
    bool inText;
    bool inUser;
}

@property (nonatomic,retain) IBOutlet UITextField *messageText;
@property (nonatomic,retain) IBOutlet UIButton *sendButton;
@property (nonatomic,retain) IBOutlet UITableView *messagesList;

- (IBAction)sendClicked:(id)sender;

@end
