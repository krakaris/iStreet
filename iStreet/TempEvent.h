//
//  TempEvent.h
//  iStreet
//
//  Created by Rishi on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// to be replace by aki's core data event object

@interface TempEvent : NSObject

@property(nonatomic, assign) int eventId;
@property(nonatomic, retain) NSString *poster;
@property(nonatomic, retain) NSString *timeStart;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) UIImage *icon;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
