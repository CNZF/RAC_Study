//
//  ModuleBViewController.m
//  RAC_Study
//
//  Created by lxy on 2019/3/11.
//  Copyright © 2019年 lxy. All rights reserved.
//

#import "ModuleBViewController.h"

@interface model_A : NSObject
@property (nonatomic, copy) NSString * name;
@end

@implementation model_A
{
    
}

@end

@interface ModuleBViewController ()

@end

@implementation ModuleBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cyanColor];
    
    model_A * model = [model_A new];
    model.name = @"啊啊啊啊";
    
    [self.subject sendNext:model];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
