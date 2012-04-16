//
//  Club.h
//  iStreet
//
//  Created by Akarshan Kumar on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Club : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * imageURL;

@end
