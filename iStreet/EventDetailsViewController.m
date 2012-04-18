//
//  EventDetailsViewController.m
//  iStreet
//
//  Created by Alexa Krakaris on 4/14/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "EventDetailsViewController.h"

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
    
    // Fix start date string
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
    [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *fullStartDate = [dateFormat dateFromString:fullStartTimeString];
    NSDate *fullEndDate = [dateFormat dateFromString:fullEndTimeString];

    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"h:mm"];
    NSString *sTimeString = [outputFormatter stringFromDate:fullStartDate];
     NSString *eTimeString = [outputFormatter stringFromDate:fullEndDate];

    //Hardcoded AM and PM --> FIX!!!
    NSString *timeString = [sTimeString stringByAppendingString:@"pm - "];
    timeString = [timeString stringByAppendingString:eTimeString];
    timeString = [timeString stringByAppendingString:@"am"];
    
    self.eventTime.text = timeString;
    self.eventDescription.text = myEvent.description;
        CGSize maximumLabelSize = CGSizeMake(280,130);
    
    CGSize expectedLabelSize = [self.eventDescription.text sizeWithFont:self.eventDescription.font 
        constrainedToSize:maximumLabelSize 
        lineBreakMode:UILineBreakModeWordWrap]; 
    
    //adjust the label the the new height.
    CGRect newFrame = self.eventDescription.frame;
    newFrame.size.height = expectedLabelSize.height;
    self.eventDescription.frame = newFrame;
    
        /* commented by Aki
    NSString *imageName = [NSString stringWithFormat:@"%@.png", myEvent.name];
    NSLog(@"Event club: %@\n", myEvent.name);
    NSLog(@"Image: %@\n", imageName);
    self.eventImage.image = [UIImage imageNamed:imageName];
         */
                       
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)attend:(UIButton *)sender {
    sender.hidden = YES;
    self.attending.text = [NSString stringWithFormat: @"You are attending %@!", myEvent.title];
    //[sender setBackgroundColor:(UIColor *)greenColor];
}
@end
