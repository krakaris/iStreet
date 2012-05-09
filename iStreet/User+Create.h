//
//  User+Create.h
//  iStreet
//
//  Created by Rishi on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "User.h"

@interface User (Create)

+ (User *)userWithNetid:(NSString *)netid;

@end
