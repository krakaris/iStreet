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

- (void)connectionWithDescription:(NSString *)description finishedReceivingData:(NSData *)data
{
    [super connectionWithDescription:description finishedReceivingData:data];
    _serverLoadedOnce = YES;
}

- (void)connectionFailed:(NSString *)description
{
    if([[self.navigationItem.rightBarButtonItem tintColor] isEqual:[UIColor redColor]])
        return; 
    
    [[[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"There was a problem retrieving the latest event information. If the error persists, make sure you are connected to the internet" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
    
    [super connectionFailed:description];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   // if(_serverLoadedOnce)
    //{
      //  NSLog(@"repeat request");
    [self requestServerEventsData];
    //}
}


@end
