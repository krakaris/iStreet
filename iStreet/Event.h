//
//  Event.h
//  iStreet
//
//  Created by Akarshan Kumar on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Club, User;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * club_name;
@property (nonatomic, retain) NSString * entry_type;
@property (nonatomic, retain) NSString * entry_descrip;
@property (nonatomic, retain) NSString * event_descrip;
@property (nonatomic, retain) NSString * startDate;
@property (nonatomic, retain) NSString * startTime;
@property (nonatomic, retain) NSString * endTime;
@property (nonatomic, retain) NSString * posterURL;
@property (nonatomic, retain) NSData * posterImageData;
@property (nonatomic, retain) NSString * rank;
@property (nonatomic, retain) NSSet *usersAttending;
@property (nonatomic, retain) Club *whichClub;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addUsersAttendingObject:(User *)value;
- (void)removeUsersAttendingObject:(User *)value;
- (void)addUsersAttending:(NSSet *)values;
- (void)removeUsersAttending:(NSSet *)values;

@end
