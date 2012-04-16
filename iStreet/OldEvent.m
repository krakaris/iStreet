//
//  Event.m
//  iStreet
//
//  Created by Alexa Krakaris on 4/10/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "Eventold.h"

@implementation Event

@synthesize ID, title, poster, startDate, startTime, endTime, name, description;

- (id)initWithDictionary:(NSDictionary *)dict
{
    if ([dict objectForKey:@"title"] == nil) {
        [self setTitle:@"On Tap"];
    } else {
        [self setTitle:[dict objectForKey:@"title"]];
    }
    if ([dict objectForKey:@"poster"] == nil) {
        [self setPoster:@"Crest"];
    } else {
        [self setPoster:[dict objectForKey:@"poster"]];
    }
    if ([dict objectForKey:@"description"] == nil) {
        [self setDescription:@"On Tap"];
    } else {
        [self setDescription:[dict objectForKey:@"description"]];
    }
    //Initialize startDate and startTime and endTime
    NSString *startTimeString = [dict objectForKey:@"time_start"];
    NSString *endTimeString = [dict objectForKey:@"time_end"];
    
    NSArray *startDateComps = [startTimeString componentsSeparatedByString:@" "];
    NSArray *endDateComps = [endTimeString componentsSeparatedByString:@" "];
    
    //Separate Start date from start time and end time strings
    NSString *dateString = [startDateComps objectAtIndex:0];
    NSString *sTimeString = [startDateComps objectAtIndex:1];
    NSString *eTimeString = [endDateComps objectAtIndex:1];
    
    [self setName:[dict objectForKey:@"name"]];
    [self setStartDate:dateString];
    [self setStartTime:sTimeString];
    [self setEndTime:eTimeString];
        
        
    [self setID:[[dict objectForKey:@"id"] intValue]];
    return self;
}


@end
