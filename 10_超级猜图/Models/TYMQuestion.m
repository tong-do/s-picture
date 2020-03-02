//
//  TYMQuestion.m
//  10_超级猜图
//
//  Created by 童益鳴 on 2020/02/18.
//  Copyright © 2020 童益鳴. All rights reserved.
//

#import "TYMQuestion.h"

@implementation TYMQuestion

-(instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.answer = dict[@"answer"];
        self.title = dict[@"title"];
        self.icon = dict[@"icon"];
        self.options = dict[@"options"];
    }
    return self;
}

+(instancetype)questionWithDict:(NSDictionary *)dict
{
    return [[self alloc]initWithDict:dict];
}
@end
