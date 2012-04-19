//
//  ClubEventsViewController.m
//  iStreet
//
//  Created by Alexa Krakaris on 4/9/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "ClubEventsViewController.h"
#import "Event.h"
#import "Event+Create.h"
#import "EventCell.h"
#import "EventDetailsViewController.h"
#import "AppDelegate.h"
#import "User.h"

@interface ClubEventsViewController ()

@end

@implementation ClubEventsViewController
@synthesize club, eventsList, activityIndicator;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.club.name;
    
    // Initialize our arrays
    eventsArray = [[NSMutableArray alloc] init];
    iconsBeingDownloaded = [NSMutableDictionary dictionary];
    
    [activityIndicator startAnimating];
    
    NSLog(@"Beginning loading core data.");
    
    UIManagedDocument *document = [(AppDelegate *)[[UIApplication sharedApplication] delegate] document];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"]; 
    request.predicate = [NSPredicate predicateWithFormat:@"name == %@", club.name];
    NSError *error;
    
    NSArray *events = [document.managedObjectContext executeFetchRequest:request error:&error];
    
    [self setPropertiesWithNewEventData:events];
    
    [eventsList reloadData];
    
    NSLog(@"Finished loading core data.");
    
    NSLog(@"Beginning loading web data.");
    
    //Get event data from server
    [self getListOfEvents: club.name];
    [activityIndicator stopAnimating];
}

- (void) getListOfEvents: (NSString *) clubName
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    //Build url for server
    NSString *urlString = 
    [NSString stringWithFormat:
     @"http://istreetsvr.herokuapp.com/clubevents?name=%@", clubName];
    NSString *url = [urlString stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setTimeoutInterval:8];
    [request setURL:[NSURL URLWithString: url]];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn) {
        receivedData = [NSMutableData data];
    } else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    
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
    NSLog(@"Connection finished loading\n");
    NSError *error;
    NSArray *eventsDictionaryArray = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:&error];
    if(!eventsDictionaryArray)
    {
        NSLog(@"%@", [error localizedDescription]);
        return; // do nothing if can't recieve messages
    }
    
    NSMutableArray *eventsTempArray = [NSMutableArray arrayWithCapacity:[eventsDictionaryArray count]];
    
    for(NSDictionary *dict in eventsDictionaryArray)
    {
        Event *e = [Event eventWithData:dict];
        [eventsTempArray addObject:e];
    }
    [self setPropertiesWithNewEventData:eventsTempArray];
    [eventsList reloadData];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
}

- (void)setPropertiesWithNewEventData:(NSArray *)eventData;
{
    eventsArray = [NSMutableArray array];    
    for (int i = 0; i < [eventData count]; i++) {
        Event *e = (Event *)[eventData objectAtIndex:i];
        
        //Determine if eventsArray already contains the event. Else add it
        if (![eventsArray containsObject:e]){
            [eventsArray addObject:e];
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [eventsArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Event *e = [eventsArray objectAtIndex:section];
    
    // Fix start date string
    if (e.time_start && e.time_end) {
        NSString *eventDate = [e.time_start substringToIndex:[e.time_start rangeOfString:@" "].location];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"YYYY-MM-dd"];
        NSDate *sDate = [dateFormat dateFromString:eventDate];
        
        NSDateFormatter *newFormat = [[NSDateFormatter alloc] init];
        [newFormat setDateFormat:@"EEEE, MMMM d"];
        NSString *sTimeString = [newFormat stringFromDate:sDate];
        
        return sTimeString;
    } else {
        return e.title;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"event cell";
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[EventCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    
    // Configure the cell...
    
    Event *event = [eventsArray objectAtIndex: indexPath.section];
    NSString *clubName = event.name;
    
    if ([cell packCellWithEventInformation:event
                               atIndexPath:indexPath
                            whileScrolling:(self.eventsList.dragging == YES 
                                            || self.eventsList.decelerating == YES)]) {
                                [self startIconDownload:event forIndexPath:indexPath];
                            }
    if (event.title) {
        if ([event.title isEqualToString:@""] || [event.title isEqualToString:clubName]) {
            cell.textLabel.text = @"On Tap";
        } else {
            cell.textLabel.text = event.title;
        }
    }
    cell.detailTextLabel.text = [self setSubtitle:event];
    return cell;
}
-(NSString *)setSubtitle:(Event *)event {
    NSString *entry = event.entry;
    NSString *entry_descrip;
    if (event.entry_description) {
        entry_descrip = event.entry_description;
    } else {
        entry_descrip = @"";
    }
    NSString *pass = [NSString stringWithFormat:@"Pa"];
    NSString *puid = [NSString stringWithFormat:@"Pu"];
    NSString *member = [NSString stringWithFormat:@"Mp"];
    NSString *list = [NSString stringWithFormat:@"Gu"];
    NSString *entry_final;
    if ([entry isEqualToString:puid]) {
        entry_final = @"PUID";
    } else if ([entry isEqualToString:pass]) {
        entry_final = @"Pass";
        // Look at description to get color
        if (![entry_descrip isEqualToString:@""]) {
            entry_final = [entry_final stringByAppendingString:@": "];
            entry_final = [entry_final stringByAppendingString:entry_descrip];
        }
    } else if ([entry isEqualToString:member]) {
        entry_final = @"Members plus";
        // Search entry_description for a number: assume it is members + this number
        if (![entry_descrip isEqualToString:@""]) {
            entry_final = [entry_final stringByAppendingString:@" "];
            entry_final = [entry_final stringByAppendingString:entry_descrip];
        }
    } else if ([entry isEqualToString:list]) {
        entry_final = @"Guest List";
    }
    return entry_final;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
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
    UITableViewCell *cell = [self.eventsList cellForRowAtIndexPath:indexPath];
    [(UIActivityIndicatorView *)[cell.contentView viewWithTag:kLoadingIndicatorTag] stopAnimating];
    [eventsList reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
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
    NSArray *visiblePaths = [self.eventsList indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visiblePaths)
    {
        Event *event = [eventsArray objectAtIndex:indexPath.row]; // the event for the cell at that index path
        
        // start downloading the icon if the event doesn't have an icon but has a link to one
        if (!event.posterImageData && ![event.poster isEqualToString:@""])
            [self startIconDownload:event forIndexPath:indexPath];
    }
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // set event based on row selected
    Event *selectedEvent = [eventsArray objectAtIndex: indexPath.section];
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    [self performSegueWithIdentifier:@"ShowEventDetails" sender:selectedEvent];
    
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowEventDetails"])
        [segue.destinationViewController setMyEvent:sender];
}


@end
