//
//  EventDetailsViewController.m
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
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

//Initialize color of description view
+ (void)initialize {
    if(!lightOrangeColor)
        lightOrangeColor = [[UIColor alloc] initWithRed:255.0/255.0 green:176.0/255.0 blue:76.0/255.0 alpha:1.0];
}

// When the view appears, flash the scroll indicators in the description text view so that users can see it is scrollable
- (void) viewWillAppear:(BOOL)animated
{
    [self.descriptionText flashScrollIndicators];
}

//Navigate to a TableView screen showing all Facebook friends of the user that are attending the event. 
- (IBAction) seeFriends:(id)sender
{
    NSNumber *fbID = [(AppDelegate *)[[UIApplication sharedApplication] delegate] fbID];
    
    //Confirm that user is logged into Facebook first. Send alert if not
    if (fbID == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login" message:@"Please login using Facebook first, through the Friends tab." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]; 
        alert.tag = loginAlertViewAlert;
        
        [alert show];
    }
    //Otherwise show all friends. Segue to See Friends Attending VC
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

// Prompt user to either login to Facebook to see all friends attending the event, or cancel.
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
        }
    }
}

#pragma mark - Set up UI details

//Set up UI; style and layout.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set appropriate colors and view
    [self.view setBackgroundColor:orangeTableColor];
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

//Format the dates and times appropriately
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

// Release any retained subviews of the main view.
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
}

//Restrict orientation to portrait
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Attend button

//Add (or remove) the Event to the user's list of events, based on whether the event already exists in the user's list or not
//Remove event (unattend) if it already exists; add it if the event does not (Attend)
- (IBAction)attend:(UIButton *)sender 
{
    ServerCommunication *sc = [[ServerCommunication alloc] init];
    NSString *post = [NSString stringWithFormat:@"event_id=%@", self.myEvent.event_id];
    
    //Hide the button until data requests have finished completing (sending attend event info back to server and Core Data)
    [attendButton setHidden:YES];
    [toggleAttendingIndicator startAnimating];
    
    //If the user had already planned on attending and pressed "Unattend" button, remove this event from his/her list
    if (userIsAttending) 
    {    
        [sc sendAsynchronousRequestForDataAtRelativeURL:@"/unattendEvent" withPOSTBody:post forViewController:self withDelegate:self andDescription:@"unattend"];
    }
    //Otherwise, add this event to his/her list of events
    else 
    {
        [sc sendAsynchronousRequestForDataAtRelativeURL:@"/attendEvent" withPOSTBody:post forViewController:self withDelegate:self andDescription:@"attend"];
    }
    
}

//Complete connection to either add or remove event 
- (void)connectionWithDescription:(NSString *)description finishedReceivingData:(NSData *)data
{
    [attendButton setHidden:NO];
    [toggleAttendingIndicator stopAnimating];
    if(![[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] isEqualToString:@"SUCCESS"])
        return;
    
    //Add event to user's events
    if([description isEqualToString:@"attend"])
    {
        [user addAttendingEventsObject:myEvent];
        userIsAttending = YES;
        [attendButton setTitle:@"Unattend" forState:UIControlStateNormal];
    }
    //remove event from user's list
    else if ([description isEqualToString:@"unattend"])
    {
        [user removeAttendingEventsObject:myEvent];
        userIsAttending = NO;
        [attendButton setTitle:@"Attend" forState:UIControlStateNormal];
    }
}

// If the connection failed, alert the user.
- (void)connectionFailed:(NSString *)description
{
    [attendButton setHidden:NO];
    [toggleAttendingIndicator stopAnimating];
    
    [[[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"There was a problem connecting to the server. If the error persists, make sure you are connected to the internet." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
}

//Navigate to TableView showing all friends attending teh event. Set the event to current event. 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SeeFriendsAttendingTableViewController *seeFriendsController = (SeeFriendsAttendingTableViewController *)[segue destinationViewController];
    seeFriendsController.eventID = myEvent.event_id;    
}


@end
