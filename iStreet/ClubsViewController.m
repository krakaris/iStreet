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
    
    [self getClubsData];
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

-(void)getClubsData
{
    NSString *url = @"http://istreetsvr.herokuapp.com/clubslist";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn)
        receivedData = [NSMutableData data];
    NSLog(@"get clubs data\n");

}
/*
 Runs when the sufficient server response data has been received.
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{  
    [receivedData setLength:0];
    NSLog(@"Connection received response\n");
}  

/*
 Runs as the connection loads data from the server.
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data  
{  
    [receivedData appendData:data];
    NSLog(@"connection received data\n");
} 

/*
 Runs when the connection has successfully finished loading all data
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Finish loading\n");
    NSError *error;
    NSArray *clubsDictionaryArray = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:&error];
    if(!clubsDictionaryArray)
    {
        NSLog(@"%@", [error localizedDescription]);
        return;
    }
    //NSMutableArray *clubsArray = [NSMutableArray arrayWithCapacity:[clubsDictionaryArray count]];
    
    for(NSDictionary *dict in clubsDictionaryArray)
        [clubsList addObject:[Club clubWithData:dict]];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /*Club *club = [Club alloc];
    //[club setName:segue.identifier];
    club.name = segue.identifier;
     */
    NSLog(@"\n\nSegue ID: %@\n\n", segue.identifier);
    NSString *clubName = segue.identifier;
    for (Club *club in clubsList){
        if ([club.name isEqualToString:clubName]){
            [segue.destinationViewController setClub:(club)];
            NSLog(@"Destination club: %@\n", club.name);
        }
    }
    
    //[segue.destinationViewController setClub:(club)];
    
}

@end
