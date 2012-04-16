//
//  ClubEventsViewController.m
//  iStreet
//
//  Created by Alexa Krakaris on 4/9/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "ClubEventsViewController.h"
#import "OldEvent.h"
#import "EventDetailsViewController.h"

@interface ClubEventsViewController ()

@end

@implementation ClubEventsViewController
@synthesize club, eventsList, sections;

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
    
    self.navigationItem.title = self.club.clubName;
    
    // Initialize our arrays
    events = [[NSMutableArray alloc] init];
    eventTitles = [[NSMutableArray alloc] init];
    eventImages = [[NSMutableArray alloc] init];
    eventStartDates  = [[NSMutableArray alloc] init];
    eventStartTimes = [[NSMutableArray alloc] init];
    eventEndTimes = [[NSMutableArray alloc] init];
    
    eventsList.dataSource = self;
    eventsList.delegate = self;
    
    //Get event data from server
    [self getListOfEvents: club.clubName];
    
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
    OldEvent *e = [events objectAtIndex:section];
    return e.startDate;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Club Event";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    // Configure the cell...
    OldEvent *event = [events objectAtIndex: indexPath.section];
    //NSString *title = [eventTitles objectAtIndex: indexPath.section];
    NSString *title = event.title;
    
    if ([title isEqualToString:@""] || [title isEqualToString:club.clubName]) {
        event.title = @"On Tap";
        title = @"On Tap";
    }
    
    // Format Times appropriately for Subtitle
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

// Online Flickr Tutorial - not sure if correct?
/*- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
    // Store incoming data into a string
    //IS it UTF8 or LATIN-1 encoding???
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // Create a dictionary from the JSON string
    
    //NSDictionary *results = [jsonString JSONValue];
    NSDictionary *results;
    
    // Build an array of events from the dictionary for easy access to each entry
    //NSArray *events = [[results objectForKey:@""];
    for (NSString *key in results) {
        [eventTitles addObject:[results objectForKey:@"title"]];
        NSString *picture = [results objectForKey:@"poster"];
        // If there is a field for "poster", use it
        [eventImages addObject:(picture.length > 0 ? picture : @"")];
        
        //Create url for event images:
        if (![picture isEqualToString:@""]) {
            NSString *imageURLString = 
        [NSString stringWithFormat:@"http://pam.tigerapps.org/media/%@", picture];
        } else {
            //Use default crest if no image provided
            NSString *imageURLString = [NSString stringWithFormat:@"http://pam.tigerapps.org/media/%@", clubName];
        }
         
        [eventDates addObject:[results objectForKey:@"DATE(time_start)"]];
    }
}
*/ 
- (void) getListOfEvents: (NSString *) clubName
{
    //Build url for server
    NSString *urlString = 
    [NSString stringWithFormat:
     @"http://istreetsvr.herokuapp.com/clubevents?name=%@", clubName];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection) {
        receivedData = [NSMutableData data];
    }
    
 //else do nothing

 }

- (void) getImageForEvent: (OldEvent *) event
{
    //Build url for server
    NSString *urlString = 
    [NSString stringWithFormat:
     @"http://pam.tigerapps.org/media/%@", event.poster];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection) {
        receivedData = [NSMutableData data];
    }
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
    NSArray *eventsArray = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:&error];
    if(!eventsArray)
    {
        NSLog(@"%@", [error localizedDescription]);
        return; // do nothing if can't recieve messages
    }
    
    for(NSDictionary *dict in eventsArray)
    {
         OldEvent *e = [[OldEvent alloc] initWithDictionary:dict];
        [events addObject:e];
        if (e.title != nil) {
            [eventTitles addObject:e.title];
        } else {
            [e setTitle:@"On Tap"];
            [eventTitles addObject:e.title];
        }
        if ([e.description isEqualToString:@""]) {
            e.description = @"On Tap";
        }
        e.description = [e.description stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
       
        // Fix start date string
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"YYYY-MM-dd"];
        NSDate *sDate = [dateFormat dateFromString:e.startDate];
        
        NSDateFormatter *newFormat = [[NSDateFormatter alloc] init];
        [newFormat setDateFormat:@"EEEE, MMMM d"];
        NSString *sTimeString = [newFormat stringFromDate:sDate];
        e.startDate = sTimeString;
        
        [eventStartDates addObject:e.startDate];
        [eventStartTimes addObject:e.startTime];
        [eventEndTimes addObject:e.endTime];
    }
    
    [eventsList reloadData];
    
    //Add images to Array: "eventImages"
    /*for (Event *event in events)
    {
        
        
        
        // If there is a field for "poster", use it
        //[eventImages addObject:(event.poster.length > 0 ? event.poster : @"")];
        
        //Create url for event images:
        if (![event.poster isEqualToString:@""]) {
            NSString *imageURLString = 
            [NSString stringWithFormat:@"http://pam.tigerapps.org/media/%@", event.poster];
            //UIImage *eventImage = get Image!
            UIImage *eventImage = nil;
            
            [eventImages addObject:eventImage];
        } else {
            NSString *name = [NSString stringWithFormat:@"%@", club.clubName];
            //Use default crest if no image provided
            UIImage *eventImage = [UIImage imageNamed: name]; 
            [eventImages addObject:eventImage];
            
        }
    }*/
    
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
