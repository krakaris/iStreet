//
//  ChatViewControllerViewController.m
//  iStreet
//
//  Much of the client-server interaction code is by Jack D Herrington, Senior Software Engineer, Fortify Software, Inc.
//  http://www.ibm.com/developerworks/library/x-ioschat/index.html

#import "ChatViewController.h"

@interface ChatViewController ()

@end

@implementation ChatViewController
@synthesize messageText, sendButton, messageList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        lastId = 0;
        //chatParser = NULL;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    messageList.dataSource = self;
    messageList.delegate = self;
    
    [self getNewMessages];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)getNewMessages {
    NSString *url = [NSString stringWithFormat:
                     @"http://localhost:5000/get?past=%d", lastId];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn)
        receivedData = [NSMutableData data];
    else
        ; // do nothing
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{  
    [receivedData setLength:0];
}  

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data  
{  
    [receivedData appendData:data];
}  

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{  
    if (messages == nil)
        messages = [[NSMutableArray alloc] init];
    
    /*
     chatParser = [[NSXMLParser alloc] initWithData:receivedData];
     [chatParser setDelegate:self];
     [chatParser parse];
     
     [receivedData release];
     */
    
    [messageList reloadData];
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                [self methodSignatureForSelector: @selector(timerCallback)]];
    [invocation setTarget:self];
    [invocation setSelector:@selector(timerCallback)];
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0 
                                         invocation:invocation repeats:NO];
}

- (void)timerCallback {
    [self getNewMessages];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)myTableView numberOfRowsInSection:
(NSInteger)section {
    return ( messages == nil ) ? 0 : [messages count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:
(NSIndexPath *)indexPath {
    return 75;
}

- (UITableViewCell *)tableView:(UITableView *)myTableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[myTableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    /*
    [cell.textLabel setText:<#(NSString *)#>]
    
    NSDictionary *itemAtIndex = (NSDictionary *)[messages objectAtIndex:indexPath.row];
    UILabel *textLabel = (UILabel *)[cell viewWithTag:1];
    textLabel.text = [itemAtIndex objectForKey:@"text"];
    UILabel *userLabel = (UILabel *)[cell viewWithTag:2];
    userLabel.text = [itemAtIndex objectForKey:@"user"];
    */
    return cell;
}

- (IBAction)sendClicked:(id)sender {
    [messageText resignFirstResponder];
    if ( [messageText.text length] > 0 ) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSString *url = [NSString stringWithFormat:
                         @"http://localhost/chat/add.php"];
        
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
    
    messageText.text = @"";
}


@end
