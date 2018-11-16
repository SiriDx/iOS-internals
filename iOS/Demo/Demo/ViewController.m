//
//  ViewController.m
//  Demo
//
//  Created by Dean on 2018/11/16.
//  Copyright © 2018年 dxchen321@gmail.com. All rights reserved.
//

#import "ViewController.h"

@interface Person : NSObject

@property (copy, nonatomic) NSMutableArray *data;

@end

@implementation Person
@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Person *p = [[Person alloc] init];
    [p.data addObject:@"jack"];
    [p.data addObject:@"rose"];
    
}

@end


