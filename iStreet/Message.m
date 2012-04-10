//
//  Message.m
//  iStreet
//
//  Created by Rishi on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Message.h"

@implementation Message

@synthesize user, message, timestamp, ID;

- (id)initWithDictionary:(NSDictionary *)dict
{
    [self setUser:[dict objectForKey:@"user_id"]];
    [self setMessage:[dict objectForKey:@"message"]];
    [self setTimestamp:[dict objectForKey:@"added"]];
    [self setID:[[dict objectForKey:@"id"] intValue]];
    return self;
}
@end
