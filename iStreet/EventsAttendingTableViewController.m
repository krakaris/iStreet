//
//  EventsAttendingTableViewController.m
//  iStreet
//
//  Created by Akarshan Kumar on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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

- (NSArray *)getCoreDataEvents
{
    [self.noUpcomingEvents setHidden:YES];
    return [NSArray array];
}

- (void)requestServerEventsData
{    
    [self.noUpcomingEvents setHidden:YES];
    //Build url for server
    NSString *relativeURL = [NSString stringWithFormat:@"/getEventsForUser?fb_id=%@", fbid];
    relativeURL = [relativeURL stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];    
    
    NSLog(@"relativeURL is %@", relativeURL);
    ServerCommunication *sc = [[ServerCommunication alloc] init];
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:nil forViewController:self withDelegate:self andDescription:nil];
    
    /*
     ServerCommunication *sc = [[ServerCommunication alloc] init];
     [sc sendAsynchronousRequestForDataAtRelativeURL:@"/eventslist" withPOSTBody:nil forViewController:self  withDelegate:self andDescription:nil];*/
}

//Delegate method of ServerCommunication - gets called if request is successful
- (void)connectionWithDescription:(NSString *)description finishedReceivingData:(NSData *)data
{
    NSLog(@"Events retrieved.");
    
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Response is %@", response);
    
    //Checking for error/empty response        
    NSRange thisRange = [response rangeOfString:@"ERROR" options:NSCaseInsensitiveSearch];
    
    if (thisRange.location != NSNotFound)
    {
        //user doesn't exist
        [self.noUpcomingEvents setHidden:NO];
        [self.noUpcomingEvents setText:[NSString stringWithFormat:@"%@ isn't using iStreet!", [[name componentsSeparatedByString:@" "] objectAtIndex:0]]];
    }
    else 
    {
        NSLog(@"Inside else!");
        
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
    
}

- (void) makeFavorite
{
    //UIManagedDocument *document = [(AppDelegate *)[[UIApplication sharedApplication] delegate] document];
    
    NSLog(@"Favorites button touched!");
    
    /*NSFetchRequest *usersRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
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
    }*/
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
    /*UIManagedDocument *document = [(AppDelegate *)[[UIApplication sharedApplication] delegate] document];
    
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *nameComponents = [name componentsSeparatedByString:@" "];
    NSString *firstname = [nameComponents objectAtIndex:0];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@'s Events", firstname];
    
    /*    //maybe do this filtering with predicates instead
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
     */
}

@end
