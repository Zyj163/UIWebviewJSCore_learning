//
//  Person.h
//  JSCore
//
//  Created by ddn on 16/11/22.
//  Copyright © 2016年 张永俊. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

//自定义个协议继承自JSExprot，并定义需要暴露给js的属性和方法
@protocol JSPersonProtocol <JSExport>

- (NSString *)whatYouName;

@end

#import <Foundation/Foundation.h>

@interface Person : NSObject <JSPersonProtocol>

- (NSString *)whatYouName;

- (NSString *)notExport;

@end
