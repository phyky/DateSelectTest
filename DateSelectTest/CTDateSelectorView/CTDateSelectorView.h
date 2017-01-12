//
//  CTDateSelectorView.h
//  CTSinglePickerView
//
//  Created by Calon Mo on 16/2/2.
//  Copyright © 2016年 gdcattsoft. All rights reserved.
//  时间选择控件，可以根据CTDatePickerShowType枚举类定制显示年、月、日、时、分的选择
//  block根据CTDatePickerShowType枚举类定制返回相应的yyyy-MM-dd HH:mm

#import <UIKit/UIKit.h>

/*控件显示类型，可以选择的时间精确度*/
typedef enum{
    SHOW_YYYY,          //只能选择年
    SHOW_YYYYMM,        //只能选择年、月
    SHOW_YYYYMMDD,      //只能选择年、月、日
    SHOW_YYYYMMDDHHmm,  //精确到分钟
    SHOW_MMDD,          //只能选择月日
    SHOW_HHmm,          //只能选择时分
    SHOW_MM,            //只能选择月
    SHOW_DD,            //只能选择日
    SHOW_HH,            //只能选择时
    SHOW_mm,            //只能选择分
}CTDatePickerShowType;

/**
 时间制式,只有显示时分才有
 */
typedef enum {
    Hour12,
    Hour24
}TimeFormat;

/**
 * 返回时间格式根据显示的格式一样，比如返回YYYY、YYYY-MM、YYYY-MM-DD、YYYY-MM-DD HH:mm
 */
typedef void (^CTDateSelectorViewFinishBlock)(NSString *selectedDate);
typedef void (^CTDateSelectorViewCancelBlock)(void);

@interface CTDateSelectorView : UIView

/**
 * 初始化函数
 * date:初始化时间，将会默认显示在控件上
 * showType:时间控件显示的格式
 */
- (instancetype)initWithShowType:(CTDatePickerShowType)showType timeFormat:(TimeFormat)timeFormat finish:(CTDateSelectorViewFinishBlock)finish cancel:(CTDateSelectorViewCancelBlock)cancel;

-(void)show;

@end
