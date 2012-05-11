//
//  SeeFriendsAttendingTableViewController.m
//  iStreet
//
//  Created by Akarshan Kumar on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SeeFriendsAttendingTableViewController.h"
#import "FriendCell.h"

@interface SeeFriendsAttendingTableViewController ()

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
        
        NSMutableArray *arrayOfAttendingFBFriendIDs = [NSMutableArray arrayWithArray:[response componentsSeparatedByString:@", "]];
        
        NSMutableArray *temporaryFriendsArray = [[NSMutableArray alloc] init];
        NSMutableSet *allFriendsFBIDs = [[NSMutableSet alloc] init];
        NSMutableArray *temporaryFriendsIDsArray = [[NSMutableArray alloc] init];
        
        NSArray *allFriendsFB = [(AppDelegate *)[[UIApplication sharedApplication] delegate] allfbFriends];
        NSLog(@"COUNT OF ALL FRIENDS IN GLOBAL = %d", [allFriendsFB count]);
        
        
        for (NSDictionary *friend in allFriendsFB)
            [allFriendsFBIDs addObject:(NSString *) [friend valueForKey:@"id"]];
        
        [allFriendsFBIDs intersectSet:[NSMutableSet setWithArray:arrayOfAttendingFBFriendIDs]];
        NSLog(@"Using new method, %d", [allFriendsFBIDs count]);
        
        /*
         NSMutableSet *set = [NSMutableSet setWithArray:temporaryFriendsIDsArray];
         [set intersectSet:[NSMutableSet setWithArray:allFriendsFBIDs]];
         NSLog(@"Using new method, %d", [set count]);
         */
        
        /*
         if ([allFriendsFB count] != 0)
         {
         for (NSString *thisID in arrayOfAttendingFBFriendIDs)
         {
         //Getting rid of empty strings.
         if (![thisID isEqualToString:@""])
         {
         int count = 0;
         for (NSDictionary *friend in allFriendsFB)
         {
         
         [allFriendsFBIDs addObject:[friend valueForKey:@"id"]];
         if ([[friend valueForKey:@"id"] isEqualToString:thisID])
         {
         //NSUInteger thisIndex = [allFriendsFB indexOfObject:thisID];
         //NSDictionary *thisObject = [allFriendsFB objectAtIndex:thisIndex];
         //[listOfAttendingFriends addObject:[allFriendsFB objectAtIndex:count]];
         [temporaryFriendsArray addObject:[allFriendsFB objectAtIndex:count]];
         [temporaryFriendsIDsArray addObject:[friend valueForKey:@"id"]];
         //NSLog(@"Contains!");
         }
         else 
         {
         //NSLog(@"Doesn't contain!");
         }
         count++;
         }
         
         }
         NSLog(@"This id is %@", thisID);
         }
         
         NSLog(@"Total number of valid id's is %d", [temporaryFriendsArray count]);
         */
        
        /*
         NSMutableSet *set = [NSMutableSet setWithArray:temporaryFriendsIDsArray];
         [set intersectSet:[NSMutableSet setWithArray:allFriendsFBIDs]];
         NSLog(@"Using new method, %d", [set count]);
         */
        
        /*
         if ([listOfAttendingFriends count] != 0)
         {
         NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
         [listOfAttendingFriends sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
         }
         */
        
        
        [self.spinner stopAnimating];
        
        //if ([temporaryFriendsArray count] == 0)
        if ([allFriendsFBIDs count] == 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"None Attending" message:@"None of your friends are attending this event." delegate:self cancelButtonTitle:@"Go Back" otherButtonTitles:nil];
            alert.delegate = self;
            [alert show];
        }
        
        //Setting global array to temporary friends array
        listOfAttendingFriends = [NSArray arrayWithArray:temporaryFriendsArray];
        //listOfAttendingFriends = [NSArray arrayWithArray:[allFriendsFBIDs allObjects]];
        NSLog(@"Setting global to temporary array!");
        
        //Reloading data
        [self.tableView reloadData];
        
        /* });
         dispatch_release(downloadFriendsAttendingQ);
         */
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
    
    //cell = [[UITableViewCell alloc] init]; //WithStyle:UITableViewCellSty reuseIdentifier:<#(NSString *)#>
    cell = [[FriendCell alloc] init];
    cell.textLabel.text = [[listOfAttendingFriends objectAtIndex:indexPath.row] valueForKey:@"name"];
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
