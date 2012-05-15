//
//  ClubEventsViewController.m
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//

#import "ClubEventsViewController.h"
#import "Event.h"
#import "Event+Accessors.h"
#import "EventCell.h"
#import "EventDetailsViewController.h"
#import "AppDelegate.h"
#import "User.h"

@interface ClubEventsViewController ()

@end

@implementation ClubEventsViewController

@synthesize clubName;

// Set up the view
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.clubName;
    self.view.backgroundColor = orangeTableColor;
}

// Customize cells for club events (show entry description, since the default cell shows the club)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventCell *cell = (EventCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    Event *event = [self eventAtIndexPath:indexPath];
    cell.detailTextLabel.text = [event fullEntryDescription];
    
    return cell;
}

#pragma mark Required methods to subclass EventsViewController

// Return core data events for this club
- (NSArray *)getCoreDataEvents
{
    UIManagedDocument *document = [(AppDelegate *)[[UIApplication sharedApplication] delegate] document];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];    
    request.predicate = [NSPredicate predicateWithFormat:@"name == %@", self.clubName];

    NSArray *events = [document.managedObjectContext executeFetchRequest:request error:NULL];
    
    return events;
}

// Send the request for events for this club
- (void)requestServerEventsData
{    
    //Build url for server
    NSString *relativeURL = [NSString stringWithFormat:@"/clubevents?name=%@", self.clubName];
    relativeURL = [relativeURL stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];

    ServerCommunication *sc = [[ServerCommunication alloc] init];
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:nil forViewController:self  withDelegate:self andDescription:nil];
}


@end
