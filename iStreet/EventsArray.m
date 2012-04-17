//
//  EventsArray.m
//  iStreet
//
//  Created by Rishi on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventsArray.h"

@implementation EventsArray

@synthesize date, array;

- (id)initWithDate:(NSString *)eventsDate
{
    self = [super init];
    [self setDate:eventsDate];
    [self setArray:[NSMutableArray array]];
    return self;
}

- (void)addEvent:(Event *)e
{
    NSString *eventDate = [e.time_start substringToIndex:[e.time_start rangeOfString:@" "].location];
    if ([eventDate isEqualToString:[self date]])
        [self.array addObject:e];
    else
        [NSException raise:@"Invalid argument exception" format:@"Mismatched date"];
}

@end
