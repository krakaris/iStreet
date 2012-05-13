//
//  SeeFriendsAttendingTableViewController.m
//  iStreet
//
//  Created by Akarshan Kumar on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SeeFriendsAttendingTableViewController.h"
#import "FriendCell.h"
#import "EventsAttendingTableViewController.h"

@interface SeeFriendsAttendingTableViewController ()
+ (NSArray *)intersectAllFriendsArray:(NSArray *)allFriends withAttendees:(NSArray *)fbids;
@end

@implementation SeeFriendsAttendingTableViewController

#define NUMBER_OF_SECTIONS 1

@synthesize fbid_loggedInUser;
@synthesize friendsFbidArray;
@synthesize listOfAttendingFriends;
@synthesize eventID;
@synthesize spinner;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

//Gets called the every time this view is loaded.
- (void) viewWillAppear:(BOOL)animated
{
    //Setting spinner up
    self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width/2.0 - 10.0, self.tableView.frame.size.height/2.0 - 5.0, 20, 20)];
    self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.tableView addSubview:self.spinner];
    [self.spinner startAnimating];
    
    //NSLog(@"Event id is %@", self.eventID);
    self.navigationItem.hidesBackButton = NO;
    
    listOfAttendingFriends = [[NSMutableArray alloc] init];
    
    //Build url for server
    NSString *relativeURL = [NSString stringWithFormat:@"/getUsersForEvent?event_id=%@", self.eventID];
    relativeURL = [relativeURL stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];    
    
    NSLog(@"relativeURL is %@", relativeURL);
    ServerCommunication *sc = [[ServerCommunication alloc] init];
    
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:nil forViewController:self withDelegate:self andDescription:@"fetching users"];

    self.navigationItem.backBarButtonItem.target = self;
    self.navigationItem.backBarButtonItem.action = @selector(backToDetails:);
}

//back to details screen
- (void) backToDetails
{
    NSLog(@"Back to details!");
}

//Delegate method of ServerCommunication - gets called if request fails
- (void)connectionFailed:(NSString *)description
{
#warning AKI - implement this method (need to handle a web access fail)
}

//Delegate method of ServerCommunication - gets called if request is successful
- (void) connectionWithDescription:(NSString *)description finishedReceivingData:(NSData *)data
{
    //emptying the array
    [listOfAttendingFriends removeAllObjects];
    [self.tableView reloadData];
    
    if (description == @"fetching users")
    {        
        NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Request completed with response string %@", response);
        
        NSMutableArray *arrayOfAttendingFBIDs = [NSMutableArray arrayWithArray:[response componentsSeparatedByString:@", "]];
        
        //Obtaining global friends array
        NSArray *allFriendsFB = [(AppDelegate *)[[UIApplication sharedApplication] delegate] allfbFriends];
        //NSLog(@"COUNT OF ALL FRIENDS IN GLOBAL = %d", [allFriendsFB count]);
                
        NSArray *friendsAttending = [SeeFriendsAttendingTableViewController intersectAllFriendsArray:allFriendsFB withAttendees:arrayOfAttendingFBIDs];
        
        [self.spinner stopAnimating];
        

        if ([friendsAttending count] == 0)  //if no friends are attending, pop up alert
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"None Attending" message:@"None of your friends are attending this event." delegate:self cancelButtonTitle:@"Go Back" otherButtonTitles:nil];
            alert.delegate = self;
            [alert show];
        }
        
        //Setting global array to friends Attending Array
        listOfAttendingFriends = [NSArray arrayWithArray:friendsAttending];
        
        //NSLog(@"Setting global to temporary array!");
        //NSLog(@"Number of results is %d", [listOfAttendingFriends count]);
        
        //Reloading data
        [self.tableView reloadData];
    }
}

//Gets called when button on alert view is pressed
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Cancel Pressed!");
    [self.navigationController popViewControllerAnimated:YES];
}

//Gets called the first time this view is loaded.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //basic setup of table view, background
    self.tableView.separatorColor = [UIColor blackColor];
    self.view.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:141.0/255.0 blue:17.0/255.0 alpha:1.0];
    
    _iconsBeingDownloaded = [[NSMutableDictionary alloc] init];
}

//Called to start downloading current icon
- (void)startIconDownload:(NSDictionary *)user forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [_iconsBeingDownloaded objectForKey:indexPath];
    if (iconDownloader) //if there is already a download in progress for that event, return.
        return;
    
    // start the download
    iconDownloader = [[IconDownloader alloc] init];
    [_iconsBeingDownloaded setObject:iconDownloader forKey:indexPath];
    NSURL *url = [NSURL URLWithString:[user valueForKey:@"picture"]];
    
    [iconDownloader startDownloadFromURL:url forImageKey:@"pictureData" ofObject:user forDisplayAtIndexPath:indexPath atDelegate:self];
}

//Called after icon gets loaded, refresh the cell at that index path in the table view
- (void)iconDidLoad:(NSIndexPath *)indexPath
{
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [_iconsBeingDownloaded removeObjectForKey:indexPath];
}

//Called when the view stops decelerating
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];    
}

//Called when the view stops dragging
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{    
    if (!decelerate)
        [self loadImagesForOnscreenRows];
}

// this method is used when the user scrolls into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visiblePaths)
    {
        // start downloading the icon if the event doesn't have an icon but has a link to one
        NSDictionary *user = [listOfAttendingFriends objectAtIndex:indexPath.row];
        if (![user valueForKey:@"pictureData"])
            [self startIconDownload:user forIndexPath:indexPath];
    }
}

//Called when view gets unloaded
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//Called when view gets removed from screen
- (void) viewDidDisappear:(BOOL)animated
{
    NSLog(@"View unloaded");
}

//Restricting orientation to Portrait
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

//Data Source delegate method for table view - returns the number of sections in the table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return NUMBER_OF_SECTIONS;
}

//Data Source delegate method for table view - returns the number of rows in this section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [listOfAttendingFriends count];
}

//Data Source delegate method for table view - returns the cell at that index path
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendsAttendingCell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell = [[FriendCell alloc] init];
    NSDictionary *user = [listOfAttendingFriends objectAtIndex:indexPath.row];
    cell.textLabel.text = [user valueForKey:@"name"];
    NSData *pictureData = [user valueForKey:@"pictureData"];
    
    if (!pictureData) //if pictureData doesn't exist, load using startIconDownload:ForIndexPath: method
    {
        cell.imageView.image = [UIImage imageNamed:@"FBPlaceholder.gif"];
        if (!(self.tableView.dragging == YES || self.tableView.decelerating == YES))
            [self startIconDownload:user forIndexPath:indexPath];
    }
    else 
        cell.imageView.image = [UIImage imageWithData:pictureData];
    
    return cell;
}

//Data Source delegate method for table view - return height for this row
- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return fCellHeight;
}

//Custom method to find intersection of one's friends and all attendees of an event
+ (NSArray *)intersectAllFriendsArray:(NSArray *)allFriends withAttendees:(NSArray *)fbids
{
    NSMutableArray *friendsAttending = [NSMutableArray arrayWithArray:allFriends];
    [friendsAttending sortUsingComparator:^NSComparisonResult(id obj1, id obj2) 
    {
        NSNumber *fb_id1 = [obj1 valueForKey:@"id"];
        NSNumber *fb_id2 = [obj2 valueForKey:@"id"];
        return [fb_id1 compare:fb_id2];
    }];
    
    NSArray *sortedFbids = [fbids sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *fb_id1 = (NSNumber *)obj1;
        NSNumber *fb_id2 = (NSNumber *)obj2;
        return [fb_id1 compare:fb_id2];
    }];
    
    int allFriendsIndex = 0;
    int fbidsIndex = 0;
    
    while(fbidsIndex < [sortedFbids count] && allFriendsIndex < [friendsAttending count])
    {
        NSComparisonResult comparisonResult = [[sortedFbids objectAtIndex:fbidsIndex] compare:[[friendsAttending objectAtIndex:allFriendsIndex] valueForKey:@"id"]];
        
        if(comparisonResult == NSOrderedAscending)
            fbidsIndex++;
        else if(comparisonResult == NSOrderedDescending)
            [friendsAttending removeObjectAtIndex:allFriendsIndex]; 
        else 
        {
            fbidsIndex++;
            allFriendsIndex++;
        }
    }
    
    while(allFriendsIndex < [friendsAttending count])
        [friendsAttending removeObjectAtIndex:allFriendsIndex];
    [friendsAttending sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *n1 = [obj1 valueForKey:@"name"];
        NSString *n2 = [obj2 valueForKey:@"name"];
        return [n1 compare:n2];
    }];
    return friendsAttending;
}


#pragma mark - Table view delegate

//Delegate method for table view - called to determine what happens when a row is selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *user = [listOfAttendingFriends objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"EventsAttendingSegue" sender:user];
}

//Called before the next view controller is pushed - any setup is done here
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSDictionary *user = (NSDictionary *)sender;
    EventsAttendingTableViewController *eatvc = (EventsAttendingTableViewController *) segue.destinationViewController;
    [eatvc setName:[user valueForKey:@"name"]];
    [eatvc setFbid:[user valueForKey:@"id"]];
}

@end
