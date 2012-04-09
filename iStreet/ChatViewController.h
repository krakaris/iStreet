//
//  ChatViewControllerViewController.h
//  iStreet
//
//  Created by Rishi on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UITableViewController <UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITextField *messageText;
    IBOutlet UIButton *sendButton;
    IBOutlet UITableView *messageList;
    
    NSMutableData *receivedData;
    NSMutableArray *messages;
    int lastId;
    //hi
    NSTimer *timer;
    
    NSString *msgAdded;
    NSMutableString *msgUser;
    NSMutableString *msgText;
    int msgId;
    Boolean inText;
    Boolean inUser;
}

@property (nonatomic,retain) UITextField *messageText;
@property (nonatomic,retain) UIButton *sendButton;
@property (nonatomic,retain) UITableView *messageList;

- (IBAction)sendClicked:(id)sender;

@end
