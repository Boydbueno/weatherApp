//
//  Weather.h
//  WeatherHistory
//
//  Created by Nigelbueno on 23-08-15.
//  Copyright (c) 2015 boydbueno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Weather : NSManagedObject

@property (nonatomic, retain) NSDate * dt;
@property (nonatomic, retain) NSString * lat;
@property (nonatomic, retain) NSString * lon;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * temperature;
@property (nonatomic, retain) NSString * type;

@end
