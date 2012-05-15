//
//  User+Create.h
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//

#import "User.h"

@interface User (Create)

// Return the user entity with the given netid
+ (User *)userWithNetid:(NSString *)netid;

@end
