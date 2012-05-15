//
//  Club.h
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Club : NSManagedObject

@property (nonatomic, retain) NSString * club_id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *whichEvents;
@end

@interface Club (CoreDataGeneratedAccessors)

- (void)addWhichEventsObject:(Event *)value;
- (void)removeWhichEventsObject:(Event *)value;
- (void)addWhichEvents:(NSSet *)values;
- (void)removeWhichEvents:(NSSet *)values;

@end
