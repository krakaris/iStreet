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

- (void) viewWillAppear:(BOOL)animated
{
    //Setting spinner up
    self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width/2.0 - 10.0, self.tableView.frame.size.height/2.0 - 5.0, 20, 20)];
    self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.tableView addSubview:self.spinner];
    [self.spinner startAnimating];
    
    NSLog(@"Event id is %@", self.eventID);
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

- (void) backToDetails
{
    NSLog(@"Back to details!");
}

- (void)connectionFailed:(NSString *)description
{
#warning AKI - implement this method (need to handle a web access fail)
}

- (void) connectionWithDescription:(NSString *)description finishedReceivingData:(NSData *)data
{
    //emptying the array
    [listOfAttendingFriends removeAllObjects];
    [self.tableView reloadData];
    
    if (description == @"fetching users")
    {        
        /*
         downloadFriendsAttendingQ = dispatch_queue_create("friends attending downloader", NULL);
         dispatch_async(downloadFriendsAttendingQ, ^{
         
         */
        NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Request completed with response string %@", response);
        
        NSMutableArray *arrayOfAttendingFBIDs = [NSMutableArray arrayWithArray:[response componentsSeparatedByString:@", "]];
        
        /*NSMutableArray *temporaryFriendsArray = [[NSMutableArray alloc] init];
        NSMutableSet *allFriendsFBIDs = [[NSMutableSet alloc] init];
        NSMutableArray *temporaryFriendsIDsArray = [[NSMutableArray alloc] init];*/
        
        NSArray *allFriendsFB = [(AppDelegate *)[[UIApplication sharedApplication] delegate] allfbFriends];
        NSLog(@"COUNT OF ALL FRIENDS IN GLOBAL = %d", [allFriendsFB count]);
                
        NSArray *friendsAttending = [SeeFriendsAttendingTableViewController intersectAllFriendsArray:allFriendsFB withAttendees:arrayOfAttendingFBIDs];
        
        
        [self.spinner stopAnimating];
        
        //if ([temporaryFriendsArray count] == 0)
        
        
        //if ([allFriendsFBIDs count] == 0)
        if ([friendsAttending count] == 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"None Attending" message:@"None of your friends are attending this event." delegate:self cancelButtonTitle:@"Go Back" otherButtonTitles:nil];
            alert.delegate = self;
            [alert show];
        }
        
        //Setting global array to temporary friends array
        //listOfAttendingFriends = [NSArray arrayWithArray:temporaryFriendsArray];
        //listOfAttendingFriends = [NSArray arrayWithArray:[allFriendsFBIDs allObjects]];
        listOfAttendingFriends = [NSArray arrayWithArray:friendsAttending];
        NSLog(@"Setting global to temporary array!");
        NSLog(@"Number of results is %d", [listOfAttendingFriends count]);
        
        //Reloading data
        [self.tableView reloadData];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Cancel Pressed!");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor blackColor];
    self.view.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:141.0/255.0 blue:17.0/255.0 alpha:1.0];
    
    _iconsBeingDownloaded = [[NSMutableDictionary alloc] init];
}

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

- (void)iconDidLoad:(NSIndexPath *)indexPath
{
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [_iconsBeingDownloaded removeObjectForKey:indexPath];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];    
}

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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewDidDisappear:(BOOL)animated
{
    NSLog(@"View unloaded, thread canceled!");

    //#DEBUG
    //if (downloadFriendsAttendingQ)
      //  dispatch_suspend(downloadFriendsAttendingQ);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [listOfAttendingFriends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendsAttendingCell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell = [[FriendCell alloc] init];
    NSDictionary *user = [listOfAttendingFriends objectAtIndex:indexPath.row];
    cell.textLabel.text = [user valueForKey:@"name"];
    NSData *pictureData = [user valueForKey:@"pictureData"];
    if (!pictureData)
    {
        cell.imageView.image = [UIImage imageNamed:@"FBPlaceholder.gif"];
        if (!(self.tableView.dragging == YES || self.tableView.decelerating == YES))
            [self startIconDownload:user forIndexPath:indexPath];
    }
    else 
        cell.imageView.image = [UIImage imageWithData:pictureData];
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return fCellHeight;
}

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
    NSDictionary *user = [listOfAttendingFriends objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"EventsAttendingSegue" sender:user];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSDictionary *user = (NSDictionary *)sender;
    EventsAttendingTableViewController *eatvc = (EventsAttendingTableViewController *) segue.destinationViewController;
    [eatvc setName:[user valueForKey:@"name"]];
    [eatvc setFbid:[user valueForKey:@"id"]];
}

@end
