//
//  Club+Create.h
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//

#import "Club.h"

@interface Club (Create)

// Return the club entity with the given data (clubs are unique based on the club_id key)
+ (Club *)clubWithData:(NSDictionary *)clubData;

@end
