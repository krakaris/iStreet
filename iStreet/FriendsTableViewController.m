//
//  FriendsTableViewController.m
//  iStreet
//
//  Created by Akarshan Kumar on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendsTableViewController.h"
#import "EventsAttendingTableViewController.h"
#import "FriendCell.h"
#include <stdlib.h>

@interface FriendsTableViewController ()

@end

@implementation FriendsTableViewController

@synthesize isFiltered;

@synthesize fbid_selected;
@synthesize name_selected;
@synthesize eventsAttending_selected;

@synthesize friendslist;
@synthesize favoriteFriendsList;
@synthesize filteredFriendsList;
@synthesize justFriendNames;
@synthesize sectionsIndex;
@synthesize searchBar;
@synthesize friendsTableView;

@synthesize logoutButton;

#define loggedOutAlertView 1
#define logOutConfirmAlertView 2

- (void) logoutOfFacebook:(id)sender
{
    NSLog(@"Logging out of facebook alert view!");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout" message:@"Are you sure you wish to log out of Facebook?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    alert.tag = logOutConfirmAlertView;
    [alert show];    
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{   
    if (alertView.tag == logOutConfirmAlertView)
    {
        if (buttonIndex == 0)   //do nothing, canceled
            NSLog(@"Cancel!");
        else                    //log out of facebook
        {
            NSLog(@"Logout!");
            
            Facebook *fb = [(AppDelegate *)[[UIApplication sharedApplication] delegate] facebook];
            fb.sessionDelegate = self;
            [fb logout];
            //[fb logout];
        }
    }
    else {
        NSLog(@"Clicked on OK");
        [self.navigationController removeFromParentViewController];
    }
}

- (void) fbDidLogout
{
    NSLog(@"Logged Out!");
    [(AppDelegate *) [[UIApplication sharedApplication] delegate] setAllfbFriends:nil];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setFbID:nil];
    
    
    //Setting fbid to nil in core data
    UIManagedDocument *document = [(AppDelegate *)[[UIApplication sharedApplication] delegate] document];
    NSFetchRequest *usersRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSArray *users = [document.managedObjectContext executeFetchRequest:usersRequest error:nil];
    
    //There should be only 1 user entity - and with matching netid
    NSString *globalnetid = [(AppDelegate *)[[UIApplication sharedApplication] delegate] netID];

    User *targetUser;
    for (User *user in users)
    {
        if ([globalnetid isEqualToString:user.netid])
        {
            targetUser = user;
            NSLog(@"Found target!");
        }
    }
    //Setting fbid
    if (targetUser != nil)
        targetUser.fb_id = nil;
    
    UIAlertView *loggedOutAlert = [[UIAlertView alloc] initWithTitle:@"Logged Out!" message:@"You have been logged out of Facebook. You can log in again at any time." delegate:self cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
    loggedOutAlert.tag = loggedOutAlertView;
    [loggedOutAlert show];
}

- (void) viewWillAppear:(BOOL)animated
{
    //Obtain the favorite friends
    
    favoriteFriendsList = [[NSMutableArray alloc] init];
    
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
    
    for (NSString *thisFave in arrayOfFavFBFriendIDs)
        NSLog(@"%@", thisFave);
    
    NSArray *allFriends = [(AppDelegate *)[[UIApplication sharedApplication] delegate] allfbFriends];
    NSLog(@"COUNT OF ALL FRIENDS IN GLOBAL = %d", [allFriends count]);
    
    //NSArray *objs = [dataManager anArray];
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", [NSNumber numberWithInt:i]];
    //NSArray *matchingObjs = [objs filteredArrayUsingPredicate:predicate];

    for (NSString *thisFave in arrayOfFavFBFriendIDs)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", thisFave];
        NSArray *matchingUsers = [allFriends filteredArrayUsingPredicate:predicate];
        
        if ([matchingUsers count] == 1)
        {
            NSLog(@"FOUND A FAVORITE! id = %@", thisFave);
            [favoriteFriendsList addObject:[matchingUsers lastObject]];
        }
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    [favoriteFriendsList sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    [self.friendsTableView reloadData];
    
    NSLog(@"Favorite friends count = %d", [favoriteFriendsList count]);

    //Displaying ALL fb friends
    /*
    for (NSDictionary *user in allFriends)
    {
        NSLog(@"%@ and %@", [user valueForKey:@"name"], [user valueForKey:@"id"]);
    }
    */
 
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.title = @"Friends";
    
    self.view.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:141.0/255.0 blue:17.0/255.0 alpha:1.0];
    friendsTableView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:141.0/255.0 blue:17.0/255.0 alpha:1.0];
    self.friendsTableView.separatorColor = [UIColor blackColor];
    
    NSLog(@"#friends = %d", [friendslist count]);
    
    searchBar.delegate = self;
    isFiltered = NO; 
    
    self.friendsTableView.delegate = self;
    self.friendsTableView.dataSource = self;

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    [friendslist sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    
    sectionsIndex = [[NSMutableArray alloc] init];
    justFriendNames = [[NSMutableArray alloc] init];
    eventsAttending_selected = [[NSMutableArray alloc] init];
    eatvc = [[EventsAttendingTableViewController alloc] init];
    
    fbid_selected = [[NSString alloc] init];
    name_selected = [[NSString alloc] init];
    
    //Adding "favorites" to section index
    //[sectionsIndex addObject:@"Favorites"];
    [sectionsIndex addObject:@"*"];
    
    
    int length = [friendslist count];
    
    for (int i = 0; i < length; i++)
    {
        //copying over names
        [justFriendNames addObject:[[friendslist objectAtIndex:i] objectForKey:@"name"]];
        
        char alpha = [[[friendslist objectAtIndex:i] objectForKey:@"name"] characterAtIndex:0];
        NSString *firstChar = [NSString stringWithFormat:@"%C", alpha];
        
        if (![sectionsIndex containsObject:firstChar])
            [sectionsIndex addObject:firstChar];
        
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    /*
    for (NSDictionary *user in friendslist)
    {
        NSLog(@"%@ and %@", [user valueForKey:@"id"], [user valueForKey:@"name"]);
    }
     */
    
    [self.friendsTableView reloadData];
    
    
    /*
    //Randomizing Friends Attending different events
    
    NSArray *allEvents = [NSArray arrayWithObjects:@"71", @"111", @"88", @"89", @"93", @"96", @"69",
                          @"81", @"95", @"106", @"107", @"79", @"85", @"86", @"87", @"97", @"103",
                          @"105", @"112", @"110", @"78", @"90", @"99", @"102", @"84", @"94", @"98", @"108",
                          @"115", @"116", @"114", @"92", @"100", nil];
    
    NSArray *allFriendsFB = [(AppDelegate *)[[UIApplication sharedApplication] delegate] allfbFriends];
    
    int count = 0;
    while (count < 10)
    {
        NSDictionary *user = [allFriendsFB objectAtIndex:count];
        int i = arc4random() % [allEvents count];
        
        NSString *userName = [user valueForKey:@"name"];
        NSString *facebookID = [user valueForKey:@"id"];
        
        NSLog(@"Friend with name %@ and id %@ and index %d and random event %@", userName, facebookID, i, [allEvents objectAtIndex:i]);
        
        //Build url for server
        NSString *relativeURL = [NSString stringWithFormat:@"/attendEvent?fb_id=%@", facebookID];
        relativeURL = [relativeURL stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];    
        
        NSLog(@"relativeURL is %@", relativeURL);
        ServerCommunication *sc = [[ServerCommunication alloc] init];
        NSString *postBody = [NSString stringWithFormat:@"name=%@", userName];

        [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:postBody forViewController:self withDelegate:self andDescription:userName];
        
        for (int j = 0; j < 5; j++)
        {
            i = arc4random() % [allEvents count];
            NSString *eventPostBody = [NSString stringWithFormat:@"event_id=%@", [allEvents objectAtIndex:i]];
            [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:eventPostBody forViewController:self withDelegate:self andDescription:userName];
        }
        count ++;
    }
    */
    
    /*
    //Build url for server
    NSString *relativeURL = [NSString stringWithFormat:@"/attendEvent?fb_id=%@", @"521832474"];
    relativeURL = [relativeURL stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];    
    
    NSLog(@"relativeURL is %@", relativeURL);
    ServerCommunication *sc = [[ServerCommunication alloc] init];
    //[sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:@"name=Stacey Wenjun Zhang"forViewController:self withDelegate:self andDescription:@"stacey"];
    
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:@"event_id=102" forViewController:self withDelegate:self andDescription:@"adding event 99"];
     */
    /*
    NSString *relativeURL = [NSString stringWithFormat:@"/attendEvent?fb_id=571438200"];
    relativeURL = [relativeURL stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];    
    
    ServerCommunication *sc = [[ServerCommunication alloc] init];
    
     
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:@"name=Rishi Narang" forViewController:self withDelegate:self andDescription:@"updating name"];
    
    //sc = [[ServerCommunication alloc] init];
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:@"event_id=99" forViewController:self withDelegate:self andDescription:@"adding event 99"];
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:@"event_id=88" forViewController:self withDelegate:self andDescription:@"adding event 88"];
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:@"event_id=100" forViewController:self withDelegate:self andDescription:@"adding event 100"];
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:@"event_id=101" forViewController:self withDelegate:self andDescription:@"adding event 101"];
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:@"event_id=71" forViewController:self withDelegate:self andDescription:@"adding event 71"];
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:@"event_id=111" forViewController:self withDelegate:self andDescription:@"adding event 111"];
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:@"event_id=97" forViewController:self withDelegate:self andDescription:@"adding event 97"];
     */
}

- (void) searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.friendsTableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    if(searchText.length == 0)
    {
        isFiltered = NO;
    }
    else
    {
        isFiltered = YES;
        filteredFriendsList = [[NSMutableArray alloc] init];
        
        for (NSDictionary *user in friendslist)
        {
            NSRange nameRange = [[user objectForKey:@"name"] rangeOfString:searchText options:NSCaseInsensitiveSearch];

            if(nameRange.location != NSNotFound)
            {
                [filteredFriendsList addObject:user];
            }
        }
    }
    
    [self.friendsTableView reloadData];
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

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    //return 1;
    if (self.isFiltered)
        return 1;
    else {
        return [sectionsIndex count];
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.isFiltered)
        //return just one section if something being searched for
        return nil;
   /* else if ([[sectionsIndex objectAtIndex:section] isEqualToString:@"*"]) {
        return @"Favorites";
    }*/ else {
        return [sectionsIndex objectAtIndex:section];
    }
}

- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return sectionsIndex;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    int rowCount;
    
    if (self.isFiltered)
    {
        rowCount = [filteredFriendsList count];
    }
    else if (section == 0)
    {
        rowCount = [favoriteFriendsList count];
    }
    else
    {
        rowCount = [friendslist count];
        
        //source - http://www.devx.com/wireless/Article/43374/1763
        NSString *alpha = [sectionsIndex objectAtIndex:section];
        NSPredicate *thisPredicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", alpha];
        //Getting the names that begin with that first letter
        NSArray *names = [justFriendNames filteredArrayUsingPredicate:thisPredicate];
        rowCount = [names count];
    }

    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Friends Cell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    // Configure the cell...
    //cell = [[UITableViewCell alloc] init];
    cell = [[FriendCell alloc] init];
    
    if (self.isFiltered)
    {
        cell.textLabel.text =  [[filteredFriendsList objectAtIndex:indexPath.row] valueForKey:@"name"];
        
        NSString *currentUserName = [[filteredFriendsList objectAtIndex:indexPath.row] valueForKey:@"name"];
        
        //Checking if favorite (to add star)
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", currentUserName];
        NSArray *matchingUsers = [favoriteFriendsList filteredArrayUsingPredicate:predicate];
            
        if ([matchingUsers count] != 0)
        {
            //Make it a special cell instead.
            UIImageView *starView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star_bw.png"]];
            starView.frame = CGRectMake(250, 10, 20, 20);
            [cell.contentView addSubview:starView];
        }
    }
    else if (indexPath.section == 0)
    {
        UIImageView *starView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star_bw.png"]];
        starView.frame = CGRectMake(250, 10, 20, 20);
        cell.textLabel.text = [[favoriteFriendsList objectAtIndex:indexPath.row] valueForKey:@"name"];
        [cell.contentView addSubview:starView];
    }
    else
    {
        NSString *alpha = [sectionsIndex objectAtIndex:[indexPath section]];
        NSPredicate *thisPredicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", alpha];
        //Getting the names that begin with that first letter
        NSArray *names = [justFriendNames filteredArrayUsingPredicate:thisPredicate];
        
        NSString *friendName;
        if ([names count] > 0)
        {
            friendName = [names objectAtIndex:indexPath.row];
            cell.textLabel.text = friendName;
            //NSLog(@"Inside if with name %@", friendName);
        }
        else {
            //NSLog(@"If not true!");
        }
        
        NSString *currentUserName = friendName;
        
        //Checking if favorite (to add star)
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", currentUserName];
        NSArray *matchingUsers = [favoriteFriendsList filteredArrayUsingPredicate:predicate];
        
        if ([matchingUsers count] != 0)
        {
            //Make it a special cell instead.
            UIImageView *starView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star_bw.png"]];
            starView.frame = CGRectMake(250, 10, 20, 20);
            [cell.contentView addSubview:starView];
        }
    }

    return cell;
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
    
    NSString *text = [sectionsIndex objectAtIndex:section];
    if ([text isEqualToString:@"*"]) {
        label.text = @"Favorites";
    } else {
        label.text = text;
    }
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor orangeColor];
    label.backgroundColor = [UIColor clearColor];
    [label setFont:[UIFont fontWithName:@"Trebuchet MS" size:17.0]];
    
    [headerView addSubview:label];
    
    return headerView;
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
    
    [self.searchBar resignFirstResponder];
    
    
    //detecting name and fb_id at that cell location   
    if (self.isFiltered)
    {
        NSInteger currentRow = [[self.friendsTableView indexPathForSelectedRow] row];
        fbid_selected = [[filteredFriendsList objectAtIndex:currentRow] valueForKey:@"id"];
        name_selected = [[filteredFriendsList objectAtIndex:currentRow] valueForKey:@"name"];
    }
    else if ([[self.friendsTableView indexPathForSelectedRow] section] == 0) //If in Favorites section
    {
        NSIndexPath *currentPath = [self.friendsTableView indexPathForSelectedRow];
        fbid_selected = [[favoriteFriendsList objectAtIndex:currentPath.row] valueForKey:@"id"];
        name_selected = [[favoriteFriendsList objectAtIndex:currentPath.row] valueForKey:@"name"];
    }
    {
        NSString *alpha = [sectionsIndex objectAtIndex:[[self.friendsTableView indexPathForSelectedRow] section]]; 
        NSPredicate *thisPredicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", alpha];
        
        //Getting the names that begin with that first letter
        NSArray *names = [justFriendNames filteredArrayUsingPredicate:thisPredicate];
        
        if ([names count] > 0)
        {
            NSString *friendName = [names objectAtIndex:[[self.friendsTableView indexPathForSelectedRow] row]];
            name_selected = friendName;
            for  (NSDictionary *user in friendslist)
            {
                if (friendName == [user objectForKey:@"name"])
                    fbid_selected = [user objectForKey:@"id"];
            }
        }
    }
    
    NSLog(@"%@ and %@", fbid_selected, name_selected);  
    
    //Setting next controller's attributes
    eatvc.fbid = fbid_selected;
    eatvc.name = name_selected;
    
    [self performSegueWithIdentifier:@"EventsAttendingSegue" sender:self];

    
    /*
    //Build url for server
    NSString *relativeURL = [NSString stringWithFormat:@"/getEventsForUser?fb_id=%@", fbid_selected];
    relativeURL = [relativeURL stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];    
    
    NSLog(@"relativeURL is %@", relativeURL);
    ServerCommunication *sc = [[ServerCommunication alloc] init];
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:nil forViewController:self withDelegate:self andDescription:@"retrieve events"];
     */
     
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    eatvc = (EventsAttendingTableViewController *) segue.destinationViewController;

    eatvc.name = name_selected;
    eatvc.fbid = fbid_selected;
    
    /*
    if (self.isFiltered)
    {
        NSInteger currentRow = [[self.friendsTableView indexPathForSelectedRow] row];
        fbid_selected = [[filteredFriendsList objectAtIndex:currentRow] valueForKey:@"id"];
        name_selected = [[filteredFriendsList objectAtIndex:currentRow] valueForKey:@"name"];
        
        NSLog(@"%@ and %@", fbid_selected, name_selected);
    }
    else 
    {
        NSString *alpha = [sectionsIndex objectAtIndex:[[self.friendsTableView indexPathForSelectedRow] section]]; 
        NSPredicate *thisPredicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", alpha];
        
        //Getting the names that begin with that first letter
        NSArray *names = [justFriendNames filteredArrayUsingPredicate:thisPredicate];
       
        if ([names count] > 0)
        {
            NSString *friendName = [names objectAtIndex:[[self.friendsTableView indexPathForSelectedRow] row]];
            name_selected = friendName;
            for  (NSDictionary *user in friendslist)
            {
                if (friendName == [user objectForKey:@"name"])
                    fbid_selected = [user objectForKey:@"id"];
            }
        }
        
        NSLog(@"%@ and %@", fbid_selected, name_selected);
    }
    
    eatvc.fbid = fbid_selected;
    eatvc.name = name_selected;
    NSLog(@"Passed to eatvc - %@ and %@", fbid_selected, name_selected);
    */

}

- (void) connectionWithDescription:(NSString *)description finishedReceivingData:(NSData *)data
{
    //Empty array needed each time
    [eventsAttending_selected removeAllObjects];
    
    if (description == @"retrieve events")
    {
       
    }
    else {
        NSString *resp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Received response for %@ is %@", description, resp);
    }
}


@end
