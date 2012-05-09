//
//  User.h
//  iStreet
//
//  Created by Rishi on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * fav_friends_commasep;
@property (nonatomic, retain) NSString * fb_friends;
@property (nonatomic, retain) NSString * fb_id;
@property (nonatomic, retain) NSString * netid;
@property (nonatomic, retain) NSSet *attendingEvents;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addAttendingEventsObject:(Event *)value;
- (void)removeAttendingEventsObject:(Event *)value;
- (void)addAttendingEvents:(NSSet *)values;
- (void)removeAttendingEvents:(NSSet *)values;

@end
