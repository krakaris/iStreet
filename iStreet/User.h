//
//  User.h
//  iStreet
//
//  Created by Akarshan Kumar on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * fb_friends;
@property (nonatomic, retain) NSString * fb_id;
@property (nonatomic, retain) NSString * netid;
@property (nonatomic, retain) NSString * fav_friends_commasep;
@property (nonatomic, retain) NSSet *attendingEvents;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addAttendingEventsObject:(Event *)value;
- (void)removeAttendingEventsObject:(Event *)value;
- (void)addAttendingEvents:(NSSet *)values;
- (void)removeAttendingEvents:(NSSet *)values;

@end
