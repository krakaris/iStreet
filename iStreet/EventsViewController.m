//
//  SecondViewController.m
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//
//  A good deal of the code for synchronously loading event icons in the table cells (and all of the logic) is from Apple's LazyTable sample project. A lot of code was eliminated, however, and several customizations were made.

#import "EventsViewController.h"
#import "EventsNight.h"
#import "EventCell.h"
#import "Event.h"
#import "Event+Accessors.h"
#import "AppDelegate.h"
#import "EventDetailsViewController.h"
#import "ServerCommunication.h"

@interface EventsViewController ()


@end

@implementation EventsViewController

@synthesize activityIndicator = _activityIndicator, eventsTable = _eventsTable, noUpcomingEvents = _noUpcomingEvents;

//Load and set the UI
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(requestServerEventsData)];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor blackColor]];
    
    self.view.backgroundColor = orangeTableColor;
    _eventsTable.backgroundColor = orangeTableColor;
    self.eventsTable.separatorColor = [UIColor blackColor];
    
    _eventsByNight = [NSMutableArray array];
    _iconsBeingDownloaded = [NSMutableDictionary dictionary];
    
    [_activityIndicator startAnimating];
    
    BOOL dataDidLoad = [(AppDelegate *)[[UIApplication sharedApplication] delegate] appDataLoaded];
    
    // If Core Data has not finished loading, register for a notification for when it does. Otherwise, load the data.
    if(!dataDidLoad)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCachedData:) name:DataLoadedNotificationString object:nil];
    else
        [self getCachedData:nil];
}

//Get whatever data is cached in core data and then request information from the server
- (void)getCachedData:(NSNotification *)notification
{    
    if(notification)
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSArray *events = [self getCoreDataEvents];
    
    [self setPropertiesWithNewEventData:events];
    
    [self.eventsTable reloadData];
    [self.activityIndicator stopAnimating];
    
    [self requestServerEventsData];
}

// Get the related events from core data – subclasses must override this method
- (NSArray *)getCoreDataEvents
{
    [NSException raise:@"Must override '- (NSArray *)getCoreDataEvents' in subclass of EventsViewController" format:@""];
    return nil;
}

// Refresh the selected cell in case the user has just "attended" or "unattended" that event in EventDetailsVC
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    NSIndexPath *selectedRow = [self.eventsTable indexPathForSelectedRow];
    if(selectedRow)
    {
        [self.eventsTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
        [self.eventsTable deselectRowAtIndexPath:selectedRow animated:NO];
    }
}

// Restrict orientation to portrait
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark Retrieving Events Data from Server
// Get the related events from the server – subclasses must override this method
- (void)requestServerEventsData
{    
    [NSException raise:@"Must override '- (void)requestServerEventsData' in subclass of EventsViewController" format:@""];
}
// If the connection has failed, notify the user
- (void)connectionFailed:(NSString *)description
{
    if([[self.navigationItem.rightBarButtonItem tintColor] isEqual:[UIColor redColor]])
        return; // if the user already knows connection attempts are failing, don't alert again.
        
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(flashReloadButton:) userInfo:[NSNumber numberWithInt:3] repeats:NO];
    [self flashReloadButton:timer];
}

//Set upper right button that refreshes the page. If no internet connection, button turns red.
- (void)flashReloadButton:(NSTimer *)timer
{
    int current = [(NSNumber *)[timer userInfo] intValue];
    if(current % 2 == 0)
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor blackColor]];
    else
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor redColor]];

    current--;
    if(current > 0)
    {
        [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(flashReloadButton:) userInfo:[NSNumber numberWithInt:current] repeats:NO];
    }
}

// Runs when the connection has successfully finished loading all data
- (void)connectionWithDescription:(NSString *)description finishedReceivingData:(NSData *)data
{
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor blackColor]];

    NSArray *eventsDictionaryArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    if(!eventsDictionaryArray)
        return;
    
    NSMutableArray *eventsArray = [NSMutableArray arrayWithCapacity:[eventsDictionaryArray count]];
    
    for(NSDictionary *dict in eventsDictionaryArray)
    {
        Event *event = [Event eventWithData:dict];
        [eventsArray addObject:event];
    }
    
    [self setPropertiesWithNewEventData:eventsArray];
    [self.eventsTable reloadData];
}

// Update (add and delete) events as necessary
// Important: this method deletes old events that are in core data but that are not retrieved from the server
- (void)setPropertiesWithNewEventData:(NSArray *)newData;
{    
    NSMutableArray *newEventsByNight = [NSMutableArray array];
    
    for(int i = [newData count] - 1; i >= 0; i--)
    {
        Event *event = (Event *)[newData objectAtIndex:i];
        NSString *dateOfEvent = [event stringForStartDate];
        
        //Find the EventsNight in eventsByDate that corresponds to the event
        EventsNight *night = nil;
        for(EventsNight *existingNight in newEventsByNight)
            if([[existingNight date] isEqualToString:dateOfEvent])
                night = existingNight;
        
        //If the EventsNight wasn't found, create a new EventsNight for that date, and add it to eventsByNight
        if(!night)
        {
            night = [[EventsNight alloc] initWithDate:dateOfEvent];
            [newEventsByNight addObject:night];
        }
        
        
        // only add the event if it isn't already contained in the events for that night, and delete the event from the _eventsByNight array
        if(![night.array containsObject:event])
        {
            [night addEvent:event];
            for(EventsNight *oldNight in _eventsByNight)
                if([[oldNight date] isEqualToString:dateOfEvent])
                    [oldNight.array removeObject:event];
        }
    }
    
    [newEventsByNight sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        EventsNight *ea1 = (EventsNight *)obj1;
        EventsNight *ea2 = (EventsNight *)obj2;
        
        return [ea1.date compare:ea2.date];
    }];
    
    NSManagedObjectContext *context = [[(AppDelegate *)[[UIApplication sharedApplication] delegate] document] managedObjectContext];
    
    // delete all leftover events in _eventsByNight, as these are in core data but no longer being returned by the server
    for(EventsNight *oldNight in _eventsByNight)
        for (Event *outdatedEvent in oldNight.array)
        {
            NSLog(@"deleting: '%@', which was on %@", [outdatedEvent title], [outdatedEvent stringForStartDate]);
            [context deleteObject:outdatedEvent];
        }
    
    
    _eventsByNight = newEventsByNight;
    
    if([_eventsByNight count] == 0)
    {
        [self.noUpcomingEvents setHidden:NO];
        [self.eventsTable setHidden:YES];
    }
    else 
    {
        [self.noUpcomingEvents setHidden:YES];
        [self.eventsTable setHidden:NO];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - Table view data source

//Each day will have its own section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{   
    return [_eventsByNight count];
}

//Each section will be populated by the events occuring on that particular date
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    EventsNight *ea = [_eventsByNight objectAtIndex:section];
    return [ea.array count];
}

//Build each cell in the TableView (Mostly UI)
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

// Return the cell height for events
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

//Sets the section header format (Mostly UI purposes)
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
    //Create a new view - size as section header
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 22)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    
    //Place image of section header (from PhotoShop) onto this view
    UIImageView *sectionHeader = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sectionheader.png"]];
    [sectionHeader setFrame:CGRectMake(0, 0, headerView.frame.size.width, headerView.frame.size.height)];
    [headerView addSubview:sectionHeader];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 22)];
    
    EventsNight *ea = [_eventsByNight objectAtIndex:section];
    
    //Format the date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:ea.date];
    [formatter setDateFormat:@"EEEE, MMMM d"];
    NSString *dateString = [formatter stringFromDate:date];
    
    //Set the labels - text and color
    label.text = dateString;
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor orangeColor];
    label.backgroundColor = [UIColor clearColor];
    [label setFont:[UIFont fontWithName:@"Trebuchet MS" size:17.0]];
    
    [headerView addSubview:label];
    
    return headerView;
}

// Get the event at a given index path
- (Event *)eventAtIndexPath:(NSIndexPath *)indexPath
{
    return (Event *)[((EventsNight *)[_eventsByNight objectAtIndex:indexPath.section]).array objectAtIndex:indexPath.row];
}

#pragma mark - Table view delegate

//Navigate to Event Details screen for the given Event at selected cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    Event *selectedEvent = [self eventAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"ShowEventDetails" sender:selectedEvent];    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowEventDetails"])
        [segue.destinationViewController setMyEvent:sender];
}

#pragma mark -
#pragma mark Icon Downloading

//Begin downloading the icons for Event cells
- (void)startIconDownload:(Event *)event forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [_iconsBeingDownloaded objectForKey:indexPath];
    if (iconDownloader) //if there is already a download in progress for that event, return.
        return;
    
    // start the download
    iconDownloader = [[IconDownloader alloc] init];
    [_iconsBeingDownloaded setObject:iconDownloader forKey:indexPath];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://pam.tigerapps.org/media/%@", event.poster]];
    
    [iconDownloader startDownloadFromURL:url forImageKey:@"posterImageData" ofObject:event forDisplayAtIndexPath:indexPath atDelegate:self];
}

// called by our ImageDownloader when an icon is ready to be displayed (i.e. has been associated with its Event)
- (void)iconDidLoad:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.eventsTable cellForRowAtIndexPath:indexPath];
    [(UIActivityIndicatorView *)[cell.contentView viewWithTag:kLoadingIndicatorTag] stopAnimating];
    [self.eventsTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [_iconsBeingDownloaded removeObjectForKey:indexPath];
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

//When scrolling has finished, load images for onscreen rows
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
