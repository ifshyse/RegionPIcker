//
//  RegionPickerView.m
//  ReginePickView
//
//  Created by stephen on 1/12/18.
//  Copyright (c) 2018 stephen. All rights reserved.
//

#import "RegionPickerView.h"
#import "RegionObject.h"

@interface RegionPickerView()
<
UIPickerViewDataSource,
UIPickerViewDelegate
>
{
    
}

@property (nonatomic, strong) RegionObject* regionObject;
@property (nonatomic, strong) NSMutableArray* provinces;
@property (nonatomic, strong) NSMutableArray* citys;
@property (nonatomic, strong) NSMutableArray* towns;

@end

@implementation RegionPickerView

#pragma mark - UIPickerViewDataSource

- (void)awakeFromNib {
    [super awakeFromNib];
    [self innerInit];
}

- (instancetype) init {
    self = [super init];
    if (self) {
        [self innerInit];
    }
    return self;
}

#pragma mark - private
- (void)innerInit
{
    self.delegate = self;
    self.dataSource = self;
    self.regionObject = [[RegionObject alloc] init];
    [self.regionObject loadWithJsonFile:@"Region.dat"];
    self.provinces = [self.regionObject provinceArrayWith:nil];
    ProvinceObject* province = [self.provinces objectAtIndex:0];
    self.citys = [self.regionObject cityArrayWith:province.code];
    CityObject* city = [self.citys objectAtIndex:0];
    self.towns = [self.regionObject townArrayWith:city.code];
}

- (void)updateData {
    int row1 = [self selectedRowInComponent:0];
    if (row1 < self.provinces.count) {
        ProvinceObject* province = [self.provinces objectAtIndex:row1];
        self.citys = [self.regionObject cityArrayWith:province.code];
        int row2 = [self selectedRowInComponent:1];
        if (row2 < self.citys.count) {
            CityObject* city = [self.citys objectAtIndex:row2];
            self.towns = [self.regionObject townArrayWith:city.code];
        }
        else {
            [self.towns removeAllObjects];
        }
    }
    else {
        [self.citys removeAllObjects];
    }
}


- (void)updateValue {
    
    int row1 = [self selectedRowInComponent:0];
    if (row1 < self.provinces.count) {
        ProvinceObject* province = [self.provinces objectAtIndex:row1];
        self.citys = [self.regionObject cityArrayWith:province.code];
        int row2 = [self selectedRowInComponent:1];
        if (row2 < self.citys.count) {
            CityObject* city = [self.citys objectAtIndex:row2];
            self.towns = [self.regionObject townArrayWith:city.code];
            int row3 = self.towns.count > 0 ? [self selectedRowInComponent:2] : 0;
            if (row3 < self.towns.count) {
                TownObject *town = [self.towns objectAtIndex:row3];
                self.addressString = [NSString stringWithFormat:@"%@%@%@", province.name, city.name, town.name];
                self.addressCode = town.code;
            }
            else {
                self.addressString = [NSString stringWithFormat:@"%@%@", province.name, city.name];
                self.addressCode = city.code;
            }
        }
        else {
            self.addressString = [NSString stringWithFormat:@"%@", province.name];
            self.addressCode = province.code;
        }
    }
    else {
        NSParameterAssert(false);
    }
    
}

- (int)provinceIndex:(int)provinceCode
{
    int index = 0;
    NSArray *filterd = [self.provinces filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"code == %@", [NSNumber numberWithInt:provinceCode]]];
    if (filterd && [filterd count] > 0) {
        index = [self.provinces indexOfObject:[filterd firstObject]];
    }
    return index;
}

- (int)cityIndex:(int)cityCode
{
    int index = 0;
    NSArray *filterd = [self.citys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"code == %@", [NSNumber numberWithInt:cityCode]]];
    if (filterd && [filterd count] > 0) {
        index = [self.citys indexOfObject:[filterd firstObject]];
    }
    return index;
}

- (int)townIndex:(int)townCode
{
    int index = 0;
    NSArray *filterd = [self.towns filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"code == %@", [NSNumber numberWithInt:townCode]]];
    if (filterd && [filterd count] > 0) {
        index = [self.towns indexOfObject:[filterd firstObject]];
    }
    return index;
}

#pragma mark - public

- (void)setInitCode:(NSNumber*)code
{
    int provinceCode = 0;
    int cityCode = 0;
    int townCode = 0;
    
    [self.regionObject getProvinceCode:&provinceCode cityCode:&cityCode townCode:&townCode withCode:code];
    
    int provinceIndex = [self provinceIndex:provinceCode];
    
    ProvinceObject* province = [self.provinces objectAtIndex:provinceIndex];
    
    self.citys = [self.regionObject cityArrayWith:province.code];
    
    int cityIndex = [self cityIndex:cityCode];
    
    CityObject* city = [self.citys objectAtIndex:cityIndex];
    self.towns = [self.regionObject townArrayWith:city.code];
    int townIndex = [self townIndex:townCode];
    
    [self selectRow:provinceIndex inComponent:0 animated:NO];
    if ([self.citys count] > 0) {
        [self selectRow:cityIndex inComponent:1 animated:NO];
        [self reloadComponent:1];
    }
    if ([self.towns count] > 0) {
        [self selectRow:townIndex inComponent:2 animated:NO];
        [self reloadComponent:2];
    }
    
    [self updateValue];
    
    if (self.selectedBlock) {
        self.selectedBlock(self, self.addressString, self.addressCode);
    }
    
}

- (void)setInitCity:(NSString*)city
{
    NSNumber *code = [self.regionObject cityCode:city];
    [self setInitCode:code];
}

#pragma mark - UIPickerViewDataSource

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    /*if ([self.towns count] <= 0) {
     return 2;
     }
     if ([self.citys count] <= 0) {
     return 1;
     }
     else {
     return 3;
     }*/
    return 3;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
        {
            return self.provinces.count;
        }
            break;
        case 1:
        {
            return self.citys.count;
        }
            break;
        case 2:
        {
            return self.towns.count;
        }
        default:
            return 0;
            break;
    }
    
}

#pragma mark - UIPickerViewDelegate

// these methods return either a plain NSString, a NSAttributedString, or a view (e.g UILabel) to display the row for the component.
// for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
// If you return back a different object, the old one will be released. the view will be centered in the row rect
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0:
        {
            ProvinceObject* province = (ProvinceObject*)[self.provinces objectAtIndex:row];
            return province.name;
        }
            break;
        case 1:
        {
            CityObject* city = [self.citys objectAtIndex:row];
            return city.name;
        }
            break;
        case 2:
        {
            TownObject* town = [self.towns objectAtIndex:row];
            return town.name;
        }
        default:
            return @"";
            break;
    }
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        [self selectRow:0 inComponent:1 animated:NO];
        [self selectRow:0 inComponent:2 animated:NO];
        [self updateData];
        
        [self reloadComponent:1];
        [self reloadComponent:2];
    }
    else if (component == 1) {
        [self selectRow:0 inComponent:2 animated:NO];
        [self updateData];
        [self reloadComponent:2];
    }
    else if (component == 2) {
        [self updateData];
    }
    else {
        NSParameterAssert(false);
    }
    
    [self updateValue];
    
    if (self.selectedBlock) {
        self.selectedBlock(self, self.addressString, self.addressCode);
    }
}


@end
