//
//  EventsArray.m
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//

#import "EventsNight.h"
#import "Event+Accessors.h"

@implementation EventsNight

@synthesize date, array;

//Initialize array of events occuring on specific date. 
- (id)initWithDate:(NSString *)eventsDate
{
    self = [super init];
    [self setDate:eventsDate];
    [self setArray:[NSMutableArray array]];
    return self;
}

//Add event to the array of Events, provided they have matching dates. 
- (void)addEvent:(Event *)event
{
    NSString *eventDate = [event stringForStartDate];
    if ([eventDate isEqualToString:[self date]])
    {
        int count = [self.array count];
        int i;
        for (i = 0; i < count; i++) 
            if([[(Event *)[self.array objectAtIndex:i] title] compare:[event title] options:NSCaseInsensitiveSearch] == NSOrderedDescending)
                break;
        
        [self.array insertObject:event atIndex:i];
    }
    else
        [NSException raise:@"Invalid argument exception" format:@"Mismatched date"];
}

@end
