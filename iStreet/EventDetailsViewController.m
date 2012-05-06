//
//  EventDetailsViewController.m
//  iStreet
//
//  Created by Alexa Krakaris on 4/14/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "AppDelegate.h"

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
@synthesize seeAllFriendsAttending;
@synthesize eventEntry, toggleAttendingIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.descriptionText flashScrollIndicators];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:150.0/255.0 blue:50.0/255.0 alpha:1.0]];
    //green - 179, blue - 76
    [self.descriptionText setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:176.0/255.0 blue:76.0/255.0 alpha:1.0]];
    
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
    
    self.descriptionText.text = myEvent.event_description;
    //self.seeAllFriendsAttending.titleLabel.textColor = [UIColor orangeColor];
    
    // Fix date and time strings
    [self formatDates];
    
    //Set entry and entry description
    eventEntry.text = [self setEntry:myEvent];
    
    //Set "Attending"/"Unattending" Button
    //attendButton.titleLabel.textColor = [UIColor orangeColor];
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
-(NSString *)setEntry:(Event *)event {
    NSString *entry = event.entry;
    NSString *entry_descrip;
    if (event.entry_description) {
        entry_descrip = event.entry_description;
    } else {
        entry_descrip = @"";
    }
    NSString *pass = [NSString stringWithFormat:@"Pa"];
    NSString *puid = [NSString stringWithFormat:@"Pu"];
    NSString *member = [NSString stringWithFormat:@"Mp"];
    NSString *list = [NSString stringWithFormat:@"Gu"];
    NSString *custom = [NSString stringWithFormat:@"Cu"];
    
    NSString *entry_final;
    if ([entry isEqualToString:puid]) {
        entry_final = @"PUID";
    } else if ([entry isEqualToString:pass]) {
        entry_final = @"Pass";
        // Look at description to get color
        if (![entry_descrip isEqualToString:@""]) {
            entry_final = [entry_final stringByAppendingString:@": "];
            entry_final = [entry_final stringByAppendingString:entry_descrip];
        }
    } else if ([entry isEqualToString:member]) {
        entry_final = @"Members plus";
        // Search entry_description for a number: entry is members + this number
        if (![entry_descrip isEqualToString:@""]) {
            entry_final = [entry_final stringByAppendingString:@" "];
            entry_final = [entry_final stringByAppendingString:entry_descrip];
        }
    } else if ([entry isEqualToString:list]) {
        entry_final = @"Guest List";
    } else if ([entry isEqualToString:custom]) {
        entry_final = entry_descrip;
    }
    return entry_final;
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
- (void)setUserWithNetid {
    //How to access netid from AppDelegate??
    //NSString *id = @"netid";
    
    UIManagedDocument *document = [(AppDelegate *)[[UIApplication sharedApplication] delegate] document];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    //request.predicate = [NSPredicate predicateWithFormat:@"netid == %@", id];
    
    NSError *error;
    NSArray *users = [document.managedObjectContext executeFetchRequest:request error:&error];
    if([users count] > 1)
        [NSException raise:@"More than one user in core data with a given netid" format:nil];
    if([users count] == 0)
        [NSException raise:@"User does not exist!" format:nil];
    
    for (User *u in users) {
        user = u;
    }
}

- (void)viewDidUnload
{
    [self setEventImage:nil];
    [self setEventTitle:nil];
    [self setEventDate:nil];
    [self setEventTime:nil];
    [self setEventImage:nil];
    [self setAttendButton:nil];
    [self setSeeAllFriendsAttending:nil];
    [self setDescriptionText:nil];
    [self setEventEntry:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

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
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"\n\nSegue ID: %@\n\n", segue.identifier);

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
