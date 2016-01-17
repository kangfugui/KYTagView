//
//  KYTagView.h
//  KYTagViewDemo
//
//  Created by KangYang on 16/1/15.
//  Copyright © 2016年 KangYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KYTagItem;

typedef NS_ENUM(NSInteger, KYTagArrowDirection)
{
    KYTagArrowDirectionLeft = 0,
    KYTagArrowDirectionRight = 1,
};

@interface KYTagView : UIView

@property (copy, nonatomic) UIColor *textColor;
@property (copy, nonatomic) UIFont *textFont;
@property (assign, nonatomic) CGFloat borderMargin;
@property (strong, nonatomic) UIImage *directionLeftBackground;
@property (strong, nonatomic) UIImage *directionRightBackground;
@property (strong, nonatomic) NSMutableArray<KYTagItem *> *tagsArray;

@property (readonly, weak, nonatomic) KYTagItem *paningTag;

- (void)addTagWithText:(NSString *)text andPosition:(CGPoint)position;

@end

@interface KYTagItem : UIView

- (instancetype)initWithText:(NSString *)text andFont:(UIFont *)font andPosition:(CGPoint)position;

- (void)changeDirection;

@property (copy, nonatomic) UIImage *backgroundImage;
@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) UIFont *font;
@property (assign, nonatomic) CGPoint position;
@property (assign, nonatomic) KYTagArrowDirection direction;

@property (strong, nonatomic) UIImageView *backgroundView;
@property (strong, nonatomic) UILabel *textLabel;
@property (strong, nonatomic) UIView *indicatorView;

@end
