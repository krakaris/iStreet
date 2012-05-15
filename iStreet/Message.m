//
//  Message.m
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//

#import "Message.h"

@implementation Message

@synthesize user, message, timestamp, ID;

// Init the message object with the values in dict
- (id)initWithDictionary:(NSDictionary *)dict
{
    [self setUser:[dict objectForKey:@"user_id"]];
    [self setMessage:[dict objectForKey:@"message"]];
    [self setTimestamp:[dict objectForKey:@"added"]];
    [self setID:[[dict objectForKey:@"id"] intValue]];
    return self;
}
@end
