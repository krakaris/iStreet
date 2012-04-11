//
//  Event.m
//  iStreet
//
//  Created by Alexa Krakaris on 4/10/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "Event.h"

@implementation Event

@synthesize ID, title, poster, startDate, name;

- (id)initWithDictionary:(NSDictionary *)dict
{
    [self setTitle:[dict objectForKey:@"title"]];
    [self setPoster:[dict objectForKey:@"poster"]];
    
    //Initialize date
    NSString *dateString = [dict objectForKey:@"DATE(time_start)"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSDate *myDate = [df dateFromString: dateString];
    [self setStartDate:myDate];
    
    [self setID:[[dict objectForKey:@"id"] intValue]];
    return self;
}


@end
