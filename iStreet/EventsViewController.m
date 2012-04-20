//
//  SecondViewController.m
//  iStreet
//
//  Created by Rishi on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  A good deal of the code for synchronously loading event icons in the table cells (and all of the logic) is from Apple's LazyTable sample project. The IconDownloader.h/.m code is almost completely Apple's. A lot of code was eliminated, however, and several customizations were made.

#import "EventsViewController.h"
#import "EventsNight.h"
#import "EventCell.h"
#import "Event.h"
#import "Event+Create.h"
#import "AppDelegate.h"
#import "EventDetailsViewController.h"

enum eventsViewConstants {
    kConnectionTimeout = 8,  
};

@interface EventsViewController ()
- (void)getServerEventsData;
- (void)loadImagesForOnscreenRows;
/* Probably incomplete */
@end

@implementation EventsViewController

@synthesize loggedIn;
@synthesize netid;

@synthesize activityIndicator, eventsTable;

- (void)viewDidLoad
{
    [super viewDidLoad];
    loggedIn = NO;
    
    eventsByNight = [NSMutableArray array];
    iconsBeingDownloaded = [NSMutableDictionary dictionary];
        
    [activityIndicator startAnimating];
    
    BOOL dataDidLoad = [(AppDelegate *)[[UIApplication sharedApplication] delegate] appDataLoaded];
    
    // If Core Data has not finished loading, register for a notification for when it does. Otherwise, load the data.
    if(!dataDidLoad)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData:) name:DataLoadedNotificationString object:nil];
    else
        [self loadData:nil];
}

- (void)loadData:(NSNotification *)notification
{    
    UIManagedDocument *document = [(AppDelegate *)[[UIApplication sharedApplication] delegate] document];

    if(notification)
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];                    
    NSArray *events = [document.managedObjectContext executeFetchRequest:request error:NULL];
    
    [self setPropertiesWithNewEventData:events];
    
    [eventsTable reloadData];
    [activityIndicator stopAnimating];
    
    [self getServerEventsData];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark Retrieving Events Data from Server

- (void)getServerEventsData
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *url = @"http://istreetsvr.herokuapp.com/eventslist";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setTimeoutInterval:kConnectionTimeout];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn)
        receivedData = [NSMutableData data];
    else
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

/*
 Runs when the connection has successfully finished loading all data
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSArray *eventsDictionaryArray = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:NULL];
    if(!eventsDictionaryArray)
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        return;
    }
    
    NSMutableArray *eventsArray = [NSMutableArray arrayWithCapacity:[eventsDictionaryArray count]];
    
    for(NSDictionary *dict in eventsDictionaryArray)
    {
        Event *event = [Event eventWithData:dict];
        [eventsArray addObject:event];
    }
    
    [self setPropertiesWithNewEventData:eventsArray];
    [eventsTable reloadData];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

// attempting to change this method to work with the current eventsByDate
- (void)setPropertiesWithNewEventData:(NSArray *)eventData;
{
    eventsByNight = [NSMutableArray array];
    for(int i = [eventData count] - 1; i >= 0; i--)
    {
        Event *event = (Event *)[eventData objectAtIndex:i];
        NSString *dateOfEvent = [event.time_start substringToIndex:[event.time_start rangeOfString:@" "].location];
        
        //Find the EventsNight in eventsByDate that corresponds to the event
        EventsNight *night = nil;
        for(EventsNight *existingNight in eventsByNight)
            if([[existingNight date] isEqualToString:dateOfEvent])
                night = existingNight;
        
        //If the EventsNight wasn't found, create a new EventsNight for that date, and add it to eventsByNight
        if(night == nil)
        {
            night = [[EventsNight alloc] initWithDate:dateOfEvent];
            [eventsByNight addObject:night];
        }
        
        [night addEvent:event];
    }
    
    [eventsByNight sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        EventsNight *ea1 = (EventsNight *)obj1;
        EventsNight *ea2 = (EventsNight *)obj2;
        
        return [ea1.date compare:ea2.date];
    }];
    
    eventsByNight = eventsByNight;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{    
    return [eventsByNight count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    EventsNight *ea = [eventsByNight objectAtIndex:section];
    return [ea.array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CELL_IDENTIFIER = @"event cell";
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    if(cell == nil)
        cell = [[EventCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CELL_IDENTIFIER];
    
    // Configure the cell...
        
    Event *event = [self eventAtIndexPath:indexPath];
    
    if([cell packCellWithEventInformation:event 
                           atIndexPath:indexPath 
                        whileScrolling:(self.eventsTable.dragging == YES || self.eventsTable.decelerating == YES)])
        [self startIconDownload:event forIndexPath:indexPath];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    EventsNight *ea = [eventsByNight objectAtIndex:section];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:ea.date];
    [formatter setDateFormat:@"MMMM d, yyyy"];
    NSString *dateString = [formatter stringFromDate:date];
    
    return dateString;
}
//Added by Alexa for section color
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 22)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 22)];
    
    EventsNight *ea = [eventsByNight objectAtIndex:section];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:ea.date];
    [formatter setDateFormat:@"MMMM d, yyyy"];
    NSString *dateString = [formatter stringFromDate:date];
    
    label.text = dateString;
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor orangeColor];
    label.alpha = 0.7;
    [label setFont:[UIFont fontWithName:@"Optima-Bold" size:16.0]];

    [headerView addSubview:label];
    
    return headerView;
}
- (Event *)eventAtIndexPath:(NSIndexPath *)indexPath
{
    return (Event *)[((EventsNight *)[eventsByNight objectAtIndex:indexPath.section]).array objectAtIndex:indexPath.row];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    Event *selectedEvent = [self eventAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"ShowEventDetails" sender:selectedEvent];
    [self.eventsTable deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowEventDetails"])
        [segue.destinationViewController setMyEvent:sender];
}


#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownload:(Event *)event forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [iconsBeingDownloaded objectForKey:indexPath];
    if (iconDownloader == nil) //if there isn't already a download in progress for that event
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.event = event;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [iconsBeingDownloaded setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.eventsTable cellForRowAtIndexPath:indexPath];
    [(UIActivityIndicatorView *)[cell.contentView viewWithTag:kLoadingIndicatorTag] stopAnimating];
    [eventsTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [iconsBeingDownloaded removeObjectForKey:indexPath];
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

// this method is used when the user scrolls into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    NSArray *visiblePaths = [self.eventsTable indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visiblePaths)
    {
        Event *event = [self eventAtIndexPath:indexPath]; // the event for the cell at that index path
        
        // start downloading the icon if the event doesn't have an icon but has a link to one
        if (!event.posterImageData && event.poster && ![event.poster isEqualToString:@""])
            [self startIconDownload:event forIndexPath:indexPath];
    }
}


@end
