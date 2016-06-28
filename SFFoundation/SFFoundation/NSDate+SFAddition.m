//
//  NSDate+SFAddition.m
//  SFFoundation
//
//  Created by yangzexin on 13-8-2.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "NSDate+SFAddition.h"

@implementation NSDate (SFAddition)

- (NSDateComponents *)sf_componentsUsingCurrentCalendar {
    NSCalendar *calender = [NSCalendar currentCalendar];
    return [calender components:NSYearCalendarUnit
            | NSMonthCalendarUnit
            | NSDayCalendarUnit
            | NSHourCalendarUnit
            | NSMinuteCalendarUnit
            | NSSecondCalendarUnit
            | NSWeekCalendarUnit
            | NSEraCalendarUnit
            | NSWeekdayCalendarUnit
            | NSWeekdayOrdinalCalendarUnit
            | NSQuarterCalendarUnit
            | NSWeekOfMonthCalendarUnit
            | NSWeekOfYearCalendarUnit
            | NSYearForWeekOfYearCalendarUnit
            | NSCalendarCalendarUnit
            | NSTimeZoneCalendarUnit fromDate:self];
}

- (NSInteger)sf_numberOfDayIntervalsByComparingWithDate:(NSDate *)date {
    return [self sf_numberOfDayIntervalsByComparingWithDate:date usingZeroHourDate:NO];
}

- (NSInteger)sf_numberOfDayIntervalsWithDate:(NSDate *)date {
    return [self sf_numberOfDayIntervalsWithDate:date usingZeroHourDate:NO];
}

- (NSDate *)sf_zeroHourDate {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *dateString = [dateFormatter stringFromDate:self];
    NSDate *beginningOfDate = [dateFormatter dateFromString:dateString];
    
    return beginningOfDate;
}

- (NSInteger)sf_numberOfDayIntervalsByComparingWithDate:(NSDate *)date usingZeroHourDate:(BOOL)usingZeroHourDate {
    NSDate *date1 = self;
    NSDate *date2 = date;
    if (usingZeroHourDate) {
        date1 = [date1 sf_zeroHourDate];
        date2 = [date2 sf_zeroHourDate];
    }
    NSTimeInterval time1 = [date1 timeIntervalSince1970];
    NSTimeInterval time2 = [date2 timeIntervalSince1970];
    NSTimeInterval timeInterval = time1 - time2;
    
    NSInteger numberOfDays = timeInterval / 86400.0f;
    
    return numberOfDays;
}

- (NSInteger)sf_numberOfDayIntervalsWithDate:(NSDate *)date usingZeroHourDate:(BOOL)usingZeroHourDate {
    NSInteger numberOfDays = [self sf_numberOfDayIntervalsByComparingWithDate:date usingZeroHourDate:usingZeroHourDate];
    if (numberOfDays < 0) {
        numberOfDays = 0 - numberOfDays;
    }
    
    return numberOfDays;
}

- (NSDate *)sf_dateByAddingNumberOfDays:(NSInteger)numberOfDays {
    return [self dateByAddingTimeInterval:numberOfDays * 86400];
}

- (NSDate *)sf_monthBeginDate {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    
    return [dateFormatter dateFromString:[dateFormatter stringFromDate:self]];
}

@end

@implementation NSDate (SFDateString)

- (NSString *)sf_yyyyMMddHHmmss_timeString {
    return [self sf_timeStringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
}

- (NSString *)sf_timeStringWithFormat:(NSString *)format {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:format];
    
    return [dateFormatter stringFromDate:self];
}

@end

