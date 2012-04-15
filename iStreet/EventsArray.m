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

- (void)addEvent:(TempEvent *)e
{
    NSString *eventDate = [e.timeStart substringToIndex:[e.timeStart rangeOfString:@" "].location];
    if ([eventDate isEqualToString:[self date]])
        [self.array addObject:e];
    else
        [NSException raise:@"Invalid argument exception" format:@"Mismatched date"];
}

@end
