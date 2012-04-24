//
//  MapViewController.m
//  iStreet
//
//  Created by Rishi on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ClubsViewController.h"
#import "Club.h"
#import "Club+Create.h"
#import "ClubEventsViewController.h"
#import "AppDelegate.h"

@interface ClubsViewController ()

@end

@implementation ClubsViewController
//@synthesize datelabel = _datelabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //https://fed.princeton.edu
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    //NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString: @"https://fed.princeton.edu" ]];
    NSLog(@"BEGIN COOKIES!");
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM d, yyyy h:mm a"];
    for(NSHTTPCookie *cookie in cookies)
    {
        NSString *date = [formatter stringFromDate:cookie.expiresDate];
        NSLog(@"comment: %@\n value: %@\ndomain: %@\npath:%@\nexpires:%@", [cookie comment], [cookie value], cookie.domain, cookie.path, date);
    }
    
    
	// Do any additional setup after loading the view.
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMMM d"];
    NSString *dateString = [dateFormat stringFromDate:date];
    //self.datelabel.text = dateString;
    dateLabel.text = dateString;
    [dateLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:18.0]];  

    //Get all clubs from Core Data
    BOOL dataDidLoad = [(AppDelegate *)[[UIApplication sharedApplication] delegate] appDataLoaded];
    
    if(!dataDidLoad)
    {
        NSLog(@"Setting up notifications.");
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData:) name:@"App Data Loaded" object:nil];
    }
    else
    {
        NSLog(@"No need for notification, data already loade.");
        [self loadData:nil];
    }
}
- (void)loadData:(NSNotification *)notification
{
    UIManagedDocument *document = [(AppDelegate *)[[UIApplication sharedApplication] delegate] document];
    
    if(notification)
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Club"];                
    NSError *error;
    
    NSArray *clubsArray = [document.managedObjectContext executeFetchRequest:request error:&error];
    [self setClubListWithNewData:clubsArray];
    NSLog(@"Finished loading core data.");
    
}
- (void)setClubListWithNewData:(NSArray *)clubData;
{
    clubsList = [NSMutableArray array];
    for (int i = 0; i < [clubData count]; i++) {
        Club *c = (Club *)[clubData objectAtIndex:i];
        if (![clubsList containsObject:c]) {
            [clubsList addObject:c];
        }
    }
}
- (void)viewDidUnload
{
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
    NSLog(@"\n\nSegue ID: %@\n\n", segue.identifier);
    NSString *clubName = segue.identifier;
    for (Club *club in clubsList){
        if ([club.name isEqualToString:clubName]){
            [segue.destinationViewController setClub:(club)];
            NSLog(@"Destination club: %@\n", club.name);
        }
    }
}

@end
