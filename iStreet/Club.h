//
//  Club.h
//  iStreet
//
//  Created by Alexa Krakaris on 4/11/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Club : NSObject

@property(nonatomic, assign) int ID;
@property(nonatomic, retain) NSString *clubName;
@property(nonatomic, retain) UIImage *clubCrest;
//@property(nonatomic, retain) NSMutableArray *events;


- (id)initWithDictionary:(NSDictionary *)dict;
-(id)init;

@end