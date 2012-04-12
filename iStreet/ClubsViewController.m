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
    
}

- (void)viewDidUnload
{
    Cloister = nil;
    //_datelabel = nil;
    //[self setDatelabel:nil];
    //dateLabel = nil;
    dateLabel = nil;
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
    Club *club = [Club alloc];
    [club setClubName:segue.identifier];
    //segue.identifier;
    
        NSLog(@"\n\nSegue ID: %@\n\n", segue.identifier);
    
    if(club)
    {
        [(ClubEventsViewController *)segue.destinationViewController setClub:(club)];
    }
    
}
/*
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 
 Servery *servery = [ServeryCache.instance.serveries objectForKey:segue.identifier];
 
 if(servery)
 {
 [segue.destinationViewController setServery:(servery)];
 }
 
 }
*/

/*
- (IBAction)pushCampus:(id)sender {
}

- (IBAction)pushCannon:(id)sender {
}

- (IBAction)pushCap:(id)sender {
    
}

- (IBAction)pushCharter:(id)sender {
}

- (IBAction)pushColonial:(id)sender {
}

- (IBAction)pushCottage:(id)sender {
}

- (IBAction)pushIvy:(id)sender {
}

- (IBAction)pushQuad:(id)sender {
}

- (IBAction)pushTI:(id)sender {
}

- (IBAction)pushTerrace:(id)sender {
}

- (IBAction)pushTower:(id)sender {
}
 */

@end
