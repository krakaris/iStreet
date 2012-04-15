//
//  SecondViewController.m
//  iStreet
//
//  Created by Rishi on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  Some of the code for synchronously loading event icons in the table cells (and all of the logic) is from Apple's LazyTable sample project

#import "EventsViewController.h"
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
    
    eventsByDate = [NSMutableArray array];
    iconsBeingDownloaded = [NSMutableDictionary dictionary];
    
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
    TempEvent *event = [ea.array objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:([event.title isEqualToString:@""] ? @"On Tap" : event.title)];
    [cell.detailTextLabel setText:event.name];
    
    if([event.poster isEqualToString:@""])
    {
        NSString *imageName = [NSString stringWithFormat:@"%@.png", event.name];
        cell.imageView.image = [UIImage imageNamed:imageName];                
        return cell;
    }
    
    // Start downloading the icon (unless the table is scrolling), or use it if it's already available
    if (!event.icon)
    {
        if (self.eventsTable.dragging == NO && self.eventsTable.decelerating == NO)
        {
            [self startIconDownload:event forIndexPath:indexPath];
        }
        
        // if a download is deferred or in progress, return a placeholder image
        cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];                
    }
    else
        cell.imageView.image = event.icon;
    
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
}

#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownload:(TempEvent *)event forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [iconsBeingDownloaded objectForKey:indexPath];
    if (iconDownloader == nil) 
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.event = event;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [iconsBeingDownloaded setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
    }
}

// this method is used when the user scrolls into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    NSArray *visiblePaths = [self.eventsTable indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visiblePaths)
    {
        TempEvent *event = [((EventsArray *)[eventsByDate objectAtIndex:indexPath.section]).array objectAtIndex:indexPath.row]; // the event for the cell at that index path
        
        // start downloading the icon if the event doesn't have an icon but has a link to one
        if (!event.icon && ![event.poster isEqualToString:@""])
            [self startIconDownload:event forIndexPath:indexPath];
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    [eventsTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
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
