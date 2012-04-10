//
//  ClubEventsViewController.m
//  iStreet
//
//  Created by Alexa Krakaris on 4/9/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "ClubEventsViewController.h"

@interface ClubEventsViewController ()

@end

@implementation ClubEventsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    
    // Initialize our arrays
    eventTitles = [[NSMutableArray alloc] init];
    eventImages = [[NSMutableArray alloc] init];

    //Get event data from server
    //Hardcoded for Cap no - fix later!!!
    clubName = @"Tower";
    [self getListOfEvents: clubName];
    
    //Make sure names are consistent!
    NSString* imagePath = [[NSBundle mainBundle] pathForResource:clubName ofType:@"png"];
    
    clubCrest = [[UIImage alloc] initWithContentsOfFile:imagePath];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Club Event";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
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
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
    // Store incoming data into a string
    //IS it UTF8 or LATIN-1 encoding???
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // Create a dictionary from the JSON string
    NSDictionary *results = [jsonString JSONValue];
    
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
            NSString *imageURLString = [@"http://pam.tigerapps.org/media/%@", clubName];
        }
         
        [eventDates addObject:[results objectForKey:@"DATE(time_start)"]];
    }
}

- (void) getListOfEvents: (NSString *) clubName
{
    //Build url for server
    NSString *urlString = 
    [NSString stringWithFormat:
     @"http://istreetsvr.herokuapp.com/eventslist"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *cap = @"Cap";
    UIButton *club = (UIButton *)sender;
    NSString *clubname = (NSString *)club.titleLabel;
    if ([clubname isEqualToString:cap])
    {
        
    }
    
}

@end
