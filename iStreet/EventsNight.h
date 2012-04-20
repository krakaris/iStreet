//
//  EventsArray.h
//  iStreet
//
//  Created by Rishi on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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
