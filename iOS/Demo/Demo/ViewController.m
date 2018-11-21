//
//  ViewController.m
//  Demo
//
//  Created by Dean on 2018/11/16.
//  Copyright © 2018年 dxchen321@gmail.com. All rights reserved.
//

#import "ViewController.h"

@interface Person : NSObject
@end
@implementation Person
@end

@interface Student : Person
@end

@implementation Student

- (instancetype)init {
    
    if (self = [super init]) {
        
        NSLog(@"[self class] = %@", [self class]); // Student
        NSLog(@"[self superclass] = %@", [self superclass]); // Person
        
        // objc_msgSendSuper({self, [MJPerson class]}, @selector(class));
        NSLog(@"[super class] = %@", [super class]); // Student
        NSLog(@"[super superclass] = %@", [super superclass]); // Person
        
    }
    return self;
}

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BOOL res1 = [NSObject isKindOfClass:[NSObject class]];
    BOOL res2 = [NSObject isMemberOfClass:[NSObject class]];
    BOOL res3 = [Person isKindOfClass:[NSObject class]];
    BOOL res4 = [Person isMemberOfClass:[NSObject class]];
    
}

@end


