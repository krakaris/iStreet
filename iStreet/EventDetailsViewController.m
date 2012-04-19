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
@synthesize eventDescription;
@synthesize eventImage;
@synthesize attending;
@synthesize attendButton;
@synthesize seeAllFriendsAttending;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.title = myEvent.title;
    self.eventTitle.text = myEvent.title;
    [self setUserWithNetid];
    friendsList = [user.fb_friends componentsSeparatedByString:@","];
    if ([user.attendingEvents containsObject:myEvent]) {
        userIsAttending = YES;
        //hide the button
        attendButton.enabled = NO;
        attendButton.hidden = YES;
        self.attending.text = [NSString stringWithFormat: @"You are attending %@!", myEvent.title];
    } else {
        userIsAttending = NO;
        attendButton.enabled = YES;
        attendButton.hidden = NO;
    }
    
    // Fix date and time strings
    [self formatDates];
    
    self.eventDescription.text = myEvent.event_description;
    CGSize maximumLabelSize = CGSizeMake(280,200);
    
    CGSize expectedLabelSize = [self.eventDescription.text sizeWithFont:self.eventDescription.font 
                                                      constrainedToSize:maximumLabelSize 
                                                          lineBreakMode:UILineBreakModeWordWrap]; 
    
    //adjust the label the the new height.
    CGRect newFrame = self.eventDescription.frame;
    newFrame.size.height = expectedLabelSize.height;
    self.eventDescription.frame = newFrame;
    
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
    //timeString = [timeString stringByAppendingString:@"am"];
    
    self.eventTime.text = timeString;
    
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
    [self setEventDescription:nil];
    [self setEventImage:nil];
    [self setAttending:nil];
    [self setAttendButton:nil];
    [self setSeeAllFriendsAttending:nil];
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
    /*if([segue.identifier isEqualToString:@"See Friends Attending Event"]) {
     [segue.destinationViewController setFriendsList:(friendsList)];
     [segue.destinationViewController setUser:user];
     [segue.destinationViewController setEvent:myEvent];
     }*/
}


@end
