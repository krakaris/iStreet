//
//  ChatViewControllerViewController.m
//  iStreet
//
//  A little bit of the client-server interaction code is borrowed from Jack D Herrington, Senior Software Engineer, Fortify Software, Inc.
//  http://www.ibm.com/developerworks/library/x-ioschat/index.html
//
// A good deal of the interface code is borrowed from here:
// http://mobile.tutsplus.com/tutorials/iphone/building-a-jabber-client-for-ios-custom-chat-view-and-emoticons/
//
// To be clear, because code was borrowed but customized a good deal, most of the code was written by us. In a sense, the above links were excellent guides in producing this code.


#import "ChatViewController.h"
#import "MessageTableViewCell.h"
#import "Message.h"
#import "AppDelegate.h"

#import <CoreData/CoreData.h>
#import "Club.h"

@interface ChatViewController ()

@end

@implementation ChatViewController

#pragma mark Synthesizing Properties
@synthesize messageField, messagesTable, sendButton, activityIndicator, scrollView;

#pragma mark Setting up the View

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    gettingNewMessages = NO;
    receivedNewMessages = NO;
    
    [activityIndicator startAnimating];
    activityIndicator.hidesWhenStopped = YES;
    
    lastMessageID = 0;
    messages = [[NSMutableArray alloc] init];
    
    messagesTable.dataSource = self;
    messagesTable.delegate = self;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(getNewMessages) userInfo:nil repeats:YES];
    [self getNewMessages];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Receiving Messages

- (void)getNewMessages
{
    if(gettingNewMessages)
        return;
    
    gettingNewMessages = YES;
    
    ServerCommunication *sc = [[ServerCommunication alloc] init];
    if(![sc sendAsynchronousRequestForDataAtRelativeURL:[NSString stringWithFormat:@"/get?past=%d", lastMessageID] withPOSTBody:nil forViewController:self withDelegate:self andDescription:@"get"])
        gettingNewMessages = NO;
}
  
- (void)connectionFailed:(NSString *)description
{
    /* */
}

/*
 Runs when the connection has successfully finished loading all data
 */
- (void)connectionWithDescription:(NSString *)description finishedReceivingData:(NSData *)data
{      
    if([description isEqualToString:@"add"])
    {
        messageField.text = @"";
        [messageField setTextColor:[UIColor blackColor]];
        
        [self getNewMessages];
    }
    else 
    { // get
        
        NSError *error;
        NSArray *messagesArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if(!messagesArray)
        {
            NSLog(@"parsing error: %@", [error localizedDescription]);
            NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding]);
            gettingNewMessages = NO;
            return; // do nothing if can't recieve messages
        }
        
        receivedNewMessages = YES;
        int oldLastID = 0;
        if([messages count] > 0)
        {
            oldLastID = ((Message *)[messages objectAtIndex:([messages count]-1)]).ID;
        }
        
        NSEnumerator *realMessageOrder = [messagesArray reverseObjectEnumerator];
        NSDictionary *dict;
        while (dict = [realMessageOrder nextObject])
        {
            Message *m = [[Message alloc] initWithDictionary:dict];
            [messages addObject:m];
        }
        
        if([messages count] > 0)
            lastMessageID = ((Message *)[messages objectAtIndex:([messages count]-1)]).ID;            
        
        [messagesTable reloadData];
        if(lastMessageID > oldLastID) // if new messages were received, scroll to the new message(s)
            [messagesTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([messages count]-1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        [activityIndicator stopAnimating];
        gettingNewMessages = NO;
    }
}

#pragma mark Sending Messages

- (IBAction)sendClicked:(id)sender 
{   
    // if there is no text, or the message is still sending (i.e. the user double-clicked), don't do anything.
    if ([messageField.text length] == 0 || [activityIndicator isAnimating])
        return;
    
    [messageField setTextColor:[UIColor grayColor]];
    [activityIndicator startAnimating];
    
    NSString *myNetID = [(AppDelegate *)[[UIApplication sharedApplication] delegate] netID];
    
    ServerCommunication *sc = [[ServerCommunication alloc] init];
    [sc sendAsynchronousRequestForDataAtRelativeURL:@"/add" withPOSTBody:[NSString stringWithFormat:@"user_id=%@&message=%@", myNetID, messageField.text] forViewController:self  withDelegate:self andDescription:@"add"];
}

#pragma mark UITableViewController Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CELL_IDENTIFIER = @"message cell";
    MessageTableViewCell *cell = (MessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    
    if (cell == nil) 
    {
        cell = [[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    
    //reversed order: Message *m = [messages objectAtIndex:([messages count] - indexPath.row - 1)];
    Message *m = [messages objectAtIndex:indexPath.row];
    
    [cell packCellWithMessage:m];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    Message *m = [messages objectAtIndex:indexPath.row];
    NSString *msg = [NSString stringWithFormat:@"%@: %@", m.user, m.message];
    
    CGSize maxSize = CGSizeMake(MAX_WIDTH, MAX_HEIGHT);
    CGSize fittedSize = [msg sizeWithFont:[UIFont boldSystemFontOfSize:13]
                  constrainedToSize:maxSize
                      lineBreakMode:UILineBreakModeWordWrap];
    
    fittedSize.height += PADDING * 2 + 10;
    
    CGFloat height = fittedSize.height;
    return height;
    
}

#pragma mark UITableViewController Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [messageField resignFirstResponder];
}

#pragma mark UITextField Delegate

/**
 TO DO: FIX SCROLLING SO THAT THE TABLE VIEW DOESN'T GO OFF THE TOP OF THE SCREEN. THIS IMPORTANT FOR WHEN THERE
 IS ONLY 1 OR 2 MESSAGES.
        FIX RANDOM DUPLICATES BUG.
 
 */

/*
 Shift the tableview, textfield, etc. up to make space for the keyboard.
 */
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    static int TAB_BAR_HEIGHT = 49;
    static int KEYBOARD_HEIGHT = 216;
    CGPoint scrollPoint = CGPointMake(0.0, messageField.frame.origin.y - KEYBOARD_HEIGHT + TAB_BAR_HEIGHT);
    [scrollView setContentOffset:scrollPoint animated:YES];
}

/* 
 If the user hits "Send", send the message
*/
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendClicked:nil];
    return YES;
}

/*
 Shift the tableview, textfield, etc. back down to hide the keyboard.
 */
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [scrollView setContentOffset:CGPointZero animated:YES];   
}

#pragma mark Memory Management

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [timer invalidate];
}



@end
