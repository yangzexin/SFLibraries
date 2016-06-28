//
//  NSDate+SFAddition.h
//  SFFoundation
//
//  Created by yangzexin on 13-8-2.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (SFAddition)

- (NSDateComponents *)sf_componentsUsingCurrentCalendar;

- (NSInteger)sf_numberOfDayIntervalsByComparingWithDate:(NSDate *)date;
- (NSInteger)sf_numberOfDayIntervalsWithDate:(NSDate *)date;

/**
 返回比较的间隔天数，可能是负数
 */
- (NSInteger)sf_numberOfDayIntervalsByComparingWithDate:(NSDate *)date usingZeroHourDate:(BOOL)usingZeroHourDate;

/**
 返回间隔天数
 */
- (NSInteger)sf_numberOfDayIntervalsWithDate:(NSDate *)date usingZeroHourDate:(BOOL)usingZeroHourDate;

- (NSDate *)sf_zeroHourDate;

- (NSDate *)sf_dateByAddingNumberOfDays:(NSInteger)numberOfDays;
- (NSDate *)sf_monthBeginDate;

@end

@interface NSDate (SFDateString)

// yyyy-MM-dd HH:mm:ss
- (NSString *)sf_yyyyMMddHHmmss_timeString;

- (NSString *)sf_timeStringWithFormat:(NSString *)format;

@end
