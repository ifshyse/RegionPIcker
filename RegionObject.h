//
//  RegionObject.h
//
//  Created by stephen on 18-4-5.
//  Copyright (c) 2014年 stephen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TownObject : NSObject

@property (nonatomic, strong) NSNumber *code;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *cityCode;

@end

@interface CityObject : NSObject

@property (nonatomic, strong) NSNumber *code;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *provinceCode;

@end

@interface ProvinceObject : NSObject

@property (nonatomic, strong) NSNumber *code;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *countryCode;

@end

@interface RegionObject : NSObject

@property (nonatomic, strong) NSMutableArray *provinceArray;
@property (nonatomic, strong) NSMutableArray *cityArray;
@property (nonatomic, strong) NSMutableArray *townArray;

- (void)loadWithJsonFile:(NSString*)filename;

- (NSMutableArray*)provinceArrayWith:(NSNumber*)countryCode;
- (NSMutableArray*)cityArrayWith:(NSNumber*)provinceCode;
- (NSMutableArray*)townArrayWith:(NSNumber*)cityCode;

- (NSString*)provinceName:(int)province;
- (NSString*)cityName:(int)city;
- (NSNumber*)cityCode:(NSString*)cityName;

- (void)getProvinceCode:(int *)provinceCode cityCode:(int *)cityCode townCode:(int*)townCode withCode:(NSNumber*)code;

@end
