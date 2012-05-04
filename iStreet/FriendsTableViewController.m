//
//  FriendsTableViewController.m
//  iStreet
//
//  Created by Akarshan Kumar on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendsTableViewController.h"
#import "EventsAttendingTableViewController.h"

@interface FriendsTableViewController ()

@end

@implementation FriendsTableViewController

@synthesize isFiltered;

@synthesize fbid_selected;
@synthesize name_selected;
@synthesize eventsAttending_selected;

@synthesize friendslist;
@synthesize filteredFriendsList;
@synthesize justFriendNames;
@synthesize sectionsIndex;
@synthesize searchBar;
@synthesize friendsTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.title = @"Friends";
    
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
}

- (void) searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
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
#warning Potentially incomplete method implementation.
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
    else
        return [sectionsIndex objectAtIndex:section];
}

- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return sectionsIndex;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    int rowCount;
    
    if (self.isFiltered)
    {
        rowCount = [filteredFriendsList count];
    }
    else {
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    // Configure the cell...
    cell = [[UITableViewCell alloc] init];
    
    if (self.isFiltered)
    {
        cell.textLabel.text =  [[filteredFriendsList objectAtIndex:indexPath.row] valueForKey:@"name"];
    }
    else 
    {
        NSString *alpha = [sectionsIndex objectAtIndex:[indexPath section]];
        NSPredicate *thisPredicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", alpha];
        //Getting the names that begin with that first letter
        NSArray *names = [justFriendNames filteredArrayUsingPredicate:thisPredicate];
        if ([names count] > 0)
            {
                NSString *friendName = [names objectAtIndex:indexPath.row];
                cell.textLabel.text = friendName;
            }
    }

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
    
    [self.searchBar resignFirstResponder];
    
    
    //detecting name and fb_id at that cell location   
    if (self.isFiltered)
    {
        NSInteger currentRow = [[self.friendsTableView indexPathForSelectedRow] row];
        fbid_selected = [[filteredFriendsList objectAtIndex:currentRow] valueForKey:@"id"];
        name_selected = [[filteredFriendsList objectAtIndex:currentRow] valueForKey:@"name"];
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
    }
    
    NSLog(@"%@ and %@", fbid_selected, name_selected);  
    
    //Setting next controller's attributes
    eatvc.fbid = fbid_selected;
    eatvc.name = name_selected;
    
    //Build url for server
    NSString *relativeURL = [NSString stringWithFormat:@"/getEventsForUser?fb_id=%@", fbid_selected];
    relativeURL = [relativeURL stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];    
    
    NSLog(@"relativeURL is %@", relativeURL);
    ServerCommunication *sc = [[ServerCommunication alloc] init];
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:nil forViewController:self withDelegate:self andDescription:@"retrieve events"];
     
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    eatvc = (EventsAttendingTableViewController *) segue.destinationViewController;
    

    eatvc.name = name_selected;
    eatvc.fbid = fbid_selected;
    eatvc.eventsAttendingIDs = eventsAttending_selected;
    
    
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
    if (description == @"retrieve events")
    {
        NSLog(@"Events retrieved.");
        
        NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Response is %@", response);
        
        //Checking for error/empty response        
        NSRange thisRange = [response rangeOfString:@"ERROR" options:NSCaseInsensitiveSearch];

        if ([response length] == 0 || thisRange.location != NSNotFound)
        {
            NSLog(@"Not found!!!");
            
            //Push view controller anyway - even if the user has no events, others should be able to
            //favorite him or her
            [self performSegueWithIdentifier:@"EventsAttendingSegue" sender:self];
        }
        else 
        {
            NSLog(@"Inside else!");
            
            NSArray *responseArray = [response componentsSeparatedByString:@", "];
                        
            for (NSString *event in responseArray)
            {
                if ([event isEqualToString:@" "] || [event isEqualToString:@"  "] ||
                    [event isEqualToString:@""])
                    NSLog(@"This will be deleted"); //do nothing
                else 
                    [eventsAttending_selected addObject:event];
            }
                       
            /*
            //#DEBUGGING
            for (NSString *event_id in eventsAttending_selected)
            {
                //NSLog(@" %@", event_id);
            }
             */
            
             /*
             //Build url for server
             NSString *relativeURL = [NSString stringWithFormat:@"/eventinfo?event_id=%@", event_id];
             relativeURL = [relativeURL stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];    
             
             NSLog(@"relativeURL is %@", relativeURL);
             [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:nil forViewController:self withDelegate:self andDescription:@"/eventinfo: retrieving specific event"];
             */
            
            //Setting up the next controller
            eatvc.eventsAttendingIDs = eventsAttending_selected;
            
            [self performSegueWithIdentifier:@"EventsAttendingSegue" sender:self];
            //[self.navigationController pushViewController:eatvc animated:YES];
        }
    }
}


@end
