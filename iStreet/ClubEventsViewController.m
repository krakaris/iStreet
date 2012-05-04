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

@synthesize club;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.club.name;
    self.view.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:179.0/255.0 blue:76.0/255.0 alpha:1.0];
    self.tableView.separatorColor = [UIColor blackColor];

    // Initialize the arrays
    eventsArray = [NSMutableArray array];
    iconsBeingDownloaded = [NSMutableDictionary dictionary];
    
    BOOL dataDidLoad = [(AppDelegate *)[[UIApplication sharedApplication] delegate] appDataLoaded];
    
    // If Core Data has not finished loading, register for a notification for when it does. Otherwise, load the data.
    if(!dataDidLoad)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData:) name:DataLoadedNotificationString object:nil];
    else
        [self loadData:nil];
}

- (void)loadData:(NSNotification *)notification
{
    if(notification)
        [[NSNotificationCenter defaultCenter] removeObserver:self];

    UIManagedDocument *document = [(AppDelegate *)[[UIApplication sharedApplication] delegate] document];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"]; 
    request.predicate = [NSPredicate predicateWithFormat:@"name == %@", self.club.name];
    NSError *error;
    NSArray *events = [document.managedObjectContext executeFetchRequest:request error:&error];
    
    [self setPropertiesWithNewEventData:events];
    
    [self.tableView reloadData];
    
    //Get event data from server
    [self getServerEventsData];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    NSIndexPath *selectedRow = [self.tableView indexPathForSelectedRow];
    if(selectedRow)
        [self.tableView deselectRowAtIndexPath:selectedRow animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) getServerEventsData
{    
    //Build url for server
    NSString *relativeURL = [NSString stringWithFormat:@"/clubevents?name=%@", self.club.name];
    relativeURL = [relativeURL stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];

    ServerCommunication *sc = [[ServerCommunication alloc] init];
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:nil forViewController:self  withDelegate:self andDescription:nil];
}

/*
 Runs when the connection has successfully finished loading all data
 */

- (void)connectionWithDescription:(NSString *)description finishedReceivingData:(NSData *)data
{      
    NSError *error;
    NSArray *eventsDictionaryArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
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
    [self.tableView reloadData];    
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
    
    [eventsArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Event *e1 = (Event *)obj1;
        Event *e2 = (Event *)obj2;
        return [e1.time_start compare:e2.time_start];
    }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"event cell";
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[EventCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    Event *event = [eventsArray objectAtIndex: indexPath.section];
    NSString *clubName = event.name;
    
    if ([cell packCellWithEventInformation:event
                               atIndexPath:indexPath
                            whileScrolling:(self.tableView.dragging == YES 
                                            || self.tableView.decelerating == YES)]) {
                                [self startIconDownload:event forIndexPath:indexPath];
                            }
    // Update event title if none is given
    if (event.title) {
        if ([event.title isEqualToString:@""] || [event.title isEqualToString:clubName]) {
            cell.textLabel.text = @"On Tap";
            event.title = @"On Tap";
        } else {
            cell.textLabel.text = event.title;
        }
    }
    cell.detailTextLabel.text = [event fullEntryDescription];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 22)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 22)];
    
    Event *e = (Event *)[eventsArray objectAtIndex:section];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:[e stringForStartDate]];
    [formatter setDateFormat:@"MMMM d, yyyy"];
    NSString *dateString = [formatter stringFromDate:date];
    
    label.text = dateString;
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor orangeColor];
    label.backgroundColor = [UIColor darkGrayColor];
    [label setFont:[UIFont fontWithName:@"Trebuchet MS" size:17.0]];
    
    [headerView addSubview:label];
    
    return headerView;

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


#pragma mark -
#pragma mark Table cell image support

/** COPIED CODE! Rishi will deal with this later. **/
- (void)startIconDownload:(Event *)event forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [iconsBeingDownloaded objectForKey:indexPath];
    if (iconDownloader) //if there is already a download in progress for that event, return.
        return;
    
    // start the download
    iconDownloader = [[IconDownloader alloc] init];
    [iconsBeingDownloaded setObject:iconDownloader forKey:indexPath];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://pam.tigerapps.org/media/%@", event.poster]];
    
    [iconDownloader startDownloadFromURL:url forImageKey:@"posterImageData" ofObject:event forDisplayAtIndexPath:indexPath atDelegate:self];
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [(UIActivityIndicatorView *)[cell.contentView viewWithTag:kLoadingIndicatorTag] stopAnimating];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
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
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visiblePaths)
    {
        Event *event = [eventsArray objectAtIndex:indexPath.row]; // the event for the cell at that index path
        
        // start downloading the icon if the event doesn't have an icon but has a link to one
        if (!event.posterImageData && event.poster && ![event.poster isEqualToString:@""])
            [self startIconDownload:event forIndexPath:indexPath];
    }
}


@end
