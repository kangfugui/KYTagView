//
//  ViewController.m
//  KYTagViewDemo
//
//  Created by KangYang on 16/1/15.
//  Copyright © 2016年 KangYang. All rights reserved.
//

#import "ViewController.h"
#import "KYTagView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    KYTagView *tagView = [[KYTagView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:tagView];
    
    [tagView addTagWithText:@"hello world" andPosition:CGPointMake(100, 100)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
