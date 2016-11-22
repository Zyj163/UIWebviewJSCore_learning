//
//  Test2Export.m
//  JSCore
//
//  Created by ddn on 16/11/22.
//  Copyright © 2016年 张永俊. All rights reserved.
//

#import "Test2Export.h"

@implementation Test2Export

- (void)jsCallNative:(NSString *)params
{
    JSValue *currentThis = [JSContext currentThis];
    JSValue *currentCallee = [JSContext currentCallee];
    NSArray *currentParamers = [JSContext currentArguments];
    dispatch_async(dispatch_get_main_queue(), ^{
        /**
         *  js调起OC代码，代码在子线程，更新OC中的UI，需要回到主线程
         */
    });
    NSLog(@"JS paramer is %@",params);
    NSLog(@"currentThis is %@",[currentThis toString]);
    NSLog(@"currentCallee is %@",[currentCallee toString]);
    NSLog(@"currentParamers is %@",currentParamers);
}

@end
