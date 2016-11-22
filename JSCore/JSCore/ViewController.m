//
//  ViewController.m
//  JSCore
//
//  Created by ddn on 16/11/22.
//  Copyright © 2016年 张永俊. All rights reserved.
//

/*
 JSContext
 一个JSContext实例代表着一个js运行时环境，js代码都需要在一个context上下文内执行，而且JSContext还负责管理js虚拟机中所有对象的生命周期
 
 JSValue
 JSContext的返回结果，他对数据类型进行了封装，并且为JS和OC的数据类型之间的转换提供了方法，例如：如果是数值类型：- (NSArray *)toArray;- (NSString *)toString;等。。。；如果是函数类型：- (JSValue *)callWithArguments:(NSArray *)arguments;调用函数
 
 JSManagedValue
 JSValue的封装，用它可以解决JS和原生代码之间循环引用的问题
 
 JSVirtualMachine
 js代码运行的虚拟机，提供JavaScriptCore执行需要的资源，有自己独立的堆栈以及垃圾回收机制，而且通过锁来实现线程安全，如果需要并发执行js代码，可以创建不同的JSVirtualMachine虚拟机对象来实现
 
 在创建jscontext的时候，可以传入一个JSVirtualMachine对象，如果没有传入这个对象，会新建一个JSVirtualMachine对象。
 JSVirtualMachine主要有3个作用：
 1: 假如我们需要并发的执行js代码，我们也可以在创建JSContext的时候也指定其所在的虚拟机，不同的虚拟机处于不同的线程中，但是如果在不同的 JSVirtualMachine，上下文并不能直接互相传值
 2：一个JSVirtualMachine在一个线程中，它可以包含多个JSContext，而且相互之间可以传值，为了确保线程安全，这些context在运行的时候会采用锁，可以认为是串行执行
 
 JSExport
 一个协议，通过实现它可以完成把一个native对象暴漏给js
 */

#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

#import "Person.h"

@interface ViewController ()

@property (strong, nonatomic) JSContext *context;

@property (strong, nonatomic) id callback;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.context = [JSContext new];
    
//    在UIWebView中获取JSContext的方法是：
//    JSContext *context=[webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    //注册js错误处理
    self.context.exceptionHandler = ^(JSContext *con, JSValue *exception) {
        NSLog(@"=====异常：%@======", exception);
        con.exception = exception;
    };
    
    [self evaluateScript];
    
    [self evaluateScriptFormFile];
    
    [self registeJSFunc];
    
    [self registeNativeFunc];
    
    [self useJSExport];
}

//直接执行js代码
- (void)evaluateScript {
    JSValue *result = [self.context evaluateScript:@"(function(){ return '直接执行js代码' })()"];
    NSLog(@"=======%@=======", result);
}

//从文件或者网络加载js代码，执行
- (void)evaluateScriptFormFile {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"js"];
    NSString *jsStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    JSValue *result = [self.context evaluateScript:jsStr];
    NSLog(@"=======%@=======", result);
}

//注册js方法，然后在利用JSValue调用
- (void)registeJSFunc {
//    [self.context evaluateScript:@"var hello = function(){return '注册调用'}"];
//    JSValue *result = [self.context evaluateScript:@"hello()"];
//    NSLog(@"========%@========", result);
    
    //更常用的是注册匿名函数(使用闭包，如果只是注册一个函数，不会返回给jsvalue)
    JSValue *jsFunc = [self.context evaluateScript:@"(function(){return '注册匿名函数调用'})"];
    
    JSValue *result = [jsFunc callWithArguments:nil];
    NSLog(@"======%@======", result);
}

//js调用native代码
- (void)registeNativeFunc {
    __weak typeof(self.context) weakContext = self.context;
    //当然，jsContext中下标不仅仅可以放函数，也可以放对象和数值
    self.context[@"native"] = ^(){
        //使用静态方法，避免循环引用
        
        NSArray *args = [JSContext currentArguments];
        JSContext *context = [JSContext currentContext];
        JSValue *this = [JSContext currentThis];
        JSValue *callee = [JSContext currentCallee];
        NSLog(@"js调用native代码获取参数========%@========", args);
        NSLog(@"js调用native代码获取上下文========%@========%@=======", context, weakContext);
        NSLog(@"js调用native代码获取this========%@========", this);
        NSLog(@"js调用native代码获取调用函数的对象，这里就是block========%@========", callee);
    };
    
    //使用js调用
    [self.context evaluateScript:@"native(1, 2, 3)"];
}

- (void)useJSExport {
    Person *p = [Person new];
    self.context[@"person"] = p;
    JSValue *result = [self.context evaluateScript:@"person.whatYouName()"];
    NSLog(@"========%@========", result);
    
    JSValue *result2 = [self.context evaluateScript:@"person.notExport()"];
    NSLog(@"========%@========", result2);
}


//JSManagedValue
/*
 在oc中为了打破循环引用我们采用weak的方式，不过在JavaScriptCore中我们采用内存管理辅助对象JSManagedValue的方式，它能帮助引用技术和垃圾回收这两种内存管理机制之间进行正确的转换
 JSManagedValue本身只弱引用js值，需要调用JSVirtualMachine的addManagedReference:withOwner:把它添加到JSVirtualMachine中，这样如果JavaScript能够找到该JSValue的Objective-C owner，该JSValue的引用就不会被释放
 */
- (void)avoidRetainCycle {
    JSValue *js = [self.context evaluateScript:@"(function(button, callback){this.button = button; this.handler = callback})"];
    self.callback = [JSManagedValue managedValueWithValue:js];
    [self.context.virtualMachine addManagedReference:self.callback withOwner:nil];
}

@end




















