//
//  Event+Create.m
//  iStreet
//
//  Created by Rishi on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Event+Accessors.h"
#import "Club.h"
#import "AppDelegate.h"

@implementation Event (Accessors)

// Return the event entity with the given data (events are unique based on the event_id key)
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

// Get the event's start date stripped of the time
- (NSString *)stringForStartDate
{
    //time_start is stored as yyyy-MM-dd HH:mm:ss (from server)
    if(!self.time_start)
        return @"";
    
    return [self.time_start substringToIndex:[self.time_start rangeOfString:@" "].location];
}

// Get the full entry description for the event
- (NSString *)fullEntryDescription
{
    static NSString *pass = @"Pa";
    static NSString *puid = @"Pu";
    static NSString *member = @"Mp";
    static NSString *list = @"Gu";
    //static NSString *custom = @"Cu"; <-- not used in code
    
    NSString *entry = self.entry;
    NSString *entryDescription = nil;
    
    if (self.entry_description)
        entryDescription = self.entry_description;
    else
        entryDescription = @"";
    
    if ([entry isEqualToString:puid])
        return @"PUID";
    
    if ([entry isEqualToString:pass]) 
        if (![entryDescription isEqualToString:@""]) 
            return [NSString stringWithFormat:@"Pass: %@", entryDescription];
        else
            return @"Pass";
    
    if ([entry isEqualToString:member])
        if (![entryDescription isEqualToString:@""])
            return [NSString stringWithFormat:@"Members plus %@", entryDescription];
        else
            return @"Members plus";
    
    if ([entry isEqualToString:list])
        return @"Guest list";
    
    // if this line is reached, entry is "Cu", or custom.
    return entryDescription;
}

@end
