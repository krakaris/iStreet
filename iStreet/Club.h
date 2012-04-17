//
//  Club.h
//  iStreet
//
//  Created by Rishi on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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
