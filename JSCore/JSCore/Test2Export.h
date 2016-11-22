//
//  Test2Export.h
//  JSCore
//
//  Created by ddn on 16/11/22.
//  Copyright © 2016年 张永俊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol TestExport <JSExport>

- (void)jsCallNative:(NSString *)params;

@end

@interface Test2Export : NSObject <TestExport>

@end
