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
        [self.array addObject:event];
    else
        [NSException raise:@"Invalid argument exception" format:@"Mismatched date"];
}

@end
