//
//  UtilTools.h
//  PHOperationManager
//
//  Created by Dinotech on 16/4/20.
//  Copyright © 2016年 Raybon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UtilTools : NSObject

@property (nonatomic,strong) NSCalendar  *   tool_Canlendar;

@property (nonatomic,strong) NSDateComponents   *   tool_DateComponets;

@property (nonatomic,strong) NSDateFormatter    * tool_DateFormatter;

@property (nonatomic,strong) UtilTools  * utils_tool;

@property (nonatomic,strong) NSString *  tool_day;
@property (nonatomic,strong) NSString *  tool_month;
@property (nonatomic,strong) NSString *  tool_year;
@property (nonatomic,strong) NSString *  tool_weekday;
@property (nonatomic,strong) NSString *  tool_weekOfMonth;
@property (nonatomic,strong) NSString *  tool_weekOfYear;
/*!
 *  @brief 当前周所对应的年
 */
@property (nonatomic,strong) NSString *  tool_yearForWeekOfYear;


/*!
 *  @brief 传入一个日期，来获取对应的周所在的周一和周末日期
 *
 *  @param date 传入一个系统NSDate 类型的日期
 *
 *  @return 返回一个字符串区间 对应周一至周末
 */
+ (NSString *)returnTheFirstDateAndLastDateByDate:(NSDate *)date;

/*!
 *  @brief 获取当前年份中是哪一年第几周 ，返回一个数组
 *
 *  @param date 传入一个日期
 *
 *  @return 返回一个周数
 */
+ (UtilTools  *)getCurrentWeekOfYearByDate:(NSDate *)date;


+ (NSInteger )getCurrentMonthOfYearByDate:(NSDate *)date;


@end
