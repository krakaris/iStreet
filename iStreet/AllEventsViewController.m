//
//  AllEventsViewController.m
//  iStreet
//
//  Created by Rishi on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AllEventsViewController.h"
#import "AppDelegate.h"
#import "Event.h"

@interface AllEventsViewController ()

@end

@implementation AllEventsViewController

- (NSArray *)getCoreDataEvents
{
    UIManagedDocument *document = [(AppDelegate *)[[UIApplication sharedApplication] delegate] document];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];   
    
    NSArray *events = [document.managedObjectContext executeFetchRequest:request error:NULL];
        
    return events;
}

- (void)requestServerEventsData
{    
    ServerCommunication *sc = [[ServerCommunication alloc] init];
    [sc sendAsynchronousRequestForDataAtRelativeURL:@"/eventslist" withPOSTBody:nil forViewController:self  withDelegate:self andDescription:nil];
}


@end
