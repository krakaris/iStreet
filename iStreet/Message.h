//
//  Message.h
//  iStreet
//
//  Alexa Krakaris, Akarshan Kumar, and Rishi Narang - COS 333 Spring 2012
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

@property(nonatomic, assign) int ID;
@property(nonatomic, retain) NSString *user;
@property(nonatomic, retain) NSString *message;
@property(nonatomic, retain) NSString *timestamp;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
