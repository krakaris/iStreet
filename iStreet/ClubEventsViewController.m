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

@interface ClubEventsViewController ()

@end

@implementation ClubEventsViewController
@synthesize club, eventsList, activityIndicator;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }    
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
    events = [[NSMutableArray alloc] init];
    iconsBeingDownloaded = [NSMutableDictionary dictionary];
       
    //eventsList.dataSource = self;
    //eventsList.delegate = self;
    
    NSLog(@"Beginning loading core data.");
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];   
    // Class code
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"time_start" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    request.predicate = [NSPredicate predicateWithFormat:@"whichClub.name = %@", club.name];
    NSError *error;
    //Not sure we want class code - no way to customize view or sections..
    
    UIManagedDocument *document = [(AppDelegate *)[[UIApplication sharedApplication] delegate] document];
    NSArray *eventsArray = [document.managedObjectContext executeFetchRequest:request error:&error];
    
    
    [eventsList reloadData];
    [activityIndicator stopAnimating];
    NSLog(@"Finished loading core data.");
    NSLog(@"Beginning loading web data.");
    
    //Get event data from server
    [self getListOfEvents: club.name];
    
    //Make sure names are consistent!
    /*
     NSString* imagePath = [[NSBundle mainBundle] pathForResource:club.clubName ofType:@"png"];
     
     club.clubCrest = [[UIImage alloc] initWithContentsOfFile:imagePath];
     */

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    return [events count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    //return [events count];
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Event *e = [events objectAtIndex:section];
    
    // Fix start date string
    NSString *eventDate = [e.time_start substringToIndex:[e.time_start rangeOfString:@" "].location];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd"];
    NSDate *sDate = [dateFormat dateFromString:eventDate];
    
    NSDateFormatter *newFormat = [[NSDateFormatter alloc] init];
    [newFormat setDateFormat:@"EEEE, MMMM d"];
    NSString *sTimeString = [newFormat stringFromDate:sDate];

    return sTimeString;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"event cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[EventCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    // Configure the cell...
    
    Event *event = [events objectAtIndex: indexPath.section];
    
    /*if([cell packCellWithEventInformation:event 
                              atIndexPath:indexPath 
                           whileScrolling:(self.eventsList.dragging == YES || self.eventsList.decelerating == YES)])
        [self startIconDownload:event forIndexPath:indexPath];
    */
    return cell;

    
    
    
    // Format Times appropriately for Subtitle
    /*
     if ([title isEqualToString:@""] || [title isEqualToString:club.name]) {
     event.title = @"On Tap";
     title = @"On Tap";
     }
     
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"HH:mm:ss"];
    NSDate *sTime = [inputFormatter dateFromString:event.startTime];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"h:mm"];
    NSString *sTimeString = [outputFormatter stringFromDate:sTime];
    event.startTime = sTimeString;
    
    NSDate *eTime = [inputFormatter dateFromString:event.endTime];
    NSString *eTimeString = [outputFormatter stringFromDate:eTime];
    event.endTime = eTimeString;
    
    //Hardcoded AM and PM --> FIX!!!
    NSString *timeString = [sTimeString stringByAppendingString:@"pm - "];
    timeString = [timeString stringByAppendingString:eTimeString];
    timeString = [timeString stringByAppendingString:@"am"];
        
    [cell.textLabel setText:title];
    [cell.detailTextLabel setText:timeString];
    return cell;
    */
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
        Event *event = [events objectAtIndex:indexPath.row]; // the event for the cell at that index path
        
        // start downloading the icon if the event doesn't have an icon but has a link to one
        if (!event.posterImageData && ![event.poster isEqualToString:@""])
            [self startIconDownload:event forIndexPath:indexPath];
    }
}


- (void) getListOfEvents: (NSString *) clubName
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    //Build url for server
    NSString *urlString = 
    [NSString stringWithFormat:
     @"http://istreetsvr.herokuapp.com/clubevents?name=%@", clubName];
    //NSURL *url = [NSURL URLWithString:urlString];
    //NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString: urlString]];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    //NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn) {
        receivedData = [NSMutableData data];
    }
    
 //else do nothing

 }

//Rishi Chat code:
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
    NSArray *eventsDictionaryArray = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:&error];
    if(!eventsDictionaryArray)
    {
        NSLog(@"%@", [error localizedDescription]);
        return; // do nothing if can't recieve messages
    }
    
    for(NSDictionary *dict in eventsDictionaryArray)
    {
        Event *e = [Event eventWithData:dict];
        [events addObject:e];
    }
    
    [eventsList reloadData];
    /*
        if (e.title == nil) {
            [e setTitle:@"On Tap"];
        }
        if ([e.event_descrip isEqualToString:@""]) {
            e.event_descrip = @"On Tap";
        }
        e.event_descrip = [e.event_descrip stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
       
        // Fix start date string
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"YYYY-MM-dd"];
        NSDate *sDate = [dateFormat dateFromString:e.startDate];
        
        NSDateFormatter *newFormat = [[NSDateFormatter alloc] init];
        [newFormat setDateFormat:@"EEEE, MMMM d"];
        NSString *sTimeString = [newFormat stringFromDate:sDate];
        e.startDate = sTimeString;
     */
        
}
    
    


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
    
    // set event based on row selected
     selectedEvent = [events objectAtIndex: indexPath.section];
     [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    
    EventDetailsViewController *detailsViewController = [[EventDetailsViewController alloc] initWithNibName:@"EventDetailsViewController" bundle:nil];
    
    detailsViewController.navigationItem.title = selectedEvent.title;
    detailsViewController.myEvent = selectedEvent;
    [self performSegueWithIdentifier:@"ShowEventDetails" sender:self];
    
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowEventDetails"])
    {
        [segue.destinationViewController setMyEvent:selectedEvent];
    }
}


@end
