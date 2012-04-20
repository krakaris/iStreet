//
//  Event+Create.m
//  iStreet
//
//  Created by Rishi on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Event+Create.h"
#import "Club.h"
#import "AppDelegate.h"

@implementation Event (Create)

+ (Event *)eventWithData:(NSDictionary *)eventData
{
    NSString *eventIDString = [eventData objectForKey:@"event_id"];
    
    if(!eventIDString)
        [NSException raise:@"No event_id key in eventData dictionary as argument to [Event -eventWithData]" format:nil];
    
    UIManagedDocument *document = [(AppDelegate *)[[UIApplication sharedApplication] delegate] document];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    request.predicate = [NSPredicate predicateWithFormat:@"event_id == %@", eventIDString];
    
    NSError *error;
    NSArray *events = [document.managedObjectContext executeFetchRequest:request error:&error];
    if([events count] > 1)
        [NSException raise:@"More than one event in core data with a given id" format:@""];
    
    Event *event;
    if ([events count] == 0) 
        event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:document.managedObjectContext];
    else 
        event = [events objectAtIndex:0];
    
    NSEnumerator *keyEnumerator = [eventData keyEnumerator];
    for(NSString *key in keyEnumerator)
    {
        // see Event.h for an explanation for this seemingly peculiar if-statement
        if([key isEqualToString:@"description"])
            [event setValue:[eventData objectForKey:key] forKey:@"event_description"];
        else
            [event setValue:[eventData objectForKey:key] forKey:key];
    }
    
    NSString *clubName = [event name];
    if(clubName)
    {
        request = [NSFetchRequest fetchRequestWithEntityName:@"Club"];
        request.predicate = [NSPredicate predicateWithFormat:@"name == %@", clubName];
        Club *club = [[document.managedObjectContext executeFetchRequest:request error:&error] lastObject];
        [event setWhichClub:club];
        // The Core Data framework automatically keeps relationships consistent, so the following line is unnecessary (but valid)
        //[club addWhichEventsObject:event];
    }
    
    return event;
}

/* Get the event's start date stripped of the time */ 
- (NSString *)stringForStartDate
{
    //time_start is stored as yyyy-MM-dd HH:mm:ss (from server)
    return [self.time_start substringToIndex:[self.time_start rangeOfString:@" "].location];
}

@end
