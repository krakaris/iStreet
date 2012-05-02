//
//  EventsAttendingTableViewController.m
//  iStreet
//
//  Created by Akarshan Kumar on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventsAttendingTableViewController.h"

@interface EventsAttendingTableViewController ()

@end

@implementation EventsAttendingTableViewController

@synthesize fbid;
@synthesize name;
@synthesize firstname;
@synthesize nameComponents;
@synthesize eventsAttending;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    nameComponents = [name componentsSeparatedByString:@" "];
    firstname = [nameComponents objectAtIndex:0];
    NSLog(@"first name is %@", firstname);

    self.navigationItem.title = [NSString stringWithFormat:@"%@'s Events", firstname];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) finishedReceivingData:(NSData *)data
{

    /*
    NSArray *eventsDictionaryArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if(!eventsDictionaryArray)
    {
        NSLog(@"%@", [error localizedDescription]);
        return; // do nothing if can't recieve messages
    }
    
    NSMutableArray *eventsTempArray = [NSMutableArray arrayWithCapacity:[eventsDictionaryArray count]];
    
    NSLog(eventsTempArray);
    
    for(NSDictionary *dict in eventsDictionaryArray)
    {
        //Event *e = [Event eventWithData:dict];
        //[eventsTempArray addObject:e];
    }
     */
    
    //[self setPropertiesWithNewEventData:eventsTempArray];
    //[eventsList reloadData];
    //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
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
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [eventsAttending count];
    NSLog(@"Data source!!!");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EventsAttendingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = [eventsAttending objectAtIndex:indexPath.row];
    NSLog(@"This is!!!! %@", [eventsAttending objectAtIndex:indexPath.row]);
    // Configure the cell...
    
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

@end
