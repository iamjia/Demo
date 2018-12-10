//
//  DetailViewController.h
//  TestDemo
//
//  Created by Jia on 2018/11/27.
//  Copyright © 2018年 Jia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) NSDate *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

