//
//  EventsAttendingTableViewController.m
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//

#import "EventsAttendingTableViewController.h"
#import "Event.h"
#import "Event+Accessors.h"
#import "User+Create.h"

@interface EventsAttendingTableViewController ()

@end

@implementation EventsAttendingTableViewController

@synthesize fbid;
@synthesize name;

@synthesize favButton;
@synthesize isStarSelected;
@synthesize isAlreadyFavorite;

//Obtaining events in Core Data
- (NSArray *)getCoreDataEvents
{
    [self.noUpcomingEvents setHidden:YES];
    return [NSArray array];
}

//Request events data from server
- (void)requestServerEventsData
{    
    [self.noUpcomingEvents setHidden:YES];
    
    //Build url for server
    NSString *relativeURL = [NSString stringWithFormat:@"/getEventsForUser?fb_id=%@", fbid];
    relativeURL = [relativeURL stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];    
    
    //NSLog(@"relativeURL is %@", relativeURL);
    ServerCommunication *sc = [[ServerCommunication alloc] init];
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:nil forViewController:self withDelegate:self andDescription:nil];
}

//Delegate method of ServerCommunication - gets called if request is successful
- (void)connectionWithDescription:(NSString *)description finishedReceivingData:(NSData *)data
{
    NSLog(@"Events retrieved.");
    
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"Response is %@", response);
    
    //Checking for error/empty response        
    NSRange thisRange = [response rangeOfString:@"ERROR" options:NSCaseInsensitiveSearch];
    
    if (thisRange.location != NSNotFound) //If ERROR received -> user doesn't use the app
    {
        //user doesn't exist
        [self.noUpcomingEvents setHidden:NO];
        [self.noUpcomingEvents setText:[NSString stringWithFormat:@"%@ isn't using iStreet!", [[name componentsSeparatedByString:@" "] objectAtIndex:0]]];
    }
    else 
    {        
        NSArray *eventsDictionaryArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if(!eventsDictionaryArray)
            return;

        NSMutableArray *eventsArray = [NSMutableArray arrayWithCapacity:[eventsDictionaryArray count]];
        
        for(NSDictionary *dict in eventsDictionaryArray)
        {
            UIManagedDocument *document = [(AppDelegate *)[[UIApplication sharedApplication] delegate] document];
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
            request.predicate = [NSPredicate predicateWithFormat:@"event_id == %@", [dict objectForKey:@"event_id"]];
            
            NSArray *events = [document.managedObjectContext executeFetchRequest:request error:NULL];
        
            if([events count] > 0)
                [eventsArray addObject:[events lastObject]]; //if there is an event in core data with that id (judging by the fact that it has a title), show it on the list.
        }
        
        [self setPropertiesWithNewEventData:eventsArray];
        [self.eventsTable reloadData];
    }
}

//Delegate method of ServerCommunication - gets called if request fails
- (void) connectionFailed:(NSString *)description
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed." message:@"Failed to load Events, possibly due to lack of an internet connection. Please try again in a bit." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController  popViewControllerAnimated:YES];    
}

//Called to handle selection of favorites
- (void) makeFavorite
{   
    NSLog(@"Favorites button touched!");

    User *targetUser = [User userWithNetid:[(AppDelegate *)[[UIApplication sharedApplication] delegate] netID]];
    
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
        //NSLog(@"Star was SELected earlier, just DESELected!");
        isStarSelected = NO;
        starButton.selected = NO;
        
        if ([arrayOfFavFBFriendIDs containsObject:self.fbid])
        {
            //NSLog(@"It does contain it!");
            [arrayOfFavFBFriendIDs removeObject:self.fbid];
        }
    }
    else 
    {          
        //NSLog(@"Star was DESELected earlier, just SELected!");
        isStarSelected = YES;
        starButton.selected = YES;
        
        //NSLog(@"Adding to array!");
        
        //add current fbid to array
        [arrayOfFavFBFriendIDs addObject:self.fbid];
    }
    
    //If 0 favorite friends left
    if ([arrayOfFavFBFriendIDs count] == 0)
    {
        //NSLog(@"no favs left!");
        targetUser.fav_friends_commasep = @"";
        
        //NSLog(@"Number of elements in arrayOfFavFriends is %d", [arrayOfFavFBFriendIDs count]);
        //NSLog(@"Updated favorites list (count = 0) to %@", targetUser.fav_friends_commasep);
    }
    else if ([arrayOfFavFBFriendIDs count] == 1) //If 1 favorite friend total
    {
        targetUser.fav_friends_commasep = [NSString stringWithFormat:@"%@", [arrayOfFavFBFriendIDs lastObject]];
        
        //NSLog(@"Number of elements in arrayOfFavFriends is %d", [arrayOfFavFBFriendIDs count]);
        //NSLog(@"Updated favorites list (count = 1) to %@", targetUser.fav_friends_commasep);
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
        
        //NSLog(@"Number of elements in arrayOfFavFriends is %d", [arrayOfFavFBFriendIDs count]);
        //NSLog(@"Updated favorites list (count > 1) to %@", targetUser.fav_friends_commasep);
    }
}

//Function gets called every time ViewController is loaded.
- (void) viewWillAppear:(BOOL)animated
{
    self.isStarSelected = NO;
    
    UIImage *grayStar = [UIImage imageNamed:@"star_gray.png"];

    UIImage *orangeStar = [UIImage imageNamed:@"star_orange.png"];

    //Configuring the favorites button
    starButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [starButton setBackgroundImage:grayStar forState:UIControlStateNormal];
    [starButton setBackgroundImage:orangeStar forState:UIControlStateSelected];
    
    starButton.frame = CGRectMake(0, 0, 28, 28);
    [starButton addTarget:self action:@selector(makeFavorite) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barStarButton = [[UIBarButtonItem alloc] initWithCustomView:starButton];
    [barStarButton setStyle:UIBarButtonItemStylePlain];
    
    self.navigationItem.rightBarButtonItem = barStarButton;
    
    User *targetUser = [User userWithNetid:[(AppDelegate *)[[UIApplication sharedApplication] delegate] netID]];
    
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
}

//Gets called the first time this view is loaded.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *nameComponents = [name componentsSeparatedByString:@" "];
    NSString *firstname = [nameComponents objectAtIndex:0];
    
    //Setting the title of the bar
    self.navigationItem.title = [NSString stringWithFormat:@"%@'s Events", firstname];
}

@end
