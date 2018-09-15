//
//  RegionPickerView.h
//  ReginePickView
//
//  Created by stephen on 1/12/18.
//  Copyright (c) 2018 stephen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RegionPickerView;

typedef void (^RegionPickerViewSelectedBlock) (RegionPickerView *regionPickerView, NSString *addressString, NSNumber *addressCode);

@interface RegionPickerView : UIPickerView

@property (strong, nonatomic) NSString *addressString;
@property (strong, nonatomic) NSNumber *addressCode;

@property (copy, nonatomic) RegionPickerViewSelectedBlock selectedBlock;

- (void)setInitCode:(NSNumber*)code;
- (void)setInitCity:(NSString*)city;

@end
