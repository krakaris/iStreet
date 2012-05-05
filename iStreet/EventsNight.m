//
//  EventsArray.m
//  iStreet
//
//  Created by Rishi on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventsNight.h"
#import "Event+Create.h"

@implementation EventsNight

@synthesize date, array;

- (id)initWithDate:(NSString *)eventsDate
{
    self = [super init];
    [self setDate:eventsDate];
    [self setArray:[NSMutableArray array]];
    return self;
}

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
