//
//  MapViewController.m
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//

#import "ClubsViewController.h"
#import "Club.h"
#import "Club+Create.h"
#import "ClubEventsViewController.h"
#import "AppDelegate.h"

@interface ClubsViewController ()

@end

@implementation ClubsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    self.view.backgroundColor = orangeTableColor;
    
    // Format Data label at bottom
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMMM d"];
    NSString *dateString = [dateFormat stringFromDate:date];
    dateLabel.text = dateString;
    [dateLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:18.0]];  
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

// Restrict orientation to portrait
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

//Prepare to segue to appropriate Club screen
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *clubName = segue.identifier;
    [segue.destinationViewController setClubName:clubName];
}

@end
