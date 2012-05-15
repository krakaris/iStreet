//
//  User.h
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * fav_friends_commasep;
@property (nonatomic, retain) NSString * fb_friends;
@property (nonatomic, retain) NSNumber * fb_id;
@property (nonatomic, retain) NSString * netid;
@property (nonatomic, retain) NSSet *attendingEvents;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addAttendingEventsObject:(Event *)value;
- (void)removeAttendingEventsObject:(Event *)value;
- (void)addAttendingEvents:(NSSet *)values;
- (void)removeAttendingEvents:(NSSet *)values;

@end
