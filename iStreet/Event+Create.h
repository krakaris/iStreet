//
//  Event+Create.h
//  iStreet
//
//  Created by Rishi on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Event.h"

@interface Event (Create)

+ (Event *)eventWithData:(NSDictionary *)eventData;

@end