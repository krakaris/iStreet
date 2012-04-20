//
//  User.h
//  iStreet
//
//  Created by Akarshan Kumar on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * fb_friends;
@property (nonatomic, retain) NSString * fb_id;
@property (nonatomic, retain) NSString * netid;
@property (nonatomic, retain) NSSet *attendingTheseEvents;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addAttendingTheseEventsObject:(Event *)value;
- (void)removeAttendingTheseEventsObject:(Event *)value;
- (void)addAttendingTheseEvents:(NSSet *)values;
- (void)removeAttendingTheseEvents:(NSSet *)values;

@end
