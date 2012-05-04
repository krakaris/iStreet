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
@synthesize eventsAttendingIDs;
@synthesize eligibleEvents;
@synthesize currentlySelectedEvent;

@synthesize favButton;
@synthesize isStarSelected;
@synthesize isAlreadyFavorite;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) makeFavorite
{
    UIManagedDocument *document = [(AppDelegate *)[[UIApplication sharedApplication] delegate] document];

    NSLog(@"Favorites button touched!");

    NSFetchRequest *usersRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSArray *users = [document.managedObjectContext executeFetchRequest:usersRequest error:nil];
    
    //There should be only 1 user entity - and with matching netid
    //Check using global netid
    NSString *globalnetid = [(AppDelegate *)[[UIApplication sharedApplication] delegate] netID];
    
    User *targetUser; // = [[User alloc] init];
    
    for (User *user in users)
    {
        if ([globalnetid isEqualToString:user.netid])
        {
            targetUser = user;
            NSLog(@"Found target!");
        }
             
        //NSLog(@"NETID of user is %@ and fb id is %@", user.netid, user.fb_id);
        //NSLog(@"Global netid is %@", globalnetid);
    }
     
    NSString *commaSepFavFBFriendsList = targetUser.fav_friends_commasep;
    NSMutableArray *arrayOfFavFBFriendIDs = [NSMutableArray arrayWithArray:[commaSepFavFBFriendsList componentsSeparatedByString:@","]];
    
    NSLog(@"Comma-separated list received in response is %@", commaSepFavFBFriendsList);
    
    for (NSString *thisID in arrayOfFavFBFriendIDs)
    {
        //Getting rid of empty strings.
        if ([thisID isEqualToString:@""])
            [arrayOfFavFBFriendIDs removeObject:thisID];
    }

    //NSLog(@"comma sep list is %@", commaSepFavFBFriendsList);
    //NSLog(@"array length is %d", [arrayOfFavFBFriendIDs count]);

    if (isStarSelected)
    {
        NSLog(@"Star was SELected earlier, just DESELected!");
        isStarSelected = NO;
        starButton.selected = NO;
        
        if ([arrayOfFavFBFriendIDs containsObject:self.fbid])
        {
            NSLog(@"It does contain it!");
            [arrayOfFavFBFriendIDs removeObject:self.fbid];
        }
    }
    else 
    {          
        NSLog(@"Star was DESELected earlier, just SELected!");
        isStarSelected = YES;
        starButton.selected = YES;

        NSLog(@"Adding to array!");
        
        //add current fbid to array
        [arrayOfFavFBFriendIDs addObject:self.fbid];
    }
    
    //If 0 favorite friends left
    if ([arrayOfFavFBFriendIDs count] == 0)
    {
        NSLog(@"no favs left!");
        targetUser.fav_friends_commasep = @"";
        
        NSLog(@"Number of elements in arrayOfFavFriends is %d", [arrayOfFavFBFriendIDs count]);
        NSLog(@"Updated favorites list (count = 0) to %@", targetUser.fav_friends_commasep);
    }
    else if ([arrayOfFavFBFriendIDs count] == 1) //If 1 favorite friend total
    {
        targetUser.fav_friends_commasep = [NSString stringWithFormat:@"%@", [arrayOfFavFBFriendIDs lastObject]];
        
        NSLog(@"Number of elements in arrayOfFavFriends is %d", [arrayOfFavFBFriendIDs count]);
        NSLog(@"Updated favorites list (count = 1) to %@", targetUser.fav_friends_commasep);
    }
    else //if more than 1 favorite friend in all
    {
        int count = 0;
        NSString *buildingCommaSepString = @"";
        for (NSString *facebookID in arrayOfFavFBFriendIDs)
        {
            if (count == 0)
            {
                buildingCommaSepString = facebookID;
            }
            else 
            {
                NSString *stringToAppend = [NSString stringWithFormat:@",%@", facebookID];
                buildingCommaSepString = [buildingCommaSepString stringByAppendingString:stringToAppend];
            }
            count = count + 1;
        }
        
        targetUser.fav_friends_commasep = buildingCommaSepString;
        
        NSLog(@"Number of elements in arrayOfFavFriends is %d", [arrayOfFavFBFriendIDs count]);
        NSLog(@"Updated favorites list (count > 1) to %@", targetUser.fav_friends_commasep);
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    self.isStarSelected = NO;
    
    UIImage *grayStar = [UIImage imageNamed:@"star_gray.png"];
    UIImage *orangeStar = [UIImage imageNamed:@"star_orange.png"];

    starButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [starButton setBackgroundImage:grayStar forState:UIControlStateNormal];
    [starButton setBackgroundImage:orangeStar forState:UIControlStateSelected];

    starButton.frame = CGRectMake(0, 0, 28, 28);
    [starButton addTarget:self action:@selector(makeFavorite) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barStarButton = [[UIBarButtonItem alloc] initWithCustomView:starButton];
    [barStarButton setStyle:UIBarButtonItemStylePlain];
    
    self.navigationItem.rightBarButtonItem = barStarButton;


    //Checking if already a favorite
    UIManagedDocument *document = [(AppDelegate *)[[UIApplication sharedApplication] delegate] document];
    
    NSFetchRequest *usersRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSArray *users = [document.managedObjectContext executeFetchRequest:usersRequest error:nil];
    
    //There should be only 1 user entity - and with matching netid
    //Check using global netid
    NSString *globalnetid = [(AppDelegate *)[[UIApplication sharedApplication] delegate] netID];
    
    User *targetUser;
    
    for (User *user in users)
    {
        if ([globalnetid isEqualToString:user.netid])
        {
            targetUser = user;
            NSLog(@"Found target!");
        }
        
        //NSLog(@"NETID of user is %@ and fb id is %@", user.netid, user.fb_id);
        //NSLog(@"Global netid is %@", globalnetid);
    }
    
    NSString *commaSepFavFBFriendsList = targetUser.fav_friends_commasep;
    NSMutableArray *arrayOfFavFBFriendIDs = [NSMutableArray arrayWithArray:[commaSepFavFBFriendsList componentsSeparatedByString:@","]];
    
    //Highlight star if fbid is present in fav fbid's list
    if ([arrayOfFavFBFriendIDs containsObject:self.fbid])
    {   
        NSLog(@"Already a favorite!");
        starButton.selected = YES;
        isStarSelected = YES;
        isAlreadyFavorite = YES;
    }
    else 
    {
        isAlreadyFavorite = NO;
        isStarSelected = NO;
    }

    
    /*
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage: [image stretchableImageWithLeftCapWidth:7.0 topCapHeight:0.0] forState:UIControlStateNormal];
    [button setBackgroundImage: [[UIImage imageNamed: @"right_clicked.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    
    button.frame= CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    
    [button addTarget:self action:@selector(AcceptData)    forControlEvents:UIControlEventTouchUpInside];
    
    UIView *v=[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height) ];
    
    [v addSubview:button];
    
    UIBarButtonItem *forward = [[UIBarButtonItem alloc] initWithCustomView:v];
    
    self.navigationItem.rightBarButtonItem= forward;
    
    [v release];
    [image release];
     */
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    iconsBeingDownloaded = [NSMutableDictionary dictionary];
    eligibleEvents = [[NSMutableArray alloc] init];
    
    eventDetailsController = [[EventDetailsViewController alloc] init];
    
    nameComponents = [name componentsSeparatedByString:@" "];
    firstname = [nameComponents objectAtIndex:0];
    NSLog(@"first name is %@", firstname);

    self.navigationItem.title = [NSString stringWithFormat:@"%@'s Events", firstname];

    NSLog(@"Beginning loading events data!!");
    UIManagedDocument *document = [(AppDelegate *)[[UIApplication sharedApplication] delegate] document];
    
    //#DEBUGGING
    //if(notification)
    //    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];      
    NSArray *events = [document.managedObjectContext executeFetchRequest:request error:NULL];
 
    NSLog(@"events count is %d", [events count]);
    NSLog(@"attending count is %d", [eventsAttendingIDs count]);
    
    //maybe do this filtering with predicates instead
    for (NSString *thisID in eventsAttendingIDs)
    {
        //NSLog(@" %@, and %@", event.event_id, event.name);
        for (Event *event in events)
        {
            //NSLog(@"ABCDEF %@ AND %@", thisID, event.event_id);
            if ([event.event_id isEqualToString:thisID])
            {
                [eligibleEvents addObject:event];
                //NSLog(@"Added to Eligible!");
            }
        }
    }
    
    /* #DEBUGGING
    for (NSString *event_id in eventsAttendingIDs)
    {
        NSLog(@"Inside table view");
        NSLog(@" %@", event_id);
    }
    */
    
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
    [self setEligibleEvents:nil];
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
    //return [eventsAttendingIDs count];
    return [eligibleEvents count];
    NSLog(@"Data source!!!");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...

    static NSString *CellIdentifier = @"event cell";
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //cell = [[UITableViewCell alloc] init];
    if (cell == nil)
        cell = [[EventCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    Event *thisEvent = (Event *) [eligibleEvents objectAtIndex:indexPath.row];
    if ([cell packCellWithEventInformation:thisEvent 
                               atIndexPath:indexPath 
                            whileScrolling:(self.tableView.dragging == YES || self.tableView.decelerating == YES)])
    {
        [self startIconDownload:thisEvent forIndexPath:indexPath];
    }
    
    return cell;
}
              
#pragma mark Icon Downloading
              
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

// called by our ImageDownloader when an icon is ready to be displayed (i.e. has been associated with its Event)
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [(UIActivityIndicatorView *)[cell.contentView viewWithTag:kLoadingIndicatorTag] stopAnimating];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [iconsBeingDownloaded removeObjectForKey:indexPath];
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
    
    NSLog(@"selected row %d", indexPath.row);
    
    NSLog(@"eligibleEvents count = %d", [eligibleEvents count]);
    currentlySelectedEvent = (Event *) [eligibleEvents objectAtIndex:indexPath.row];
    
    eventDetailsController.myEvent = currentlySelectedEvent;
    
    
    NSLog(@" %@ AND %@", currentlySelectedEvent.title, currentlySelectedEvent.event_description);
    
    [eventDetailsController setMyEvent:currentlySelectedEvent];
    //[self.navigationController pushViewController:eventDetailsController animated:YES];
    
    //perform segue - AttendingEventsToSpecific
    [self performSegueWithIdentifier:@"ListofEventsToSpecific" sender:currentlySelectedEvent];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /*
    EventDetailsViewController *eventDetailsController = (EventDetailsViewController *) [segue destinationViewController];

    eventDetailsController.myEvent = currentlySelectedEvent;
     */
    if ([segue.identifier isEqualToString:@"ListofEventsToSpecific"])
        [segue.destinationViewController setMyEvent:sender];
        
}

@end
