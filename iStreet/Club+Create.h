//
//  Club+Create.h
//  iStreet
//
//  Created by Rishi on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Club.h"

@interface Club (Create)

// Return the club entity with the given data (clubs are unique based on the club_id key)
+ (Club *)clubWithData:(NSDictionary *)clubData;

@end
