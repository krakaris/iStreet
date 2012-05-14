//
//  ChatViewControllerViewController.m
//  iStreet
//
//  A little bit of the client-server interaction code is borrowed from Jack D Herrington, Senior Software Engineer, Fortify Software, Inc.
//  http://www.ibm.com/developerworks/library/x-ioschat/index.html
//
// Some of the interface code is borrowed from here:
// http://mobile.tutsplus.com/tutorials/iphone/building-a-jabber-client-for-ios-custom-chat-view-and-emoticons/
//
// To be clear, because code was borrowed but customized a good deal, most of the code was written by us. In a sense, the above links were excellent guides in producing this code.


#import "ChatViewController.h"
#import "MessageTableViewCell.h"
#import "Message.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreData/CoreData.h>
#import "Club.h"

@interface ChatViewController ()

@end

@implementation ChatViewController

#pragma mark Synthesizing Properties
@synthesize messageField, messagesTable, sendButton, activityIndicator, scrollView, drunkButton;

#pragma mark Setting up the View

// View loaded
- (void)viewDidLoad
{
    [super viewDidLoad];
    drunk = NO;
    [drunkButton setTitle:@"Drunk"];
    lastMessage = nil;
    secondLastMessage = nil;
    
    gettingNewMessages = NO;
    //successfulInitialRequest = NO;
    failedLastRequest = NO;
    
    [activityIndicator startAnimating];
    activityIndicator.hidesWhenStopped = YES;
    
    lastMessageID = 0;
    messages = [[NSMutableArray alloc] init];
    
    messagesTable.dataSource = self;
    messagesTable.delegate = self;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(getNewMessages) userInfo:nil repeats:YES];
    [self getNewMessages];
}

// View appeared – start timer for getting new messages
- (void)viewDidAppear:(BOOL)animated
{
    if (![timer isValid]) 
    {
        timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(getNewMessages) userInfo:nil repeats:YES];
        [self getNewMessages];
    }
}
// View disappeared - stop the timer
- (void)viewDidDisappear:(BOOL)animated
{
    if([timer isValid])
        [timer invalidate];
    timer = nil;
}

// Restrict orientation to portrait
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Receiving Messages

// Get new messages if that is not already being done
- (void)getNewMessages
{
    if(gettingNewMessages)
        return;
    
    gettingNewMessages = YES;
    
    ServerCommunication *sc = [[ServerCommunication alloc] init];
    if(![sc sendAsynchronousRequestForDataAtRelativeURL:[NSString stringWithFormat:@"/get?past=%d", lastMessageID] withPOSTBody:nil forViewController:self withDelegate:self andDescription:@"get"])
        gettingNewMessages = NO;
}

// Handle connection failure with an alert or extra table cell
- (void)connectionFailed:(NSString *)description
{
    if([description isEqualToString:@"add"])
    {
        lastMessage = secondLastMessage;
        secondLastMessage = nil;
        [messageField setUserInteractionEnabled:YES];
        [activityIndicator stopAnimating];
        [messageField setTextColor:[UIColor blackColor]];
        
        [[[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"Whoops! There was a problem sending your message. If the error persists, make sure you are connected to the internet." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
    }
    else 
    { 
        // get
        gettingNewMessages = NO;
        [activityIndicator stopAnimating];
        
        if([timer isValid])
            [timer invalidate];
        
        failedLastRequest = YES;
        [self.messagesTable reloadData];
        [messagesTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messages count] inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

// Runs when the connection has successfully finished loading all data
- (void)connectionWithDescription:(NSString *)description finishedReceivingData:(NSData *)data
{      
    if([description isEqualToString:@"add"])
    {
        messageField.text = @"";

        //erase the message from the field, but don't let the user type more until the message shows up on the screen
        [self getNewMessages];
    }
    else 
    { // get
        [messageField setUserInteractionEnabled:YES];
        [activityIndicator stopAnimating];
        [messageField setTextColor:[UIColor blackColor]];

        NSError *error;
        NSArray *messagesArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if(!messagesArray)
        {
            NSLog(@"parsing error: %@", [error localizedDescription]);
            NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding]);
            gettingNewMessages = NO;
            return; // do nothing if can't recieve messages
        }
        
        //successfulInitialRequest = YES;
        if (failedLastRequest) 
        { // remove the error cell
            failedLastRequest = NO;
            /*[messagesTable reloadData];
            [messagesTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([messages count]-1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];*/
            [self.messagesTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:([messages count]) inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
        failedLastRequest = NO;

        if([messagesArray count] == 0)
        {
            gettingNewMessages = NO;
            return;
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
        [messagesTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([messages count]-1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        [activityIndicator stopAnimating];
        gettingNewMessages = NO;
    }
}

#pragma mark Sending Messages

// The user hit send
- (IBAction)sendClicked:(id)sender 
{   
    // if there is no text, or the message is still sending (i.e. the user double-clicked), don't do anything.
    if ([messageField.text length] == 0 || gettingNewMessages)
        return;
    
    /* Simple spam prevention measures */
    if([messageField.text length] > 90)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Character Limit Exceeded" message:[NSString stringWithFormat:@"Please limit chat messages to\n90 characters in length.\n(Currently using %d)", [messageField.text length]] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSDate *now = [NSDate date];
    if(lastMessage && [now timeIntervalSinceDate:lastMessage] <= 20)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rate Limit" message:[NSString stringWithFormat:@"Please wait 20 seconds between sending chat messages.", [messageField.text length]] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /* Send the message */
    secondLastMessage = lastMessage;
    lastMessage = now;
    [messageField setTextColor:[UIColor grayColor]];
    [messageField setUserInteractionEnabled:NO];
    [activityIndicator startAnimating];
    
    ServerCommunication *sc = [[ServerCommunication alloc] init];
    [sc sendAsynchronousRequestForDataAtRelativeURL:@"/add" withPOSTBody:[NSString stringWithFormat:@"message=%@", messageField.text] forViewController:self  withDelegate:self andDescription:@"add"];
}

// The user hit the drunk/sober button
- (IBAction)toggleDrunk:(id)sender
{
    drunk = !drunk;
    
    if(drunk)
        [drunkButton setTitle:@"Sober"];
    else 
        [drunkButton setTitle:@"Drunk"];
    
    NSIndexPath *bottomRowPath = [[self.messagesTable indexPathsForVisibleRows] lastObject];
    [self.messagesTable reloadData];
    [self.messagesTable scrollToRowAtIndexPath:bottomRowPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

#pragma mark UITableViewController Data Source

// Return number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

// Return number of cells
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    int reloadCell = (failedLastRequest ? 1 : 0);
    return [messages count] + reloadCell;
}

// Return the cell at indexpath
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(failedLastRequest && indexPath.row == [messages count])
    {
        static NSString *RELOAD_CELL_IDENTIFIER = @"reload cell";
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:RELOAD_CELL_IDENTIFIER];
        if (cell == nil) 
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RELOAD_CELL_IDENTIFIER];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
            [cell.textLabel setTextAlignment:UITextAlignmentCenter];
            [cell.textLabel setFont:[UIFont fontWithName:@"TrebuchetMS" size:16]];
            [cell.textLabel setBackgroundColor:[UIColor clearColor]];
            [cell.contentView setBackgroundColor:orangeTableColor];
            [cell.contentView.layer setCornerRadius:10];
            [cell.textLabel setTextColor:[UIColor blackColor]];
            [cell.textLabel setText:@"Failed to retrieve new messages.\nClick here to try again."];
            [cell.textLabel setNumberOfLines:2];
            NSLog(@"making error cell");
        }
        NSLog(@"returning error cell");
        return cell;
    }
       
    static NSString *MESSAGE_CELL_IDENTIFIER = @"message cell";
    MessageTableViewCell *cell = (MessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:MESSAGE_CELL_IDENTIFIER];
    if (cell == nil) 
    {
        cell = [[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MESSAGE_CELL_IDENTIFIER];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    //reversed order: Message *m = [messages objectAtIndex:([messages count] - indexPath.row - 1)];
    Message *m = [messages objectAtIndex:indexPath.row];
    
    [cell packCellWithMessage:m andFont:[self getCurrentFont]];
    
    return cell;
}

// Return the height for the cell at that index path based on the message size (or 50 if it's an error message)
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if(failedLastRequest && indexPath.row == [messages count])
    {
        return 50;
    }
    
    Message *m = [messages objectAtIndex:indexPath.row];
    NSString *msg = [NSString stringWithFormat:@"%@: %@", m.user, m.message];
    
    
    CGSize maxSize = CGSizeMake(MAX_WIDTH, CGFLOAT_MAX);
    CGSize fittedSize = [msg sizeWithFont:[self getCurrentFont]
                  constrainedToSize:maxSize];
    
    fittedSize.height += PADDING * 2 + 10;
    
    return fittedSize.height;
    
}

// Get the current font depending on if the user is drunk or sober
- (UIFont *)getCurrentFont
{
    if (drunk)
        return [UIFont fontWithName:@"TrebuchetMS-Bold" size:16];
    else 
        return [UIFont fontWithName:@"TrebuchetMS" size:13];
}

#pragma mark UITableViewController Delegate

// Hide the keyboard if the user touches the table, and attempt to make a connection again if the error message was selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [messageField resignFirstResponder];
    
    if(failedLastRequest && indexPath.row == [messages count])
    {
        timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(getNewMessages) userInfo:nil repeats:YES];
        [self getNewMessages];
    }
}

#pragma mark UITextField Delegate

// Shift the tableview, textfield, etc. up to make space for the keyboard.
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    static int TAB_BAR_HEIGHT = 49;
    static int KEYBOARD_HEIGHT = 216;
    CGPoint scrollPoint = CGPointMake(0.0, messageField.frame.origin.y - KEYBOARD_HEIGHT + TAB_BAR_HEIGHT);
    [scrollView setContentOffset:scrollPoint animated:YES];
}

// If the user hits "Send" from the keyboard, send the message
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendClicked:nil];
    return YES;
}

// Shift the tableview, textfield, etc. back down to hide the keyboard.
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [scrollView setContentOffset:CGPointZero animated:YES];   
}

#pragma mark Memory Management

// Called when the view is unloaded
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}



@end
