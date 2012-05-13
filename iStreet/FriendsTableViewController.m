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
#import "User+Create.h"
#include <stdlib.h>

@interface FriendsTableViewController ()

@end

@implementation FriendsTableViewController

#define NUMBER_OF_SECTIONS_IF_FILTERED 1
#define HALF_OF_CELL_HEIGHT 25

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
#define logOutFailedAlertView 3

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
            
            /*
            Logging out is a two-step process -
             1. First, we need to make a server call to iStreet to dissociate the fbid from the netid,
             2. Then, we need to call the logout method of the facebook object
             
             The second step doesn't depend on an internet connection but the first one does,
             so we'll call them in this sequence such that if the first step fails, we never
             reach the second step.
            */
            
            //Calling server method to update user's credentials on server
            //Build url for server
            NSString *relativeURL = @"/updateUser";
            relativeURL = [relativeURL stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];    
            
            ServerCommunication *sc = [[ServerCommunication alloc] init];
            [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:@"fb_id=" forViewController:self withDelegate:self andDescription:@"updating user with fbid on logout"];
            
        }
    }
    else if (alertView.tag == loggedOutAlertView)
    {
        NSLog(@"Clicked on OK");
        //[self.navigationController removeFromParentViewController];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (alertView.tag == logOutFailedAlertView)
    {
        //do nothing, show message
        NSLog(@"Logout failed.");
    }
}

- (void) fbDidLogout
{
    NSLog(@"Logged Out!");
    [(AppDelegate *) [[UIApplication sharedApplication] delegate] setAllfbFriends:nil];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setFbID:nil];

    //Setting fbid to nil in core data    
    User *targetUser = [User userWithNetid:[(AppDelegate *)[[UIApplication sharedApplication] delegate] netID]];
    
    //Setting fbid
    if (targetUser != nil)
        targetUser.fb_id = nil;
    
    //Clearing user defaults
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:nil forKey:@"FBAccessTokenKey"];
    [prefs setObject:nil forKey:@"FBExpirationDateKey"];
    [prefs synchronize];
    
    UIAlertView *loggedOutAlert = [[UIAlertView alloc] initWithTitle:@"Logged Out!" message:@"You have been logged out of Facebook. You can log in again at any time." delegate:self cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
    loggedOutAlert.tag = loggedOutAlertView;
    [loggedOutAlert show];
}


- (void) viewWillAppear:(BOOL)animated
{
    NSLog(@"View Will Appear of Friends!");
    
    //Pop Controller if user not logged in
    NSNumber *fbid = [(AppDelegate *)[[UIApplication sharedApplication] delegate] fbID];
    
    if (fbid == nil)
    {
        [self.navigationController popViewControllerAnimated:NO];
    }

    
    //Obtain the favorite friends
    favoriteFriendsList = [[NSMutableArray alloc] init];
    
    /*//Checking if already a favorite
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
    }*/
    
    User *targetUser = [User userWithNetid:[(AppDelegate *)[[UIApplication sharedApplication] delegate] netID]];
    
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
    NSLog(@"View Did Load of Friends!");
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
    _iconsBeingDownloaded = [NSMutableDictionary dictionary];
    
    //fbid_selected = [[NSNumber alloc] initWithInt:0];
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

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.searchBar resignFirstResponder];
    
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

#pragma mark - Table view data source

//Data Source delegate method for table view - returns the number of sections in the table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.isFiltered)
        return NUMBER_OF_SECTIONS_IF_FILTERED;
    else {
        return [sectionsIndex count];
    }
}

//Data Source delegate method for table view - returns the title for each section header
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

//Data Source delegate method for table view - returns the index titles (for the vertical bar on the right)
- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return sectionsIndex;
}

//Data Source delegate method for table view - returns the number of rows in this section
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

//Data Source delegate method for table view - returns the cell at that index path
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Friends Cell";
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell)
        cell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    //To store the selected friend
    NSDictionary *currentFriend;
    NSString *currentUserName;
    int indexInCompleteFriendsArray;
    
    BOOL isAFavorite = NO;
    
    if (self.isFiltered)
    {
        currentFriend = [filteredFriendsList objectAtIndex:indexPath.row];
        currentUserName = [currentFriend valueForKey:@"name"];
        cell.textLabel.text = currentUserName;
        
        indexInCompleteFriendsArray = [self.justFriendNames indexOfObject:currentUserName];
        NSLog(@"Index in complete array is %d", indexInCompleteFriendsArray);

        
        //Checking if favorite (to add star)
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", currentUserName];
        NSArray *matchingUsers = [favoriteFriendsList filteredArrayUsingPredicate:predicate];
        
        if ([matchingUsers count] != 0) //is a favorite
        {
            isAFavorite = YES; //mark as favorite
        }
    }
    else if (indexPath.section == 0)
    {
        isAFavorite = YES; //mark as favorite

        currentFriend = [favoriteFriendsList objectAtIndex:indexPath.row];
        currentUserName = [currentFriend valueForKey:@"name"];
        cell.textLabel.text = currentUserName;
        
        indexInCompleteFriendsArray = [self.justFriendNames indexOfObject:currentUserName];
        NSLog(@"Index in complete array is %d", indexInCompleteFriendsArray);
    }
    else
    {
        NSString *alpha = [sectionsIndex objectAtIndex:[indexPath section]];
        NSPredicate *thisPredicate = [NSPredicate predicateWithFormat:@"name beginswith[c] %@", alpha];
        //Getting the names that begin with that first letter
        
        NSArray *thisSectionFriends = [friendslist filteredArrayUsingPredicate:thisPredicate];
                
        if ([thisSectionFriends count] > 0)
        {
            currentFriend = [thisSectionFriends objectAtIndex:indexPath.row];
            currentUserName = [currentFriend valueForKey:@"name"];
            cell.textLabel.text = currentUserName;
            
            currentFriend = [friendslist objectAtIndex:[justFriendNames indexOfObject:currentUserName]];
        }
        else 
        {
        }
        
        indexInCompleteFriendsArray = [self.justFriendNames indexOfObject:currentUserName];
                
        //Checking if favorite (to add star)
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", currentUserName];
        NSArray *matchingUsers = [favoriteFriendsList filteredArrayUsingPredicate:predicate];
        
        if ([matchingUsers count] != 0)
        {
            isAFavorite = YES;
        }
    }
    
    if (isAFavorite)
    {
        UIImage *image = [UIImage imageNamed:@"star_outline_thick.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, HALF_OF_CELL_HEIGHT, HALF_OF_CELL_HEIGHT)];
        [imageView setImage:image];
        cell.accessoryView = imageView;
    }
    else 
        cell.accessoryView = nil;
    
    NSDictionary *friendInCompleteArray = [self.friendslist objectAtIndex:indexInCompleteFriendsArray];
    
    //look here
    NSData *pictureData = [friendInCompleteArray valueForKey:@"pictureData"];
    if (!pictureData)
    {
        [cell setImage:[UIImage imageNamed:@"FBPlaceholder.gif"]];
        if (!(self.friendsTableView.dragging == YES || self.friendsTableView.decelerating == YES))
            [self startIconDownload:currentFriend forIndexPath:indexPath];
    }
    else 
        [cell setImage:[UIImage imageWithData:pictureData]];

        

     
    return cell;
}

//Called when the view stops decelerating
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];    
}

// this method is used when the user scrolls into a set of cells that don't have their app icons yet

- (void)loadImagesForOnscreenRows
{
    NSArray *visiblePaths = [self.friendsTableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visiblePaths)
    {
        // start downloading the icon if the event doesn't have an icon but has a link to one
        NSDictionary *user = [self getUserAtIndexPath:indexPath];
        if (![user valueForKey:@"pictureData"])
            [self startIconDownload:user forIndexPath:indexPath];
    }
}

- (NSDictionary *) getUserAtIndexPath: (NSIndexPath *) indexPath
{
    int sections = indexPath.section;
    
    int count = 0, sum = 0;
    while (count < sections)
    {
        sum += [self.friendsTableView numberOfRowsInSection:count];
        count++;
        //NSLog(@"User at index path %d, %d", count, sum);
    }
    
    sum += indexPath.row;
    
    //these next two lines should never have been here!
    /*
    if (sum > 0)
        sum -= 1;

    */
    /*
    int sections = [self.friendsTableView numberOfSections];
    
    int count = 0, sum = 0;
    while (count < sections)
    {
        sum += [self.friendsTableView numberOfRowsInSection:count];
        
        count++;
    }
    
    sum -= 1;
    */
    
    //NSLog(@"index for useratIndexPath is %d", sum);
    //Return absolute object
    return [self.friendslist objectAtIndex:sum];
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
    
    //#DEBUG FIX FOR THUMBNAILS.
    //NSURL *url = [NSURL URLWithString:(NSString *)[[self.friendslist objectAtIndex:indexPath.row] valueForKey:@"picture"]];
    NSURL *url = [NSURL URLWithString:[user valueForKey:@"picture"]];
    
    [iconDownloader startDownloadFromURL:url forImageKey:@"pictureData" ofObject:user forDisplayAtIndexPath:indexPath atDelegate:self];
}

//Called after icon is loaded
- (void)iconDidLoad:(NSIndexPath *)indexPath
{
    if(self.isFiltered)
        return;
    
    //NSLog(@"loaded icon for friend name is %@", [[self getUserAtIndexPath:indexPath] valueForKey:@"name"]);
    [self.friendsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [_iconsBeingDownloaded removeObjectForKey:indexPath];
}

//Data Source delegate method for table view - return height for this row
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return fCellHeight;
}

//Method that returns the view for a header in a section - Added by Alexa for section color
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

//Delegate method for table view - called to determine what happens when a row is selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    NSLog(@"Index path selected is row %d and sec %d", indexPath.row, indexPath.section);
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

//Called before the next view controller is pushed - any setup is done here
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

//Delegate method of ServerCommunication - gets called if request fails
- (void) connectionFailed:(NSString *)description
{
    if (description == @"updating user with fbid on logout")
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout Failed" message:@"Logout failed, possibly due to lack of an internet connection. Please check your connection and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.tag = logOutFailedAlertView;
        [alert show];
    }
}

//Delegate method of ServerCommunication - gets called if request is successful
- (void) connectionWithDescription:(NSString *)description finishedReceivingData:(NSData *)data
{
    //Empty array needed each time
    [eventsAttending_selected removeAllObjects];
    
    if (description == @"updating user with fbid on logout")
    {
        NSLog(@"Updated fbid on logout");
        Facebook *fb = [(AppDelegate *)[[UIApplication sharedApplication] delegate] facebook];
        fb.sessionDelegate = self;
        [fb logout];
    }
    else if (description == @"retrieve events")
    {
        NSLog(@"Events retrieved.");
    }
    else {
        NSString *resp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Received response for %@ is %@", description, resp);
    }
}

//Facebook delegate methods
//FBSessionDelegate

- (void) fbDidLogin
{
    NSLog(@"FB did log in.");
}

- (void) fbSessionInvalidated
{
    NSLog(@"FB Session Invalidated.");
}

- (void) fbDidNotLogin:(BOOL)cancelled
{
    NSLog(@"FB did not login.");
}

- (void) fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt
{
    NSLog(@"FB did extend token.");
}

@end
