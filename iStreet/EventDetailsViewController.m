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
@synthesize attending;
@synthesize attendButton;
@synthesize descriptionText;
@synthesize seeAllFriendsAttending;
@synthesize eventEntry;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setUserWithNetid];
    friendsList = [user.fb_friends componentsSeparatedByString:@","];
    
    //Set main Titles and Labels
    self.navigationItem.title = myEvent.title;
    if (myEvent.title != nil) {
        self.eventTitle.text = myEvent.title;
    } else {
        self.eventTitle.text = @"On Tap";
    }
    self.descriptionText.text = myEvent.event_description;
    // Fix date and time strings
    [self formatDates];
    
    //Set entry and entry description
    eventEntry.text = [self setEntry:myEvent];
    
    //Set "Attending" Button/Label
    if ([user.attendingEvents containsObject:myEvent]) {
        userIsAttending = YES;
        //hide the button
        attendButton.enabled = NO;
        attendButton.hidden = YES;
        
        //FIX this
        [self.attending.text sizeWithFont:self.attending.font 
                        constrainedToSize:self.attending.frame.size
                            lineBreakMode:UILineBreakModeWordWrap]; 
        self.attending.text = [NSString stringWithFormat: @"You are attending %@!", myEvent.title];
    } else {
        userIsAttending = NO;
        attendButton.enabled = YES;
        attendButton.hidden = NO;
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
        // Search entry_description for a number: assume it is members + this number
        if (![entry_descrip isEqualToString:@""]) {
            entry_final = [entry_final stringByAppendingString:@" "];
            entry_final = [entry_final stringByAppendingString:entry_descrip];
        }
    } else if ([entry isEqualToString:list]) {
        entry_final = @"Guest List";
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
        
        //Hardcoded AM and PM --> FIX!!!
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
        NSLog(@"Number of matching users: %d\n", [users count]);
    }
}

- (void)viewDidUnload
{
    [self setEventImage:nil];
    [self setEventTitle:nil];
    [self setEventDate:nil];
    [self setEventTime:nil];
    [self setEventImage:nil];
    [self setAttending:nil];
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

- (IBAction)attend:(UIButton *)sender {
    [user addAttendingEventsObject:myEvent];
    userIsAttending = YES;
    sender.hidden = YES;
    sender.enabled = NO;
    self.attending.text = [NSString stringWithFormat: @"You are attending %@!", myEvent.title];
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"\n\nSegue ID: %@\n\n", segue.identifier);
    /*
     Segue to Aki's Friends TableView
     }*/
}


@end
