//
//  Test2UIWebViewController.m
//  JSCore
//
//  Created by ddn on 16/11/22.
//  Copyright © 2016年 张永俊. All rights reserved.
//

#import "Test2UIWebViewController.h"
#import "Test2Export.h"

@interface Test2UIWebViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (strong, nonatomic) JSContext *jsContext;
@end

@implementation Test2UIWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webview.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test2.html" ofType:nil];
    NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self.webview loadHTMLString:html baseURL:nil];
}

- (IBAction)callJS:(id)sender {
    JSValue *varibleStyle = self.jsContext[@"globalObj"];
    [varibleStyle invokeMethod:@"nativeCallJS" withArguments:@[@"yellow"]];
    
    //等同于
//    [self.webview stringByEvaluatingJavaScriptFromString:@"globalObj.nativeCallJS('green')"];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exception){
        NSLog(@"JS代码执行中的异常信息%@", exception);
    };
    self.jsContext[@"obj"] = [Test2Export new];
}

@end
