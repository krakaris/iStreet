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
    self.eventDate.text = myEvent.startDate;
    NSString *sTimeString = myEvent.startTime;
    NSString *timeString = [sTimeString stringByAppendingString:@"pm - "];
    timeString = [timeString stringByAppendingString:myEvent.endTime];
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
