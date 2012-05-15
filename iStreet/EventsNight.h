//
//  EventsArray.h
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//

#import <Foundation/Foundation.h>
#import "Event.h"

/*
 An EventsNight is an array of events for a given night. It's only additional property is the date.
 */
@interface EventsNight : NSObject

@property(nonatomic, retain) NSMutableArray *array;
@property(nonatomic, retain) NSString *date;

- (id)initWithDate:(NSString *)date;
- (void)addEvent:(Event *)e;

@end
