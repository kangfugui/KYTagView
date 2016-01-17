//
//  KYTagView.m
//  KYTagViewDemo
//
//  Created by KangYang on 16/1/15.
//  Copyright © 2016年 KangYang. All rights reserved.
//

#import "KYTagView.h"
#import "UIView+KYAdd.h"

#pragma mark - KYTagView

@implementation KYTagView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self _configureDefaults];
        [self _setup];
    }
    return self;
}

- (void)_configureDefaults
{
    self.borderMargin = 5;
    self.textColor = [UIColor whiteColor];
    self.textFont = [UIFont systemFontOfSize:14];
    self.directionLeftBackground = [[UIImage imageNamed:@"tag_bg_left"] stretchableImageWithLeftCapWidth:20 topCapHeight:10];
    self.directionRightBackground = [[UIImage imageNamed:@"tag_bg_right"] stretchableImageWithLeftCapWidth:20 topCapHeight:10];
}

- (void)_setup
{
    self.tagsArray = [[NSMutableArray alloc] init];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [tapGesture addTarget:self action:@selector(tapGestureAction:)];
    [self addGestureRecognizer:tapGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] init];
    [panGesture setMinimumNumberOfTouches:1];
    [panGesture setMaximumNumberOfTouches:1];
    [panGesture addTarget:self action:@selector(panGestureAction:)];
    [self addGestureRecognizer:panGesture];
    
    UILongPressGestureRecognizer *pressGesture = [[UILongPressGestureRecognizer alloc] init];
    [pressGesture addTarget:self action:@selector(pressGestureAction:)];
    [self addGestureRecognizer:pressGesture];
}

#pragma mark - gesture actions

- (void)tapGestureAction:(UITapGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self];
    KYTagItem *item = [self tagItemAtLocation:location];
    if (item) {
        
        [item changeDirection];
        item.backgroundImage = (item.direction == KYTagArrowDirectionLeft) ? self.directionLeftBackground : self.directionRightBackground;
    }
}

- (void)panGestureAction:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        CGPoint location = [gesture locationInView:self];
        _paningTag = [self tagItemAtLocation:location];
        
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        
        if (_paningTag) {
            
            CGPoint offset = [gesture translationInView:self];
            CGPoint point = CGPointMake(_paningTag.center.x + offset.x,
                                        _paningTag.center.y + offset.y);
            
            point.x = MAX(point.x, _paningTag.width / 2 + 5);
            point.x = MIN(point.x, self.width - (_paningTag.width / 2) - 5);
            
            point.y = MAX(point.y, CGRectGetMidY(_paningTag.bounds));
            point.y = MIN(point.y, self.height - CGRectGetMidY(_paningTag.bounds));
            
            _paningTag.center = point;
            [gesture setTranslation:CGPointZero inView:self];
        }
        
    } else if (gesture.state == UIGestureRecognizerStateEnded ||
               gesture.state == UIGestureRecognizerStateCancelled) {
        
        _paningTag = nil;
    }
}

- (void)pressGestureAction:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        CGPoint location = [gesture locationInView:self];
        KYTagItem *item = [self tagItemAtLocation:location];
        if (item) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"title"
                                                                           message:@"confirm the delete?"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"cancel"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction *action) {
                                                        
                                                        [alert dismissViewControllerAnimated:YES completion:nil];
            }]];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"ok"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) {
                                                        
                                                        [item removeFromSuperview];
                                                        [self.tagsArray removeObject:item];
                                                        [alert dismissViewControllerAnimated:YES completion:nil];
            }]];
            
            [[self topViewController] presentViewController:alert animated:YES completion:nil];
        }
    }
}

#pragma mark - private method

- (UIViewController *)topViewController
{
    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topViewController.presentedViewController != nil) {
        
        topViewController = topViewController.presentedViewController;
    }
    
    return topViewController;
}

- (KYTagItem *)tagItemAtLocation:(CGPoint)location
{
    for (KYTagItem *obj in self.tagsArray) {
        
        if (CGRectContainsPoint(obj.frame, location)) {
            
            return obj;
        }
    }
    
    return nil;
}

#pragma mark - public method

- (void)addTagWithText:(NSString *)text andPosition:(CGPoint)position
{
    KYTagItem *item = [[KYTagItem alloc] initWithText:text andFont:self.textFont andPosition:position];
    
    [self addSubview:item];
    [self.tagsArray addObject:item];
    
    if (item.minX < self.borderMargin || item.maxX > (self.width - self.borderMargin)) {
        [item changeDirection];
    }
    
    item.textLabel.textColor = self.textColor;
    item.backgroundImage = (item.direction == KYTagArrowDirectionLeft) ? self.directionLeftBackground : self.directionRightBackground;
}

@end

#pragma mark - KYTagItem

@implementation KYTagItem

- (instancetype)initWithText:(NSString *)text andFont:(UIFont *)font andPosition:(CGPoint)position
{
    if ((self = [super init])) {
        _text = text;
        _font = font;
        _position = position;
        _direction = KYTagArrowDirectionRight;
        
        [self _setup];
        [self _configureFrames];
    }
    return self;
}

- (void)_setup
{
    CGFloat textWidth = [_text boundingRectWithSize:CGSizeMake(MAXFLOAT, 20)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName : _font}
                                            context:nil].size.width;
    
    textWidth = MIN(textWidth, 150);
    
    CGFloat width = textWidth + 40;
    self.frame = CGRectMake(0, 0, width, 20);
    
    if (self.direction == KYTagArrowDirectionLeft) {
        
        self.center = CGPointMake(self.position.x + (width / 2), self.position.y);
        
    } else if (self.direction == KYTagArrowDirectionRight) {
        
        self.center = CGPointMake(self.position.x - (width / 2), self.position.y);
    }
    
    _backgroundView = [[UIImageView alloc] init];
    [self addSubview:_backgroundView];
    
    _indicatorView = [[UIView alloc] init];
    _indicatorView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    _indicatorView.layer.masksToBounds = YES;
    _indicatorView.layer.cornerRadius = 5;
    [self addSubview:_indicatorView];
    
    UIView *whitePoint = [[UIView alloc] initWithFrame:CGRectMake(3, 3, 4, 4)];
    whitePoint.backgroundColor = [UIColor whiteColor];
    whitePoint.layer.masksToBounds = YES;
    whitePoint.layer.cornerRadius = 2;
    [_indicatorView addSubview:whitePoint];

    _textLabel = [[UILabel alloc] init];
    _textLabel.text = _text;
    _textLabel.font = _font;
    [self addSubview:_textLabel];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.toValue = @(0.5);
    animation.fromValue = @(1);
    animation.duration = 1.5;
    animation.autoreverses = YES;
    animation.repeatCount = NSIntegerMax;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [_indicatorView.layer addAnimation:animation forKey:nil];
}

- (void)_configureFrames
{
    if (self.direction == KYTagArrowDirectionLeft) {
        
        self.backgroundView.frame = CGRectMake(12, 0, self.width - 12, 20);
        self.indicatorView.frame = CGRectMake(0, 5, 10, 10);
        self.textLabel.frame = CGRectMake(30, 0, self.width - 40, 20);
        
    } else if (self.direction == KYTagArrowDirectionRight) {
        
        self.backgroundView.frame = CGRectMake(0, 0, self.width - 12, 20);
        self.indicatorView.frame = CGRectMake(self.width - 10, 5, 10, 10);
        self.textLabel.frame = CGRectMake(11, 0, self.width - 40, 20);
    }
}

- (void)changeDirection
{
    if (self.minX <= 5 && self.direction == KYTagArrowDirectionLeft) {
        return;
    } else if (self.maxX >= (self.superview.width - 5) && self.direction == KYTagArrowDirectionRight) {
        return;
    }
    
    self.direction = (self.direction == KYTagArrowDirectionLeft) ? KYTagArrowDirectionRight : KYTagArrowDirectionLeft;
    self.centerX = self.centerX + ((self.direction == KYTagArrowDirectionLeft) ? self.width : -self.width);
    [self _configureFrames];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    if (_backgroundImage != backgroundImage) {
        _backgroundImage = backgroundImage;
        _backgroundView.image = backgroundImage;
    }
}

@end
