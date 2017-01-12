//
//  CTDateSelectorView.m
//  CTSinglePickerView
//
//  Created by Calon Mo on 16/2/2.
//  Copyright © 2016年 gdcattsoft. All rights reserved.
//

#import "CTDateSelectorView.h"

#define CTContainViewHeight [[UIScreen mainScreen] bounds].size.height*2/5
#define CTPickBottomHeight 45

@interface CTDateSelectorView ()<UIPickerViewDataSource,UIPickerViewDelegate>{
    CTDateSelectorViewFinishBlock finishBlock;
    CTDateSelectorViewCancelBlock cancelBlock;
}


@property(nonatomic,assign)CTDatePickerShowType showType;

@property(nonatomic,assign)TimeFormat timeFormat;

@property(nonatomic,retain)UIView *opacityView;
@property(nonatomic,retain)UIView *containView;

@property(nonatomic,retain)UIPickerView *pickerView;

@property(nonatomic,retain)UIView *bottomView;

@property(nonatomic,retain)NSMutableArray *yearArray;
@property(nonatomic,retain)NSMutableArray *monthArray;
@property(nonatomic,retain)NSMutableArray *dayArray;
@property(nonatomic,retain)NSMutableArray *hourArray;
@property(nonatomic,retain)NSMutableArray *minuteArray;
@property(nonatomic,retain)NSMutableArray *timeFormatArray;

@property(nonatomic,assign)int selectedYear;
@property(nonatomic,assign)int selectedMonth;
@property(nonatomic,assign)int selectedDay;
@property(nonatomic,assign)int selectedHour;
@property(nonatomic,assign)int selectedMinute;
@property(nonatomic,strong)NSString *selectedTimeFormat;

@end

@implementation CTDateSelectorView

//年份列表，当前年的前100年到当前年后的50年范围
-(NSMutableArray *)yearArray{
    if(!_yearArray){
        _yearArray = [NSMutableArray array];
        NSDate *currentDate = [NSDate date];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];
        int startYear = (int)[components year]-100;
        int endYear = (int)[components year] + 50;
        for(int i=startYear;i<endYear;i++){
            NSString *year = [NSString stringWithFormat:@"%d",startYear];
            [_yearArray addObject:year];
            startYear ++;
        }
    }
    return _yearArray;
}

-(NSMutableArray *)monthArray{
    if(!_monthArray){
        _monthArray = [NSMutableArray array];
        int monthCount = 12;
        for(int i=1;i<=monthCount;i++){
            NSString *month = [NSString stringWithFormat:@"%d",i];
            [_monthArray addObject:month];
        }
    }
    return _monthArray;
}

-(NSMutableArray *)dayArray{
    if(!_dayArray || _dayArray.count <= 0){
        _dayArray = [NSMutableArray array];
        NSDateComponents *comps = [[NSDateComponents alloc]init];
        [comps setYear:self.selectedYear];
        [comps setMonth:self.selectedMonth];
        [comps setTimeZone: [NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        NSCalendar *cal = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDate *referenceTime = [cal dateFromComponents:comps];
        NSRange days = [cal rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:referenceTime];
        for(int i=0;i<days.length;i++){
            NSString *day = [NSString stringWithFormat:@"%d",i+1];
            [_dayArray addObject:day];
        }
    }
    return _dayArray;
}

-(NSMutableArray *)hourArray{
    if (self.timeFormat == Hour12 &&(self.showType == SHOW_YYYYMMDDHHmm ||self.showType == SHOW_HHmm ||self.showType == SHOW_HH)) {
        if(!_hourArray || _dayArray.count <= 0){
            _hourArray = [NSMutableArray array];
            for(int i=0;i<13;i++){
                NSString *hour = [NSString stringWithFormat:@"%d",i];
                [_hourArray addObject:hour];
            }
        }
    }else{
        if(!_hourArray || _dayArray.count <= 0){
            _hourArray = [NSMutableArray array];
            for(int i=0;i<24;i++){
                NSString *hour = [NSString stringWithFormat:@"%d",i];
                [_hourArray addObject:hour];
            }
        }
    }
    return _hourArray;
}

-(NSMutableArray *)minuteArray{
    if(!_minuteArray){
        _minuteArray = [NSMutableArray array];
        for(int i=0;i<60;i++){
            NSString *minute = [NSString stringWithFormat:@"%d",i];
            [_minuteArray addObject:minute];
        }
    }
    return _minuteArray;
}

-(NSMutableArray *)timeFormatArray{
    if(!_timeFormatArray){
        _timeFormatArray = [NSMutableArray array];
        [_timeFormatArray addObject:@"上午"];
        [_timeFormatArray addObject:@"下午"];
    }
    return _timeFormatArray;
}

- (instancetype)initWithShowType:(CTDatePickerShowType)showType timeFormat:(TimeFormat)timeFormat finish:(CTDateSelectorViewFinishBlock)finish cancel:(CTDateSelectorViewCancelBlock)cancel{
    finishBlock = finish;
    cancelBlock = cancel;
    self.showType = showType;
    self.timeFormat = timeFormat;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self = [super initWithFrame:screenBounds];
    if(self){
        self.opacityView = [[UIView alloc]initWithFrame:self.bounds];
        self.opacityView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        [self addSubview:self.opacityView];
        self.opacityView.alpha = 0;
        self.opacityView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeMySelf)];
        [self.opacityView addGestureRecognizer:tap];
        
        self.containView = [[UIView alloc]initWithFrame:CGRectMake(0,screenBounds.size.height, screenBounds.size.width, CTContainViewHeight)];
        self.containView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.containView];
        
        self.pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(10, 10, self.containView.frame.size.width-20, CTContainViewHeight-CTPickBottomHeight-30)];
        self.pickerView.layer.borderWidth = 0.5f;
        self.pickerView.layer.borderColor = [[UIColor colorWithWhite:0.7 alpha:0.7]CGColor];
        self.pickerView.delegate=self,
        self.pickerView.dataSource=self;
        self.pickerView.showsSelectionIndicator=YES;
        [self.containView addSubview:self.pickerView];
        
        self.bottomView = [[UIView alloc]initWithFrame:CGRectMake(10, self.pickerView.frame.size.height+self.pickerView.frame.origin.y+10, screenBounds.size.width-20, CTPickBottomHeight)];
        self.bottomView.layer.cornerRadius = CTPickBottomHeight/2;
        self.bottomView.layer.masksToBounds = YES;
        [self.containView addSubview:self.bottomView];
        self.bottomView.backgroundColor = [UIColor orangeColor];
        
        UIButton *cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.bottomView.frame.size.width/2, CTPickBottomHeight)];
        [cancelBtn setTitle:@"取 消" forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.bottomView addSubview:cancelBtn];
        [cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *okBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.bottomView.frame.size.width/2, 0, self.bottomView.frame.size.width/2, CTPickBottomHeight)];
        okBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [okBtn setTitle:@"确 定" forState:UIControlStateNormal];
        [self.bottomView addSubview:okBtn];
        [okBtn addTarget:self action:@selector(okBtnAction) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(self.bottomView.frame.size.width/2, 0, 0.5, CTPickBottomHeight)];
        line.backgroundColor = [UIColor whiteColor];
        [self.bottomView addSubview:line];

        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8
              initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
                  self.opacityView.alpha = 1;
                  self.containView.frame = CGRectMake(0, screenBounds.size.height-CTContainViewHeight,screenBounds.size.width, CTContainViewHeight);
              }completion:^(BOOL finished) {
                  
              }];
        
        NSDate *date = [NSDate date];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];

        self.selectedYear = (int)[components year];
        self.selectedMonth = (int)[components month];
        self.selectedDay = (int)[components day];
        self.selectedHour = (int)[components hour];
        self.selectedMinute = (int)[components minute];
        self.selectedTimeFormat = self.timeFormatArray[0];
        if (self.selectedHour>11) {
            self.selectedTimeFormat = self.timeFormatArray[1];
        }
        if (timeFormat == Hour12 &&(self.showType == SHOW_YYYYMMDDHHmm ||self.showType == SHOW_HHmm||self.showType == SHOW_HH)) {
            if (self.selectedHour >12) {
                self.selectedHour -= 12;
            }
        }
        int startYear = self.selectedYear - ((int)[components year]-100);
        
        if(self.showType == SHOW_YYYY){
            [self.pickerView selectRow:startYear inComponent:0 animated:NO];
        }else if(self.showType == SHOW_MM){
            [self.pickerView selectRow:self.selectedMonth-1 inComponent:0 animated:NO];
        }else if(self.showType == SHOW_DD){
            [self.pickerView selectRow:self.selectedDay-1 inComponent:0 animated:NO];
        }else if(self.showType == SHOW_HH){
            [self.pickerView selectRow:self.selectedHour inComponent:0 animated:NO];
        }else if(self.showType == SHOW_mm){
            [self.pickerView selectRow:self.selectedMinute-1 inComponent:0 animated:NO];
        }else if (self.showType == SHOW_YYYYMM){
            [self.pickerView selectRow:startYear inComponent:0 animated:NO];
            [self.pickerView selectRow:self.selectedMonth-1 inComponent:1 animated:NO];
        }else if (self.showType == SHOW_MMDD){
            [self.pickerView selectRow:self.selectedMonth-1 inComponent:0 animated:NO];
            [self.pickerView selectRow:self.selectedDay-1 inComponent:1 animated:NO];
        }else if (self.showType == SHOW_HHmm){
            [self.pickerView selectRow:self.selectedHour inComponent:0 animated:NO];
            [self.pickerView selectRow:self.selectedMinute-1 inComponent:1 animated:NO];
            if (self.timeFormat == Hour12) {
                [self.pickerView selectRow:[self.timeFormatArray indexOfObject:self.selectedTimeFormat] inComponent:2 animated:NO];
            }
        }else if (self.showType == SHOW_YYYYMMDD){
            [self.pickerView selectRow:startYear inComponent:0 animated:NO];
            [self.pickerView selectRow:self.selectedMonth-1 inComponent:1 animated:NO];
            [self.pickerView selectRow:self.selectedDay-1 inComponent:2 animated:NO];
        }else if (self.showType == SHOW_YYYYMMDDHHmm){
            [self.pickerView selectRow:startYear inComponent:0 animated:NO];
            [self.pickerView selectRow:self.selectedMonth-1 inComponent:1 animated:NO];
            [self.pickerView selectRow:self.selectedDay-1 inComponent:2 animated:NO];
            [self.pickerView selectRow:self.selectedHour inComponent:3 animated:NO];
            [self.pickerView selectRow:self.selectedMinute inComponent:4 animated:NO];
            if (self.timeFormat == Hour12) {
                [self.pickerView selectRow:[self.timeFormatArray indexOfObject:self.selectedTimeFormat] inComponent:5 animated:NO];
            }
        }
    }
    
    return self;
}

-(void)show{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
}

-(void)cancelBtnAction{
    if(cancelBlock){
        cancelBlock();
    }
    [self closeMySelf];
}

-(void)okBtnAction{
    NSString *result = @"";
//    if(self.showType == SHOW_YYYY){
//        int yearIndex = (int)[self.pickerView selectedRowInComponent:0];
//        result = self.yearArray[yearIndex];
//    }else if (self.showType == SHOW_YYYYMM){
//        int yearIndex = (int)[self.pickerView selectedRowInComponent:0];
//        NSString *year = self.yearArray[yearIndex];
//        int monthIndex = (int)[self.pickerView selectedRowInComponent:1];
//        int month = [self.monthArray[monthIndex]intValue];
//        result = [NSString stringWithFormat:@"%@-%02d",year,month];
//    }else if (self.showType == SHOW_YYYYMMDD){
//        int yearIndex = (int)[self.pickerView selectedRowInComponent:0];
//        NSString *year = self.yearArray[yearIndex];
//        int monthIndex = (int)[self.pickerView selectedRowInComponent:1];
//        int month = [self.monthArray[monthIndex]intValue];
//        int dayIndex = (int)[self.pickerView selectedRowInComponent:2];
//        int day = [self.dayArray[dayIndex]intValue];
//        result = [NSString stringWithFormat:@"%@-%02d-%02d",year,month,day];
//    }else if (self.showType == SHOW_YYYYMMDDHHmm){
//        int yearIndex = (int)[self.pickerView selectedRowInComponent:0];
//        NSString *year = self.yearArray[yearIndex];
//        int monthIndex = (int)[self.pickerView selectedRowInComponent:1];
//        int month = [self.monthArray[monthIndex]intValue];
//        int dayIndex = (int)[self.pickerView selectedRowInComponent:2];
//        int day = [self.dayArray[dayIndex]intValue];
//        int hourIndex = (int)[self.pickerView selectedRowInComponent:3];
//        int hour = [self.hourArray[hourIndex]intValue];
//        int minuteIndex = (int)[self.pickerView selectedRowInComponent:4];
//        int minute = [self.minuteArray[minuteIndex]intValue];
//        result = [NSString stringWithFormat:@"%@-%02d-%02d %02d:%02d",year,month,day,hour,minute];
//    }
    
    
    if(self.showType == SHOW_YYYY){
        int yearIndex = (int)[self.pickerView selectedRowInComponent:0];
        result = self.yearArray[yearIndex];
    }else if(self.showType == SHOW_MM){
        int monthIndex = (int)[self.pickerView selectedRowInComponent:0];
        int month = [self.monthArray[monthIndex] intValue];
        result = [NSString stringWithFormat:@"%02d",month];
    }else if(self.showType == SHOW_DD){
        int dayIndex = (int)[self.pickerView selectedRowInComponent:0];
        int day = [self.dayArray[dayIndex] intValue];
        result = [NSString stringWithFormat:@"%02d",day];
    }else if(self.showType == SHOW_HH){
        int hourIndex = (int)[self.pickerView selectedRowInComponent:0];
        int hour = [self.hourArray[hourIndex] intValue];
        result = [NSString stringWithFormat:@"%02d",hour];
    }else if(self.showType == SHOW_mm){
        int minuteIndex = (int)[self.pickerView selectedRowInComponent:0];
        int minute = [self.minuteArray[minuteIndex] intValue];
        result = [NSString stringWithFormat:@"%02d",minute];
    }else if (self.showType == SHOW_YYYYMM){
        int yearIndex = (int)[self.pickerView selectedRowInComponent:0];
        NSString *year = self.yearArray[yearIndex];
        int monthIndex = (int)[self.pickerView selectedRowInComponent:1];
        int month = [self.monthArray[monthIndex]intValue];
        result = [NSString stringWithFormat:@"%@-%02d",year,month];
    }else if (self.showType == SHOW_MMDD){
        int monthIndex = (int)[self.pickerView selectedRowInComponent:0];
        int month = [self.monthArray[monthIndex] intValue];
        int dayIndex = (int)[self.pickerView selectedRowInComponent:1];
        int day = [self.dayArray[dayIndex]intValue];
        result = [NSString stringWithFormat:@"%02d-%02d",month,day];
    }else if (self.showType == SHOW_HHmm){
        int hourIndex = (int)[self.pickerView selectedRowInComponent:0];
        int hour = [self.hourArray[hourIndex] intValue];
        int minuteIndex = (int)[self.pickerView selectedRowInComponent:1];
        int minute = [self.minuteArray[minuteIndex]intValue];
        result = [NSString stringWithFormat:@"%02d-%02d",hour,minute];
        if (self.timeFormat == Hour12) {
            int timeFormatIndex = (int)[self.pickerView selectedRowInComponent:2];
            NSString *timeFormat = self.timeFormatArray[timeFormatIndex];
            result = [NSString stringWithFormat:@"%02d-%02d-%@",hour,minute,timeFormat];
        }
    }else if (self.showType == SHOW_YYYYMMDD){
        int yearIndex = (int)[self.pickerView selectedRowInComponent:0];
        NSString *year = self.yearArray[yearIndex];
        int monthIndex = (int)[self.pickerView selectedRowInComponent:1];
        int month = [self.monthArray[monthIndex]intValue];
        int dayIndex = (int)[self.pickerView selectedRowInComponent:2];
        int day = [self.dayArray[dayIndex]intValue];
        result = [NSString stringWithFormat:@"%@-%02d-%02d",year,month,day];
    }else if (self.showType == SHOW_YYYYMMDDHHmm){
        int yearIndex = (int)[self.pickerView selectedRowInComponent:0];
        NSString *year = self.yearArray[yearIndex];
        int monthIndex = (int)[self.pickerView selectedRowInComponent:1];
        int month = [self.monthArray[monthIndex]intValue];
        int dayIndex = (int)[self.pickerView selectedRowInComponent:2];
        int day = [self.dayArray[dayIndex]intValue];
        int hourIndex = (int)[self.pickerView selectedRowInComponent:3];
        int hour = [self.hourArray[hourIndex]intValue];
        int minuteIndex = (int)[self.pickerView selectedRowInComponent:4];
        int minute = [self.minuteArray[minuteIndex]intValue];
        result = [NSString stringWithFormat:@"%@-%02d-%02d %02d:%02d",year,month,day,hour,minute];
        if (self.timeFormat == Hour12) {
            int timeFormatIndex = (int)[self.pickerView selectedRowInComponent:5];
            NSString *timeFormat = self.timeFormatArray[timeFormatIndex];
            result = [NSString stringWithFormat:@"%@-%02d-%02d %02d:%02d %@",year,month,day,hour,minute,timeFormat];
        }
    }
    if(finishBlock){
        finishBlock(result);
    }
    
    [self closeMySelf];
}

-(void)closeMySelf{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8
          initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
              self.opacityView.alpha = 0;
              self.containView.frame = CGRectMake(0, screenBounds.size.height,self.containView.frame.size.width, CTContainViewHeight);
          }completion:^(BOOL finished) {
              [self removeFromSuperview];
          }];
}

#pragma mark delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if(self.showType == SHOW_YYYY ||self.showType == SHOW_MM||self.showType == SHOW_DD||self.showType == SHOW_HH||self.showType == SHOW_mm){
        return 1;
    }else if (self.showType == SHOW_YYYYMM||self.showType == SHOW_MMDD){
        return 2;
    }else if (self.showType == SHOW_HHmm){
        if (self.timeFormat == Hour12) {
            return 3;
        }
        return 2;
    }else if (self.showType == SHOW_YYYYMMDD){
        return 3;
    }else if (self.showType == SHOW_YYYYMMDDHHmm){
        if (self.timeFormat == Hour12) {
            return 6;
        }
        return 5;
    }
    return 0;
}


//SHOW_YYYY,          //只能选择年
//SHOW_YYYYMM,        //只能选择年、月
//SHOW_YYYYMMDD,      //只能选择年、月、日
//SHOW_YYYYMMDDHHmm,  //精确到分钟
//SHOW_MMDD,          //只能选择月日
//SHOW_HHmm,          //只能选择时分
//SHOW_MM,            //只能选择月
//SHOW_DD,            //只能选择日
//SHOW_HH,            //只能选择时
//SHOW_mm,            //只能选择分
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(component == 0){
        switch (self.showType) {
            case SHOW_YYYY:return self.yearArray.count;
            case SHOW_MM:return self.monthArray.count;
            case SHOW_DD:return self.dayArray.count;
            case SHOW_HH:return self.hourArray.count;
            case SHOW_mm:return self.minuteArray.count;
            case SHOW_YYYYMM:return self.yearArray.count;
            case SHOW_MMDD:return self.monthArray.count;
            case SHOW_HHmm:return self.hourArray.count;
            case SHOW_YYYYMMDD:return self.yearArray.count;
            case SHOW_YYYYMMDDHHmm:return self.yearArray.count;
            default:return 0; break;
        }
    }else if (component == 1){
        switch (self.showType) {
            case SHOW_YYYYMM:return self.monthArray.count;
            case SHOW_MMDD:return self.dayArray.count;
            case SHOW_HHmm:return self.minuteArray.count;
            case SHOW_YYYYMMDD:return self.monthArray.count;
            case SHOW_YYYYMMDDHHmm:return self.monthArray.count;
            default:return 0; break;
        }
    }else if (component == 2){
        switch (self.showType) {
            case SHOW_HHmm:return self.timeFormatArray.count;
            case SHOW_YYYYMMDD:return self.dayArray.count;
            case SHOW_YYYYMMDDHHmm:return self.dayArray.count;
            default:return 0; break;
        }
    }else if (component == 3){
        return self.hourArray.count;
    }else if (component == 4){
        return self.minuteArray.count;
    }else if (component == 5){
        return self.timeFormatArray.count;
    }
    return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont systemFontOfSize:16]];
    }
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if(component == 0){
        switch (self.showType) {
            case SHOW_YYYY:return [self.yearArray[row] stringByAppendingString:@"年"];
            case SHOW_MM:return [[NSString stringWithFormat:@"%02d",[self.monthArray[row]intValue]] stringByAppendingString:@"月"];
            case SHOW_DD:return [[NSString stringWithFormat:@"%02d",[self.dayArray[row]intValue]] stringByAppendingString:@"日"];
            case SHOW_HH:return [[NSString stringWithFormat:@"%02d",[self.hourArray[row]intValue]] stringByAppendingString:@"时"];
            case SHOW_mm:return [[NSString stringWithFormat:@"%02d",[self.minuteArray[row]intValue]] stringByAppendingString:@"分"];
            case SHOW_YYYYMM:return [self.yearArray[row] stringByAppendingString:@"年"];
            case SHOW_MMDD:return [[NSString stringWithFormat:@"%02d",[self.monthArray[row]intValue]] stringByAppendingString:@"月"];
            case SHOW_HHmm:return [[NSString stringWithFormat:@"%02d",[self.hourArray[row]intValue]] stringByAppendingString:@"时"];
            case SHOW_YYYYMMDD:return [self.yearArray[row] stringByAppendingString:@"年"];
            case SHOW_YYYYMMDDHHmm:return [self.yearArray[row] stringByAppendingString:@"年"];
            default:return 0; break;
        }
    }else if (component == 1){
        switch (self.showType) {
            case SHOW_YYYYMM:return [[NSString stringWithFormat:@"%02d",[self.monthArray[row]intValue]] stringByAppendingString:@"月"];
            case SHOW_MMDD:return [[NSString stringWithFormat:@"%02d",[self.dayArray[row]intValue]] stringByAppendingString:@"日"];
            case SHOW_HHmm:return [[NSString stringWithFormat:@"%02d",[self.minuteArray[row]intValue]] stringByAppendingString:@"分"];
            case SHOW_YYYYMMDD:return [[NSString stringWithFormat:@"%02d",[self.monthArray[row]intValue]] stringByAppendingString:@"月"];
            case SHOW_YYYYMMDDHHmm:return [[NSString stringWithFormat:@"%02d",[self.monthArray[row]intValue]] stringByAppendingString:@"月"];
            default:return 0; break;
        }
    }else if (component == 2){
        switch (self.showType) {
            case SHOW_HHmm:return self.timeFormatArray[row];
            case SHOW_YYYYMMDD:return [[NSString stringWithFormat:@"%02d",[self.dayArray[row]intValue]] stringByAppendingString:@"日"];
            case SHOW_YYYYMMDDHHmm:return [[NSString stringWithFormat:@"%02d",[self.dayArray[row]intValue]] stringByAppendingString:@"日"];
            default:return 0; break;
        }
    }else if (component == 3){
        return [[NSString stringWithFormat:@"%02d",[self.hourArray[row]intValue]] stringByAppendingString:@"时"];
    }else if (component == 4){
        return [[NSString stringWithFormat:@"%02d",[self.minuteArray[row]intValue]] stringByAppendingString:@"分"];
    }else if (component == 5){
        return self.timeFormatArray[row];
    }
    return @"";
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 35;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if(component == 0){
        switch (self.showType) {
            case SHOW_YYYY:self.selectedYear = [self.yearArray[row]intValue];break;
            case SHOW_MM:self.selectedMonth = [self.monthArray[row]intValue];break;
            case SHOW_DD:self.selectedDay = [self.dayArray[row]intValue];break;
            case SHOW_HH:self.selectedHour = [self.hourArray[row]intValue];break;
            case SHOW_mm:self.selectedMinute = [self.minuteArray[row]intValue];break;
            case SHOW_YYYYMM:self.selectedYear = [self.yearArray[row]intValue];break;
            case SHOW_MMDD:self.selectedMonth = [self.monthArray[row]intValue];break;
            case SHOW_HHmm:self.selectedHour = [self.hourArray[row]intValue];break;
            case SHOW_YYYYMMDD:self.selectedYear = [self.yearArray[row]intValue];break;
            case SHOW_YYYYMMDDHHmm:self.selectedYear = [self.yearArray[row]intValue];break;
        }
    }else if (component == 1){
        switch (self.showType) {
            case SHOW_YYYYMM:self.selectedMonth = [self.monthArray[row]intValue];break;
            case SHOW_MMDD:self.selectedDay = [self.dayArray[row]intValue];break;
            case SHOW_HHmm:self.selectedMinute = [self.minuteArray[row]intValue];break;
            case SHOW_YYYYMMDD:self.selectedMonth = [self.monthArray[row]intValue];break;
            case SHOW_YYYYMMDDHHmm:self.selectedMonth = [self.monthArray[row]intValue];break;
            default:
                break;
        }
    }else if (component == 2){
        switch (self.showType) {
            case SHOW_HHmm:self.selectedTimeFormat = self.timeFormatArray[row];break;
            case SHOW_YYYYMMDD:self.selectedDay = [self.dayArray[row]intValue];break;
            case SHOW_YYYYMMDDHHmm:self.selectedDay = [self.dayArray[row]intValue];break;
            default:
                break;
        }
    }else if (component == 3){
        self.selectedHour = [self.hourArray[row]intValue];
    }else if (component == 4){
        self.selectedMinute = [self.minuteArray[row]intValue];
    }else if (component == 5){
        self.selectedTimeFormat = self.timeFormatArray[row];
    }
    
    if (self.showType == SHOW_YYYYMMDD || self.showType == SHOW_YYYYMMDDHHmm) {
        if(component != 2){
            [self.dayArray removeAllObjects];
            [pickerView reloadComponent:2];
        }
    }else if (self.showType == SHOW_MMDD){
        if(component != 1){
            [self.dayArray removeAllObjects];
            [pickerView reloadComponent:1];
        }
    }
}


@end
