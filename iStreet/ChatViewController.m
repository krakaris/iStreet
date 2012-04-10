//
//  ChatViewControllerViewController.m
//  iStreet
//
//  Much of the client-server interaction code is by Jack D Herrington, Senior Software Engineer, Fortify Software, Inc.
//  http://www.ibm.com/developerworks/library/x-ioschat/index.html

#import "ChatViewController.h"
#import "Message.h"
#import "SBJson.h"

@interface ChatViewController ()

@end

@implementation ChatViewController
@synthesize messageText, messagesList, sendButton;

#pragma mark Setting up the View

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) 
    {
        lastMessageID = 0;
        messages = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    messagesList.dataSource = self;
    messagesList.delegate = self;
    
    
    timer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(getNewMessages) userInfo:nil repeats:YES];
    [self getNewMessages];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Receiving Messages

- (void)getNewMessages 
{
    NSString *url = [NSString stringWithFormat:@"http://localhost:5000/get?past=%d", lastMessageID];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn)
        receivedData = [NSMutableData data];
    // else do nothing
}

- (void)timerCallback 
{
    [self getNewMessages];
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

/*
 Runs when the connection has successfully finished loading all data
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{      
    // parse and appropriately locate the connection data
    
    [messagesList reloadData];
}

#pragma mark Sending Messages

- (IBAction)sendClicked:(id)sender 
{/*
    [messageText resignFirstResponder];
    if ( [messageText.text length] > 0 ) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSString *url = [NSString stringWithFormat:
                         @"http://localhost:5000/chat/add.php"];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] 
                                        init];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"POST"];
        
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"user=%@&message=%@", 
                           [defaults stringForKey:@"user_preference"], 
                           messageText.text] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
        
        NSHTTPURLResponse *response = nil;
        NSError *error = [[NSError alloc] init];
        [NSURLConnection sendSynchronousRequest:request 
                              returningResponse:&response error:&error];
        
        [self getNewMessages];
    }
    
    messageText.text = @"";*/
}

#pragma mark UITableViewController Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)myTableView numberOfRowsInSection:(NSInteger)section 
{
    return [messages count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:
(NSIndexPath *)indexPath 
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)myTableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UITableViewCell *cell = (UITableViewCell *)[myTableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    Message *m = [messages objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:m.message];
    [cell.detailTextLabel setText:@"User ID will be here"];    
    
    return cell;
}



#pragma mark Memory Management

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

@end
