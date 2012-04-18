//
//  MapViewController.m
//  iStreet
//
//  Created by Rishi on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ClubsViewController.h"
#import "Club.h"
#import "ClubEventsViewController.h"
#import "AppDelegate.h"

@interface ClubsViewController ()

@end

@implementation ClubsViewController
//@synthesize datelabel = _datelabel;

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
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMMM d"];
    NSString *dateString = [dateFormat stringFromDate:date];
    //self.datelabel.text = dateString;
    dateLabel.text = dateString;
    
    //Get all clubs from Core Data
    clubs = [NSArray array];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Club"];                
    NSError *error;
    UIManagedDocument *document = [(AppDelegate *)[[UIApplication sharedApplication] delegate] document];
    clubs = [document.managedObjectContext executeFetchRequest:request error:&error];
}

- (void)viewDidUnload
{
    /*Cloister = nil;
    //_datelabel = nil;
    //[self setDatelabel:nil];
    //dateLabel = nil;
    dateLabel = nil;
     */
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /*Club *club = [Club alloc];
    //[club setName:segue.identifier];
    club.name = segue.identifier;
     */
    NSLog(@"\n\nSegue ID: %@\n\n", segue.identifier);
    NSString *clubName = segue.identifier;
    for (Club *club in clubs){
        if ([club.name isEqualToString:clubName]){
            [segue.destinationViewController setClub:(club)];
            NSLog(@"Destination club: %@\n", club.name);
        }
    }
    
    //[segue.destinationViewController setClub:(club)];
    
}

@end
