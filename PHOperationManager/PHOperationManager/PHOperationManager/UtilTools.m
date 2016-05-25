//
//  UtilTools.m
//  PHOperationManager
//
//  Created by Dinotech on 16/4/20.
//  Copyright © 2016年 Raybon. All rights reserved.
//

#import "UtilTools.h"

@implementation UtilTools
    //返回一个区间 ，周一到周末
+ (NSString *)returnTheFirstDateAndLastDateByDate:(NSDate *)date{

    NSDate * today = date;
    NSDateFormatter *  dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];// you can use your format.

        //Week Start Date

    NSCalendar *gregorian = [[NSCalendar alloc]        initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    NSDateComponents *components = [gregorian components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:today];

    int dayofweek = [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:today] weekday];// this will give you current day of week
//    NSLog(@"day1s = %d  dayofweek = %d",[components day],dayofweek);
    [components setDay:([components day] - ((dayofweek) - 2))];// for beginning of the week.

    NSDate *beginningOfWeek = [gregorian dateFromComponents:components];
    NSDateFormatter *dateFormat_first = [[NSDateFormatter alloc] init];
    [dateFormat_first setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString2Prev;
    NSDate  *weekstartPrev;

    dateString2Prev = [dateFormat stringFromDate:beginningOfWeek];

    weekstartPrev = [dateFormat_first dateFromString:dateString2Prev];

//    NSLog(@"StartDate:%@",weekstartPrev);


        //Week End Date

    NSCalendar *gregorianEnd = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    NSDateComponents *componentsEnd = [gregorianEnd components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:today];

    int Enddayofweek = [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:today] weekday];// this will give you current day of week

    [componentsEnd setDay:([componentsEnd day]+(7-Enddayofweek)+1)];// for end day of the week

    NSDate *EndOfWeek = [gregorianEnd dateFromComponents:componentsEnd];
    NSDateFormatter *dateFormat_End = [[NSDateFormatter alloc] init];
    [dateFormat_End setDateFormat:@"yyyy-MM-dd"];
    NSString *dateEndPrev;
    NSDate *weekEndPrev;

    dateEndPrev = [dateFormat stringFromDate:EndOfWeek];
//    NSLog(@"end = %@",dateEndPrev);

    weekEndPrev = [dateFormat_End dateFromString:dateEndPrev];
//    NSLog(@"EndDate:%@",weekEndPrev);

    return [NSString stringWithFormat:@"%@至%@",dateString2Prev,dateEndPrev];
}

+ (UtilTools  *)getCurrentWeekOfYearByDate:(NSDate *)date{

    UtilTools * tools= [[UtilTools alloc]init];
    NSDateComponents * dateComponets =[tools.tool_Canlendar components:NSCalendarUnitYear| NSCalendarUnitMonth |NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekday| NSCalendarUnitDay|NSCalendarUnitWeekOfYear|NSCalendarUnitYearForWeekOfYear fromDate:date];
    
    tools.tool_year = [NSString stringWithFormat:@"%d",dateComponets.year];
    tools.tool_month = [NSString stringWithFormat:@"%d",dateComponets.month];
    tools.tool_day = [NSString stringWithFormat:@"%d",dateComponets.day];
    tools.tool_weekday = [NSString stringWithFormat:@"%d",dateComponets.weekday];
    tools.tool_weekOfMonth = [NSString stringWithFormat:@"%d",dateComponets.weekOfMonth];
    tools.tool_weekOfYear = [NSString stringWithFormat:@"%d",dateComponets.weekOfYear];
    tools.tool_yearForWeekOfYear = [NSString stringWithFormat:@"%d",dateComponets.yearForWeekOfYear];
    tools.tool_GMTTime = [NSString stringWithFormat:@"%@",@(date.timeIntervalSince1970)];
    tools.tool_TimeInterval = date.timeIntervalSince1970;

//    NSLog(@"tools = %@",tools);
    return tools;

}
static UtilTools * CreateTools(){

    static UtilTools * __tools = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __tools = [[UtilTools alloc]init];

    });
    return __tools;
}
- (UtilTools *)utils_tool{
    if (!_utils_tool) {
        _utils_tool = [[UtilTools alloc]init];

    }
    return _utils_tool;
}
- (NSCalendar *)tool_Canlendar{
    if (!_tool_Canlendar) {
        _tool_Canlendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        
    }
    return _tool_Canlendar;
}

- (NSDateFormatter *)tool_DateFormatter{
    if (!_tool_DateFormatter) {
        _tool_DateFormatter = [[NSDateFormatter alloc]init];
        _tool_DateFormatter.dateStyle = NSDateFormatterShortStyle;

    }
    return _tool_DateFormatter;
}
- (NSString *)description{
    return [NSString stringWithFormat:@"year = %@ \n month = %@ \n day = %@ \n weekday = %@ \n weekofmonth = %@ \n weekOfYear = %@ \n yearofweek = %@",self.tool_year,self.tool_month,self.tool_day,self.tool_weekday,self.tool_weekOfMonth,self.tool_weekOfYear,self.tool_yearForWeekOfYear];

}
@end
