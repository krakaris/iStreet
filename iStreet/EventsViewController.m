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
#import "ServerCommunication.h"

@interface EventsViewController ()
- (void)requestServerEventsData;
- (void)loadImagesForOnscreenRows;
/* Probably incomplete */
@end

@implementation EventsViewController

@synthesize activityIndicator = _activityIndicator, eventsTable = _eventsTable, noUpcomingEvents = _noUpcomingEvents;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(requestServerEventsData)];
    
    self.view.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:150.0/255.0 blue:50.0/255.0 alpha:1.0];
    _eventsTable.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:150.0/255.0 blue:50.0/255.0 alpha:1.0];
    //[UIColor colorWithRed:255.0/255.0 green:179.0/255.0 blue:76.0/255.0 alpha:1.0];
    self.eventsTable.separatorColor = [UIColor blackColor];
    
    _eventsByNight = [NSMutableArray array];
    _iconsBeingDownloaded = [NSMutableDictionary dictionary];
    
    self.eventsTable.separatorColor = [UIColor blackColor]; 
    
    [_activityIndicator startAnimating];
    
    BOOL dataDidLoad = [(AppDelegate *)[[UIApplication sharedApplication] delegate] appDataLoaded];
    
    // If Core Data has not finished loading, register for a notification for when it does. Otherwise, load the data.
    if(!dataDidLoad)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCachedData:) name:DataLoadedNotificationString object:nil];
    else
        [self getCachedData:nil];    
}

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

- (NSArray *)getCoreDataEvents
{
    [NSException raise:@"Must override '- (NSArray *)getCoreDataEvents' in subclass of EventsViewController" format:@""];
    return nil;
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    NSIndexPath *selectedRow = [self.eventsTable indexPathForSelectedRow];
    if(selectedRow)
    {
        [self.eventsTable deselectRowAtIndexPath:selectedRow animated:NO];
        [self.eventsTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark Retrieving Events Data from Server

- (void)requestServerEventsData
{    
    [NSException raise:@"Must override '- (void)requestServerEventsData' in subclass of EventsViewController" format:@""];
}

/*
 Runs when the connection has successfully finished loading all data
 */
- (void)connectionWithDescription:(NSString *)description finishedReceivingData:(NSData *)data
{
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

// attempting to change this method to work with the current eventsByDate
- (void)setPropertiesWithNewEventData:(NSArray *)newData;
{
    //if an event is in _eventsByNight but not in newData, that event should be deleted (i.e. it is past that date, or the event was deleted from the server's database
    
    NSMutableArray *newEventsByNight = [NSMutableArray array];
    
    for(int i = [newData count] - 1; i >= 0; i--)
    {
        Event *event = (Event *)[newData objectAtIndex:i];
        NSString *dateOfEvent = [event.time_start substringToIndex:[event.time_start rangeOfString:@" "].location];
        
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
    
    // delete all leftover events in _eventsByNight
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

- (NSArray *)constructEventsNightArrayFromEventsArray:(NSArray *)eventsArray
{
    return eventsArray;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{   
    return [_eventsByNight count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    EventsNight *ea = [_eventsByNight objectAtIndex:section];
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

//Added by Alexa for section color
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 22)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *sectionHeader = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sectionheader.png"]];
    [sectionHeader setFrame:CGRectMake(0, 0, headerView.frame.size.width, headerView.frame.size.height)];
    [headerView addSubview:sectionHeader];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 22)];
    
    EventsNight *ea = [_eventsByNight objectAtIndex:section];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:ea.date];
    [formatter setDateFormat:@"MMMM d, yyyy"];
    NSString *dateString = [formatter stringFromDate:date];
    
    label.text = dateString;
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor orangeColor];
    label.backgroundColor = [UIColor clearColor];
    [label setFont:[UIFont fontWithName:@"Trebuchet MS" size:17.0]];
    
    [headerView addSubview:label];
    
    return headerView;
}
- (Event *)eventAtIndexPath:(NSIndexPath *)indexPath
{
    return (Event *)[((EventsNight *)[_eventsByNight objectAtIndex:indexPath.section]).array objectAtIndex:indexPath.row];
}

#pragma mark - Table view delegate

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
- (void)appImageDidLoad:(NSIndexPath *)indexPath
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
