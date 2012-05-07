//
//  ClubEventsViewController.m
//  iStreet
//
//  Created by Alexa Krakaris on 4/9/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "ClubEventsViewController.h"
#import "Event.h"
#import "Event+Create.h"
#import "EventCell.h"
#import "EventDetailsViewController.h"
#import "AppDelegate.h"
#import "User.h"

@interface ClubEventsViewController ()

@end

@implementation ClubEventsViewController

@synthesize club;

- (void)viewDidLoad
{
    self.title = self.club.name;
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:141.0/255.0 blue:17.0/255.0 alpha:1.0];
}

- (NSArray *)getCoreDataEvents
{
    UIManagedDocument *document = [(AppDelegate *)[[UIApplication sharedApplication] delegate] document];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];    
    request.predicate = [NSPredicate predicateWithFormat:@"name == %@", self.club.name];

    NSArray *events = [document.managedObjectContext executeFetchRequest:request error:NULL];
    
    return events;
}


- (void)requestServerEventsData
{    
    //Build url for server
    NSString *relativeURL = [NSString stringWithFormat:@"/clubevents?name=%@", self.club.name];
    relativeURL = [relativeURL stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];

    ServerCommunication *sc = [[ServerCommunication alloc] init];
    [sc sendAsynchronousRequestForDataAtRelativeURL:relativeURL withPOSTBody:nil forViewController:self  withDelegate:self andDescription:nil];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventCell *cell = (EventCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    Event *event = [self eventAtIndexPath:indexPath];
    cell.detailTextLabel.text = [event fullEntryDescription];
    
    return cell;
}

@end
