//
//  EventDetailsViewController.m
//  iStreet
//
//  Created by Alexa Krakaris on 4/14/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "AppDelegate.h"
#import "User+Create.h"
#import <QuartzCore/QuartzCore.h>
#import "Event+Accessors.h"

UIColor *lightOrangeColor = nil;
//[UIColor colorWithRed:255.0/255.0 green:176.0/255.0 blue:76.0/255.0 alpha:1.0];

@interface EventDetailsViewController ()

@end

@implementation EventDetailsViewController
@synthesize myEvent;
@synthesize eventTitle;
@synthesize eventDate;
@synthesize eventTime;
@synthesize eventImage;
@synthesize attendButton;
@synthesize descriptionText;
@synthesize eventEntry, toggleAttendingIndicator;

#define loginAlertViewAlert 1

+ (void)initialize {
    if(!lightOrangeColor)
        lightOrangeColor = [[UIColor alloc] initWithRed:255.0/255.0 green:176.0/255.0 blue:76.0/255.0 alpha:1.0];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.descriptionText flashScrollIndicators];
}

- (IBAction) seeFriends:(id)sender
{
    NSNumber *fbID = [(AppDelegate *)[[UIApplication sharedApplication] delegate] fbID];
    
    
    if (fbID == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login" message:@"Please login using Facebook first, through the Friends tab." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]; 
        alert.tag = loginAlertViewAlert;
        
        [alert show];
    }
    else
    {
        NSArray *allFriends = [(AppDelegate *)[[UIApplication sharedApplication] delegate] allfbFriends];
        
        if ([allFriends count] == 0) //If logged in but friends still loading in the background
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading" message:@"Friends still loading, please try again in a bit." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else {
            [self performSegueWithIdentifier:@"SeeFriendsAttending" sender:self];
        }
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == loginAlertViewAlert)
    {
        if (buttonIndex == 0)
        {
            NSLog(@"Cancel!");
        }
        else 
        {
            NSLog(@"Login");

            
            //[self.navigationController.tabBarController setSelectedIndex:3];
            
            /*
            FriendsViewController *friendsController = (FriendsViewController *) [[self.navigationController.tabBarController.viewControllers objectAtIndex:3] rootViewController];
            [friendsController fbconnect:nil]; 
            */
        }
    }
}

#pragma mark - Set up UI details

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set appropriate colors and view
    [self.view setBackgroundColor:orangeTableColor];
    //[self.descriptionText setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:176.0/255.0 blue:76.0/255.0 alpha:1.0]];
    [self.descriptionText setBackgroundColor:lightOrangeColor];
    [self.descriptionText.layer setCornerRadius:7];
    [self setUserWithNetid];
    friendsList = [user.fb_friends componentsSeparatedByString:@","];
    
    //Set main Titles and Labels
    if (![myEvent.title isEqualToString:@""]) 
    {
        self.eventTitle.text = myEvent.title;
        self.navigationItem.title = myEvent.title;
    } else 
    {
        self.eventTitle.text = @"On Tap";
        self.navigationItem.title = @"On Tap";
    }
    self.eventTitle.lineBreakMode = UILineBreakModeWordWrap;
    self.descriptionText.text = myEvent.event_description;
    
    // Fix date and time strings
    [self formatDates];
    
    //Set entry and entry description
    eventEntry.text = [myEvent fullEntryDescription];
    
    //Set "Attending" Button
    if ([user.attendingEvents containsObject:myEvent]) 
    {
        userIsAttending = YES;
        [attendButton setTitle:@"Unattend" forState:UIControlStateNormal];
    } 
    else 
    {
        userIsAttending = NO;
        [attendButton setTitle:@"Attend" forState:UIControlStateNormal];
    }
    
    //Set image
    if (myEvent.posterImageData)
    {
        [eventImage setImage:[UIImage imageWithData:myEvent.posterImageData]];
    } else {
        NSString *imageName = [NSString stringWithFormat:@"%@.png", myEvent.name];
        eventImage.image = [UIImage imageNamed:imageName]; 
    }
    
}

- (void)formatDates {
    if (myEvent.time_start && myEvent.time_end) {
        NSString *eventDay = [myEvent.time_start substringToIndex:[myEvent.time_start rangeOfString:@" "].location];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"YYYY-MM-dd"];
        NSDate *sDate = [dateFormat dateFromString:eventDay];
        
        NSDateFormatter *newFormat = [[NSDateFormatter alloc] init];
        [newFormat setDateFormat:@"EEEE, MMMM d"];
        NSString *sDayString = [newFormat stringFromDate:sDate];
        
        self.eventDate.text = sDayString;
        
        NSString *fullStartTimeString = myEvent.time_start;
        NSString *fullEndTimeString = myEvent.time_end;
        NSDateFormatter *longFormat = [[NSDateFormatter alloc] init];
        [longFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        NSDate *fullStartDate = [longFormat dateFromString:fullStartTimeString];
        NSDate *fullEndDate = [longFormat dateFromString:fullEndTimeString];
        
        
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"h:mm a"];
        NSString *sTimeString = [outputFormatter stringFromDate:fullStartDate];
        NSString *eTimeString = [outputFormatter stringFromDate:fullEndDate];
        
        NSString *timeString = [sTimeString stringByAppendingString:@" - "];
        timeString = [timeString stringByAppendingString:eTimeString];
        
        self.eventTime.text = timeString;
    } 
    //else leave time field blank
}
- (void)setUserWithNetid 
{
    user = [User userWithNetid:[(AppDelegate *)[[UIApplication sharedApplication] delegate] netID]];
}

- (void)viewDidUnload
{
    [self setEventImage:nil];
    [self setEventTitle:nil];
    [self setEventDate:nil];
    [self setEventTime:nil];
    [self setEventImage:nil];
    [self setAttendButton:nil];
    [self setDescriptionText:nil];
    [self setEventEntry:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Attend button

- (IBAction)attend:(UIButton *)sender 
{
    ServerCommunication *sc = [[ServerCommunication alloc] init];
    NSString *post = [NSString stringWithFormat:@"event_id=%@", self.myEvent.event_id];
    
    [attendButton setHidden:YES];
    [toggleAttendingIndicator startAnimating];
    if (userIsAttending) 
    {    
        [sc sendAsynchronousRequestForDataAtRelativeURL:@"/unattendEvent" withPOSTBody:post forViewController:self withDelegate:self andDescription:@"unattend"];
    }
    else 
    {
        [sc sendAsynchronousRequestForDataAtRelativeURL:@"/attendEvent" withPOSTBody:post forViewController:self withDelegate:self andDescription:@"attend"];
    }
    
}

- (void)connectionWithDescription:(NSString *)description finishedReceivingData:(NSData *)data
{
    [attendButton setHidden:NO];
    [toggleAttendingIndicator stopAnimating];
    if(![[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] isEqualToString:@"SUCCESS"])
        return;
    
    if([description isEqualToString:@"attend"])
    {
        [user addAttendingEventsObject:myEvent];
        userIsAttending = YES;
        [attendButton setTitle:@"Unattend" forState:UIControlStateNormal];
    }
    else if ([description isEqualToString:@"unattend"])
    {
        [user removeAttendingEventsObject:myEvent];
        userIsAttending = NO;
        [attendButton setTitle:@"Attend" forState:UIControlStateNormal];
    }
}

- (void)connectionFailed:(NSString *)description
{
    [attendButton setHidden:NO];
    [toggleAttendingIndicator stopAnimating];
    
    [[[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"There was a problem connecting to the server. If the error persists, make sure you are connected to the internet." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //NSLog(@"\n\nSegue ID: %@\n\n", segue.identifier);

    SeeFriendsAttendingTableViewController *seeFriendsController = (SeeFriendsAttendingTableViewController *)[segue destinationViewController];
    seeFriendsController.eventID = myEvent.event_id;
    
    /*
    //Getting list of events from server
    //Build url for server
    NSString *relativeURL = [NSString stringWithFormat:@"/attendEvent?fb_id=%@", @"521832474"];
    relativeURL = [relativeURL stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];    
     
    NSLog(@"relativeURL is %@", relativeURL);
    ServerCommunication *sc = [[ServerCommunication alloc] init];
    //[sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:@"name=Stacey Wenjun Zhang"forViewController:self withDelegate:self andDescription:@"stacey"];
     
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:@"event_id=102" forViewController:self withDelegate:self andDescription:@"adding event 99"];
     */
    /*
     Segue to Aki's Friends TableView
     }*/
}


@end
