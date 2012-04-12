//
//  Event.h
//  iStreet
//
//  Created by Alexa Krakaris on 4/10/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject

@property(nonatomic, assign) int ID;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *poster;
@property(nonatomic, retain) NSString *startDate;
@property(nonatomic, retain) NSString *startTime;
@property(nonatomic, retain) NSString *endTime;
//@property(nonatomic) NSTimeInterval *duration;

//club name
@property(nonatomic, retain) NSString *name;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
