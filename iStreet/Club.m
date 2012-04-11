//
//  Club.m
//  iStreet
//
//  Created by Alexa Krakaris on 4/11/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "Club.h"

@implementation Club

@synthesize ID, clubName, clubCrest;

- (id)initWithDictionary:(NSDictionary *)dict
{
    [self setClubName:[dict objectForKey:@"name"]];
    [self setClubCrest:[dict objectForKey:@"poster"]];
    [self setID:[[dict objectForKey:@"club_id"] intValue]];
    
    return self;
}

-(void)setClubName:(NSString *)clubName
{
    self.clubName = clubName;
}

- (id)init
{
    self = [super init];
    return self;
}

@end

