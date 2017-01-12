//
//  ViewController.m
//  DateSelectTest
//
//  Created by pang on 16/3/31.
//  Copyright © 2016年 cattsoft. All rights reserved.
//

#import "ViewController.h"
#import "CTDateSelectorView.h"

@interface ViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *PickerView;

@property (nonatomic,strong) NSMutableArray *sourceArray;
@property (nonatomic) CTDatePickerShowType ShowType ;
@property (nonatomic) TimeFormat timeFormat;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.PickerView.delegate = self;
    self.timeFormat = Hour24;
    self.ShowType = SHOW_YYYYMMDDHHmm;
    self.sourceArray = [NSMutableArray arrayWithObjects:@"SHOW_HHmm",@"SHOW_MM",@"SHOW_MMDD",@"SHOW_YYYY",@"SHOW_YYYYMM",@"SHOW_YYYYMMDD",@"SHOW_YYYYMMDDHHmm",@"SHOW_DD",@"SHOW_HH",@"SHOW_YYYY", nil];
}
- (IBAction)selectDateAction:(UIButton *)sender {
    CTDateSelectorView *dateSelect =[[CTDateSelectorView alloc]initWithShowType:self.ShowType timeFormat:self.timeFormat finish:^(NSString *selectedDate) {
        self.dateLabel.text = selectedDate;
    } cancel:^{
        
    }];
    [dateSelect show];
    
}


- (IBAction)timeFormatAction:(UIButton *)sender {
    if (self.timeFormat == Hour24) {
        self.timeFormat =Hour12;
        [sender setTitle:@"12" forState:UIControlStateNormal];
    }else{
        self.timeFormat = Hour24;
        [sender setTitle:@"24" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}



- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
        return 10;
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
    
    return self.sourceArray[row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 35;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    switch (row) {
        case 0:self.ShowType = SHOW_HHmm;break;
        case 1:self.ShowType = SHOW_MM;break;
        case 2:self.ShowType = SHOW_MMDD;break;
        case 3:self.ShowType = SHOW_YYYY;break;
        case 4:self.ShowType = SHOW_YYYYMM;break;
        case 5:self.ShowType = SHOW_YYYYMMDD;break;
        case 6:self.ShowType = SHOW_YYYYMMDDHHmm;break;
        case 7:self.ShowType = SHOW_DD;break;
        case 8:self.ShowType = SHOW_HH;break;
        case 9:self.ShowType = SHOW_YYYY;break;
        default:
            break;
    }
    
}

@end
