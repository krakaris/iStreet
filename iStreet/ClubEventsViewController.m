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
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"http://localhost:5000"]];
    for(NSHTTPCookie *cookie in cookies)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMMM d, yyyy h:mm a"];
        NSString *timestamp = [formatter stringFromDate:[cookie expiresDate]];
    }
    
    self.navigationItem.title = self.club.name;
    //self.view.backgroundColor = [UIColor orangeColor];
    self.view.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:179.0/255.0 blue:76.0/255.0 alpha:1.0];
    self.eventsList.separatorColor = [UIColor blackColor];

    // Initialize the arrays
    eventsArray = [[NSMutableArray alloc] init];
    iconsBeingDownloaded = [NSMutableDictionary dictionary];
    
    [activityIndicator startAnimating];
    
    UIManagedDocument *document = [(AppDelegate *)[[UIApplication sharedApplication] delegate] document];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"]; 
    request.predicate = [NSPredicate predicateWithFormat:@"name == %@", self.club.name];
    NSError *error;
    
    NSArray *events = [document.managedObjectContext executeFetchRequest:request error:&error];
    
    [self setPropertiesWithNewEventData:events];
    
    [eventsList reloadData];
    
    //Get event data from server
    [self getListOfEvents: self.club.name];
    [activityIndicator stopAnimating];
}

- (void) getListOfEvents:(NSString *)clubName
{    
    //Build url for server
    NSString *relativeURL = [NSString stringWithFormat:@"/clubevents?name=%@", clubName];
    relativeURL = [relativeURL stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];

    ServerCommunication *sc = [[ServerCommunication alloc] init];
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:nil forViewController:self  withDelegate:self andDescription:nil];
}

- (void)connectionFailed:(NSString *)description
{
    NSLog(@"Connection Failed\n");
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
    [eventsList reloadData];    
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
    return [self formatTime:e];
}
- (NSString *)formatTime:(Event *)event {
    if (event.time_start && event.time_end) {
        NSString *eventDate = event.stringForStartDate;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"YYYY-MM-dd"];
        NSDate *sDate = [dateFormat dateFromString:eventDate];
        
        NSDateFormatter *newFormat = [[NSDateFormatter alloc] init];
        [newFormat setDateFormat:@"EEEE, MMMM d"];
        NSString *sTimeString = [newFormat stringFromDate:sDate];
        
        return sTimeString;
    } else {
        return event.title;
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
    // Update event title if none is given
    if (event.title) {
        if ([event.title isEqualToString:@""] || [event.title isEqualToString:clubName]) {
            cell.textLabel.text = @"On Tap";
            event.title = @"On Tap";
        } else {
            cell.textLabel.text = event.title;
        }
    }
    cell.detailTextLabel.text = [self setSubtitle:event];
    return cell;
}
// Determine entry description
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
    NSString *custom = [NSString stringWithFormat:@"Cu"];
    
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
        // Search entry_description for a number: entry is members + this number
        if (![entry_descrip isEqualToString:@""]) {
            entry_final = [entry_final stringByAppendingString:@" "];
            entry_final = [entry_final stringByAppendingString:entry_descrip];
        }
    } else if ([entry isEqualToString:list]) {
        entry_final = @"Guest List";
    } else if ([entry isEqualToString:custom]) {
        entry_final = entry_descrip;
    }
    return entry_final;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 22)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 22)];
    Event *e = (Event *)[eventsArray objectAtIndex:section];
    label.text = [self formatTime:e];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor orangeColor];
    label.backgroundColor = [UIColor darkGrayColor];
    [label setFont:[UIFont fontWithName:@"Trebuchet MS" size:17.0]];
    [headerView addSubview:label];

    return headerView;
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
