//
//  Event.h
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Club, User;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * entry;
@property (nonatomic, retain) NSString * entry_description;
@property (nonatomic, retain) NSString * event_description;
@property (nonatomic, retain) NSString * event_id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * poster;
@property (nonatomic, retain) NSData * posterImageData;
@property (nonatomic, retain) NSString * rank;
@property (nonatomic, retain) NSString * time_end;
@property (nonatomic, retain) NSString * time_start;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *usersAttending;
@property (nonatomic, retain) Club *whichClub;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addUsersAttendingObject:(User *)value;
- (void)removeUsersAttendingObject:(User *)value;
- (void)addUsersAttending:(NSSet *)values;
- (void)removeUsersAttending:(NSSet *)values;

@end
