//
//  Message.h
//  iStreet
//
//  Created by Rishi on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

@property(nonatomic, assign) int ID;
@property(nonatomic, retain) NSString *user;
@property(nonatomic, retain) NSString *message;
@property(nonatomic, retain) NSString *timestamp;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
