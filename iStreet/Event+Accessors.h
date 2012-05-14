//
//  Event+Create.h
//  iStreet
//
//  Created by Rishi on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Event.h"

@interface Event (Accessors)

// Return the event entity with the given data (events are unique based on the event_id key)
+ (Event *)eventWithData:(NSDictionary *)eventData;

// Get the event's start date stripped of the time
- (NSString *)stringForStartDate;
// Get the full entry description for the event
- (NSString *)fullEntryDescription;

@end
