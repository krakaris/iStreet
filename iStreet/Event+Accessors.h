//
//  Event+Create.h
//  iStreet
//
//  Created by Rishi on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Event.h"

@interface Event (Accessors)

+ (Event *)eventWithData:(NSDictionary *)eventData;

/* Get the event's start date stripped of the time */ 
- (NSString *)stringForStartDate;
- (NSString *)fullEntryDescription;

@end
