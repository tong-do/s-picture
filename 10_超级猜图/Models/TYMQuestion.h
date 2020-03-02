//
//  TYMQuestion.h
//  10_超级猜图
//
//  Created by 童益鳴 on 2020/02/18.
//  Copyright © 2020 童益鳴. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TYMQuestion : NSObject

@property (nonatomic, copy) NSString *answer;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSArray *options;

-(instancetype)initWithDict:(NSDictionary *)dict;
+(instancetype)questionWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
