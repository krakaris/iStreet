//
//  Event.h
//  iStreet
//
//  Created by Rishi on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Club, User;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * entry;
@property (nonatomic, retain) NSString * entry_description;
@property (nonatomic, retain) NSString * event_description;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * poster;
@property (nonatomic, retain) NSData * posterImageData;
@property (nonatomic, retain) NSString * rank;
@property (nonatomic, retain) NSString * time_end;
@property (nonatomic, retain) NSString * time_start;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Club *whichClub;
@property (nonatomic, retain) User *usersAttending;

@end
