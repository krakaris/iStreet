//
//  Event+Create.m
//  iStreet
//
//  Created by Rishi on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Event+Create.h"
#import "AppDelegate.h"

@implementation Event (Create)

+ (Event *)eventWithData:(NSDictionary *)eventData
{
    int eventID = [(NSString *)[eventData objectForKey:@"event_id"] intValue];

    UIManagedDocument *document = [(AppDelegate *)[[UIApplication sharedApplication] delegate] document];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    request.predicate = [NSPredicate predicateWithFormat:@"event_id = %d", eventID];
    
    NSError *error;
    NSArray *events = [document.managedObjectContext executeFetchRequest:request error:&error];
    if([events count] > 1)
        [NSException raise:@"More than one event in core data with a given id" format:nil];
         
    Event *event;
    if ([events count] == 0) 
    {
        event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:document.managedObjectContext];
    }
    else 
        event = [events objectAtIndex:0];
    
    NSEnumerator *keyEnumerator = [eventData keyEnumerator];
    for(NSString *key in keyEnumerator)
    {
        // see Event.h for an explanation for this seemingly peculiar if-statement
        if(![key isEqualToString:@"description"])
            [event setValue:[eventData objectForKey:key] forKey:key];
        else
            [event setValue:[eventData objectForKey:key] forKey:@"event_description"];
    }
    
    return event;
}

@end
