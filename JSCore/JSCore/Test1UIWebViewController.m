//
//  Test1UIWebViewController.m
//  JSCore
//
//  Created by ddn on 16/11/22.
//  Copyright © 2016年 张永俊. All rights reserved.
//

#import "Test1UIWebViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface Test1UIWebViewController () <UIWebViewDelegate>

@property (strong, nonatomic) JSContext *jsContext;

@end

@implementation Test1UIWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webview.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test1.html" ofType:nil];
    NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self.webview loadHTMLString:html baseURL:nil];
}

- (IBAction)callJS:(id)sender {
    JSValue *jsMethod = self.jsContext[@"nativeCallJS"];
    [jsMethod callWithArguments:@[@"yellow"]];
    
    //等同于
//    [self.webview stringByEvaluatingJavaScriptFromString:@"nativeCallJS('green')"];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exception){
        NSLog(@"JS代码执行中的异常信息%@", exception);
    };
    
    
    //注入方法供js调用
    __weak typeof(self) ws = self;
    self.jsContext[@"jsCallNative"] = ^(NSString *paramer) {
        JSValue *currentThis = [JSContext currentThis];
        JSValue *currentCallee = [JSContext currentCallee];
        NSArray *currentParamers = [JSContext currentArguments];
        dispatch_async(dispatch_get_main_queue(), ^{
            /**
             *  js调起OC代码，代码在子线程，更新OC中的UI，需要回到主线程
             */
            ws.webview.backgroundColor = [UIColor blueColor];
        });
        NSLog(@"JS paramer is %@",paramer);
        NSLog(@"currentThis is %@",[currentThis toString]);
        NSLog(@"currentCallee is %@",[currentCallee toString]);
        NSLog(@"currentParamers is %@",currentParamers);
    };
}

@end
