//
//  TempEvent.m
//  iStreet
//
//  Created by Rishi on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TempEvent.h"

@implementation TempEvent

@synthesize eventId, name, title, timeStart, poster;

- (id)initWithDictionary:(NSDictionary *)dict
{
    [self setEventId:[(NSString *)[dict objectForKey:@"event_id"] intValue]];
    [self setName:[dict objectForKey:@"name"]];
    [self setTitle:[dict objectForKey:@"title"]];
    [self setTimeStart:[dict objectForKey:@"time_start"]];
    [self setPoster:[dict objectForKey:@"poster"]];
    [self setIcon:nil];
    
    return self;
}

@end
