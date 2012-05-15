//
//  Event+Create.h
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
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
