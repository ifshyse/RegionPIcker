//
//  RegionObject.m
//
//  Created by stephen on 18-4-5.
//  Copyright (c) 2018年 stephen. All rights reserved.
//

#import "RegionObject.h"

#pragma mark - TownObject
@implementation TownObject

@end

#pragma mark - CityObject
@implementation CityObject

@end


#pragma mark - ProvinceObject
@implementation ProvinceObject

@end

#pragma mark - RegionObject
@implementation RegionObject

- (id)init {
    self = [super init];
    if (self) {
        self.provinceArray = [[NSMutableArray alloc] init];
        self.cityArray = [[NSMutableArray alloc] init];
        self.townArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)loadWithJsonFile:(NSString*)filename
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Region" ofType:@"dat"];
    NSError *error = nil;
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath options:kNilOptions error:&error];
    NSDictionary *regions = [NSJSONSerialization JSONObjectWithData:data
                                                            options:NSJSONReadingAllowFragments
                                                              error:&error];
    if (!regions || error) {
        NSParameterAssert(false);
        return;
    }
    // parse province
    for (NSString *provinceKey in [regions allKeys])
    {
        NSDictionary *provinceDic = [regions objectForKey:provinceKey];
        NSString *provinceName = [provinceDic objectForKey:@"name"];
        NSDictionary *citiesDic = [provinceDic objectForKey:@"cell"];
        
        // province object
        ProvinceObject *province = [[ProvinceObject alloc] init];
        province.name = provinceName;
        province.code = [NSNumber numberWithInteger:[provinceKey integerValue]];
        [self.provinceArray addObject:province];
        
        // parse city
        for (NSString *cityKey in [citiesDic allKeys])
        {
            NSDictionary *cityDic = [citiesDic objectForKey:cityKey];
            NSString *cityName = [cityDic objectForKey:@"name"];
            NSDictionary *townsDic = [cityDic objectForKey:@"cell"];
            
            // city object
            CityObject *city = [[CityObject alloc] init];
            city.name = cityName;
            city.code = [NSNumber numberWithInteger:[cityKey integerValue]];
            city.provinceCode = province.code;
            [self.cityArray addObject:city];
            
            // parse town
            for (NSString *townKey in [townsDic allKeys])
            {
                NSDictionary *townDic = [townsDic objectForKey:townKey];
                NSString *townName = [townDic objectForKey:@"name"];
                
                // town object
                TownObject *town = [[TownObject alloc] init];
                town.name = townName;
                town.code = [NSNumber numberWithInteger:[townKey integerValue]];
                town.cityCode = city.code;
                [self.townArray addObject:town];
            }
        }
    }
    
    // sort province
    NSSortDescriptor * codeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"code" ascending:YES];
    NSSortDescriptor * provinceCodeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"provinceCode" ascending:YES];
    NSSortDescriptor * cityCodeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"cityCode" ascending:YES];
    
    NSArray * provinceDescriptors = [NSArray arrayWithObjects:codeDescriptor, nil];
    [self.provinceArray sortUsingDescriptors:provinceDescriptors];
    
    // sort city
    NSArray * cityDescriptors = [NSArray arrayWithObjects:provinceCodeDescriptor, codeDescriptor, nil];
    [self.cityArray sortUsingDescriptors:cityDescriptors];
    
    // twon city
    NSArray * townDescriptors = [NSArray arrayWithObjects:cityCodeDescriptor, codeDescriptor, nil];
    [self.townArray sortUsingDescriptors:townDescriptors];
    
}

- (NSMutableArray*)provinceArrayWith:(NSNumber*)countryCode
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithArray:self.provinceArray];
    return result;
}

- (NSMutableArray*)cityArrayWith:(NSNumber*)provinceCode
{
    NSArray *filterd = [self.cityArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"provinceCode == %@", provinceCode]];
    NSMutableArray *result = [[NSMutableArray alloc] initWithArray:filterd];
    // for beijing, shanghai, tianjin, chongqing
    if ([result count] == 1) {
        //CityObject *city = [result firstObject];
        //result = [self townArrayWith:city.code];
    }
    
    return result;
}

- (NSMutableArray*)townArrayWith:(NSNumber*)cityCode
{
    NSArray *filterd = [self.townArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"cityCode == %@", cityCode]];
    NSMutableArray *result = [[NSMutableArray alloc] initWithArray:filterd];
    return result;
}

- (NSString*)provinceName:(int)province
{
    NSArray *filterd = [self.provinceArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"code == %@", [NSNumber numberWithInt:province]]];
    ProvinceObject *provinceObject = [filterd firstObject];
    return [provinceObject name];
}

- (NSString*)cityName:(int)city
{
    NSArray *filterd = [self.cityArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"code == %@", [NSNumber numberWithInt:city]]];
    if (filterd && [filterd count] > 0) {
        CityObject *cityObject = [filterd firstObject];
        return [cityObject name];
    }
    else {
        NSArray *filterd2 = [self.townArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"code == %@", [NSNumber numberWithInt:city]]];
        TownObject *townObject = [filterd2 firstObject];
        return [townObject name];
    }
}

- (NSNumber*)cityCode:(NSString*)cityName
{
    NSArray *filterd = [self.provinceArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", cityName]];
    if (filterd && [filterd count] > 0) {
        ProvinceObject *provinceObject = [filterd firstObject];
        return [provinceObject code];
    }
    else {
        NSArray *filterd = [self.cityArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", cityName]];
        if (filterd && [filterd count] > 0) {
            CityObject *cityObject = [filterd firstObject];
            return [cityObject code];
        }
        else {
            NSArray *filterd2 = [self.townArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", cityName]];
            if (filterd2 && [filterd2 count] > 0) {
                TownObject *townObject = [filterd2 firstObject];
                return [townObject code];
            }
            else {
                return nil;
            }
        }
    }
}

- (void)getProvinceCode:(int *)provinceCode cityCode:(int *)cityCode townCode:(int*)townCode withCode:(NSNumber*)code
{
    NSArray *filterd = [self.cityArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"code == %@", code]];
    if (filterd && [filterd count] > 0) {
        CityObject *cityObject = [filterd firstObject];
        *cityCode = cityObject.code.intValue;
        *provinceCode = cityObject.provinceCode.intValue;
        *townCode = 0;
    }
    else {
        NSArray *filterd2 = [self.townArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"code == %@", code]];
        if (filterd2 && [filterd2 count] > 0) {
            TownObject *townObject = [filterd2 firstObject];
            *townCode = townObject.code.intValue;
            *cityCode = townObject.cityCode.intValue;
            NSArray *filterd = [self.cityArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"code == %@", townObject.cityCode]];
            if (filterd && [filterd count] > 0) {
                CityObject *cityObject = [filterd firstObject];
                *provinceCode = cityObject.provinceCode.intValue;
            }
        }
        else {
            *townCode = 0;
            *cityCode = 0;
            NSArray *filterd = [self.provinceArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"code == %@", code]];
            if (filterd && [filterd count] > 0) {
                ProvinceObject *provinceObject = [filterd firstObject];
                *provinceCode = provinceObject.code.intValue;
            }
        }
    }
    
}


@end
