//
//  SecondViewController.m
//  iStreet
//
//  Created by Rishi on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  Help for downloading icons asynchronously was received from Apple's LazyTable sample project

#import "EventsViewController.h"
#import "LoginViewController.h"
#import "TempEvent.h"
#import "EventsArray.h"

@interface EventsViewController ()
- (void)getEventsData;
@end

@implementation EventsViewController

@synthesize loggedIn;
@synthesize netid;

@synthesize activityIndicator, eventsTable;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    loggedIn = NO;
    
    eventsByDate = [NSMutableDictionary dictionary];
    
    [self getEventsData];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    loggedIn = YES;
    if (loggedIn != YES)
    {
        NSString *casURL = @"https://fed.princeton.edu/cas/login";
        
        LoginViewController *loginView = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil andURL:[NSURL URLWithString:casURL]];
        
        //LoginViewController *loginView = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil andURL:[NS
        loginView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;   
        loginView.delegate = self;
        
        [self presentModalViewController:loginView animated:YES];
    }
}


- (void) screenGotCancelled:(id) sender
{
    NSLog(@"WHAZOO!");
    loggedIn = YES;
    
    // NSString *netid;
    // netid = self.loginView.
    
    [self dismissModalViewControllerAnimated:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logged In!" message:[NSString stringWithFormat:@"Welcome to iStreet, %@!", self.netid] delegate:self cancelButtonTitle:@"Start!" otherButtonTitles:nil];
    [alert show];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark Receiving Events Data

- (void)getEventsData
{
    [activityIndicator startAnimating];
    NSString *url = @"http://istreetsvr.herokuapp.com/eventslist";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn)
        receivedData = [NSMutableData data];
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
    NSError *error;
    NSArray *eventsArray = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:&error];
    if(!eventsArray)
    {
        NSLog(@"%@", [error localizedDescription]);
        return;
    }
    
    for(NSDictionary *dict in eventsArray)
    {
        
        TempEvent *e = [[TempEvent alloc] initWithDictionary:dict];
        NSString *dateOfEvent = [e.timeStart substringToIndex:[e.timeStart rangeOfString:@" "].location];
        
        //Find the array in eventsByDate that has events on the same date as e
        EventsArray *eventsSameDate = nil;
        for(EventsArray *events in eventsByDate)
            if([[events date] isEqualToString:dateOfEvent])
                eventsSameDate = events;
        
        //If the array wasn't found, create a new array of events for that night.
        if(eventsSameDate == nil)
        {
            eventsSameDate = [[EventsArray alloc] initWithDate:dateOfEvent];
            [eventsByDate addObject:eventsSameDate];
        }
        
        [eventsSameDate addEvent:e];
    }
    
    [eventsByDate sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        EventsArray *ea1 = (EventsArray *)obj1;
        EventsArray *ea2 = (EventsArray *)obj2;
        
        return [ea1.date compare:ea2.date];
    }];
    
    [eventsTable reloadData];
    [activityIndicator stopAnimating];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{    
    return [eventsByDate count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    EventsArray *ea = [eventsByDate objectAtIndex:section];
    return [ea.array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CELL_IDENTIFIER = @"event cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CELL_IDENTIFIER];
    }
    
    // Configure the cell...
    EventsArray *ea = [eventsByDate objectAtIndex:indexPath.section];
    TempEvent *e = [ea.array objectAtIndex:indexPath.row];
    
    // Start downloading the icon (unless the table is scrolling), or use it if it's already available
    if (!e.icon)
    {
        if (self.eventsTable.dragging == NO && self.eventsTable.decelerating == NO)
            [self startIconDownload:appRecord forIndexPath:indexPath];

        // if a download is deferred or in progress, return a placeholder image
        cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];                
    }
    else
        cell.imageView.image = e.icon;

    
    [cell.imageView setImage:[UIImage imageNamed:@"Placeholder.png"]];
    [cell.textLabel setText:([e.title isEqualToString:@""] ? @"On Tap" : e.title)];
    [cell.detailTextLabel setText:e.name];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    EventsArray *ea = [eventsByDate objectAtIndex:section];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:ea.date];
    [formatter setDateFormat:@"MMMM d, yyyy"];
    NSString *dateString = [formatter stringFromDate:date];
    
    return dateString;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownload:(AppRecord *)appRecord forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil) 
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.appRecord = appRecord;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
        [iconDownloader release];   
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([self.entries count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            AppRecord *appRecord = [self.entries objectAtIndex:indexPath.row];
            
            if (!appRecord.appIcon) // avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:appRecord forIndexPath:indexPath];
            }
        }
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
        // Display the newly loaded image
        cell.imageView.image = iconDownloader.appRecord.appIcon;
    }
}


#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

@end
