//
//  QQBtn.m
//  QQMessageBtn
//
//  Created by ecaray_miss on 2017/12/20.
//  Copyright © 2017年 Miel_TDQ. All rights reserved.
//

#import "QQBtn.h"
#define kQQBtnWidth self.frame.size.width
#define kQQBtnHeight self.frame.size.height
@interface QQBtn()
//底部小圆
@property(nonatomic,weak)UIView * smallCircleView;
//不规则图形
@property(nonatomic,weak)CAShapeLayer *shapeLayer;

@end
@implementation QQBtn

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setUp];
}
#pragma mark -setter
-(UIView *)smallCircleView
{
    if(!_smallCircleView){
        UIView * view = [[UIView alloc]init];
        view.backgroundColor = self.backgroundColor;
        [self.superview insertSubview:view belowSubview:self];
        _smallCircleView = view;
    }
    return _smallCircleView;
}

-(CAShapeLayer *)shapeLayer
{
    if(!_shapeLayer){
        CAShapeLayer *lay = [CAShapeLayer layer];
        lay.fillColor = self.backgroundColor.CGColor;
        [self.superview.layer insertSublayer:lay above:self.layer];
        _shapeLayer = lay;
    }
    return _shapeLayer;
}

- (NSMutableArray *)images
{
    if (_images == nil) {
        _images = [NSMutableArray array];
        for (int i = 1; i < 9; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d", i]];
            [_images addObject:image];
        }
    }
    return _images;
}

#pragma mark -init
- (void)setUp {
    
    CGFloat radius = MIN(kQQBtnWidth, kQQBtnHeight)/2;
    _maxDistance = radius * 5;
    self.backgroundColor = [UIColor redColor];
    [self setTitle:@"12" forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
    
    self.smallCircleView.frame = CGRectMake(0, 0, radius*1.5, radius*1.5);
    self.smallCircleView.layer.cornerRadius = CGRectGetWidth(self.smallCircleView.frame)/2;
    self.smallCircleView.center = self.center;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    
    [self addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)pan:(UIPanGestureRecognizer *)pan{
    
    [self.layer removeAnimationForKey:@"shake"];
    
    CGPoint panPoint = [pan translationInView:self];
    
    CGPoint changeCenter = self.center;
    changeCenter.x += panPoint.x;
    changeCenter.y += panPoint.y;
    self.center = changeCenter;
    [pan setTranslation:CGPointZero inView:self];
    
    //俩个圆的中心点之间的距离
    CGFloat dist = [self pointToPintDistanceWithAPoint:self.center bPoint:self.smallCircleView.center];
    
    if (dist < _maxDistance) {
        
        CGFloat cornerRadius = MIN(kQQBtnWidth, kQQBtnHeight)/2;
        CGFloat samllCrecleRadius = cornerRadius - dist / 10;
        _smallCircleView.bounds = CGRectMake(0, 0, samllCrecleRadius * (2 - 0.5), samllCrecleRadius * (2 - 0.5));
        _smallCircleView.layer.cornerRadius = _smallCircleView.bounds.size.width / 2;
        
        if (_smallCircleView.hidden == NO && dist > 0) {
            //画不规则矩形
            self.shapeLayer.path = [self pathWithBigCirCleView:self smallCirCleView:_smallCircleView].CGPath;
        }
    } else {
        
        [self.shapeLayer removeFromSuperlayer];
        self.shapeLayer = nil;
        
        self.smallCircleView.hidden = YES;
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (dist > _maxDistance) {
    
            [self startDestoryAnimation];
            [self killAll];
        } else {
            
            [self.shapeLayer removeFromSuperlayer];
            self.shapeLayer = nil;
            
            [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.2 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.center = self.smallCircleView.center;
            } completion:^(BOOL finished) {
                self.smallCircleView.hidden = NO;
            }];
        }
    }
}
#pragma mark - 不规则路径
- (UIBezierPath *)pathWithBigCirCleView:(UIView *)bigCirCleView  smallCirCleView:(UIView *)smallCirCleView
{
    CGPoint bigCenter = bigCirCleView.center;
    CGFloat x2 = bigCenter.x;
    CGFloat y2 = bigCenter.y;
    CGFloat r2 = bigCirCleView.bounds.size.width / 2;
    
    CGPoint smallCenter = smallCirCleView.center;
    CGFloat x1 = smallCenter.x;
    CGFloat y1 = smallCenter.y;
    CGFloat r1 = smallCirCleView.bounds.size.width / 2;
    
    // 获取圆心距离
    CGFloat d = [self pointToPintDistanceWithAPoint:self.smallCircleView.center bPoint:self.center];
    CGFloat sinθ = (x2 - x1) / d;
    CGFloat cosθ = (y2 - y1) / d;
    
    // 坐标系基于父控件
    CGPoint pointA = CGPointMake(x1 - r1 * cosθ , y1 + r1 * sinθ);
    CGPoint pointB = CGPointMake(x1 + r1 * cosθ , y1 - r1 * sinθ);
    CGPoint pointC = CGPointMake(x2 + r2 * cosθ , y2 - r2 * sinθ);
    CGPoint pointD = CGPointMake(x2 - r2 * cosθ , y2 + r2 * sinθ);
    CGPoint pointO = CGPointMake(pointA.x + d / 2  * sinθ , pointA.y + d / 2  * cosθ);   //AO距离越短，OD切角越小，OD越直；AO距离越大，AO切角越小，AO越直
    CGPoint pointP = CGPointMake(pointB.x + d / 2  * sinθ , pointB.y + d / 2  * cosθ);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    // A
    [path moveToPoint:pointA];
    // AB
    [path addLineToPoint:pointB];
    // 绘制BC曲线
    [path addQuadCurveToPoint:pointC controlPoint:pointP];
    // CD
    [path addLineToPoint:pointD];
    // 绘制DA曲线
    [path addQuadCurveToPoint:pointA controlPoint:pointO];
    
    return path;
}

- (CGFloat)pointToPintDistanceWithAPoint:(CGPoint)aPoint bPoint:(CGPoint)bPoint{

    CGFloat offestX = aPoint.x - bPoint.x;
    CGFloat offestY = aPoint.y - bPoint.y;
    CGFloat distance = sqrt(offestX*offestX+offestY*offestY);
    return distance;
}

- (void)btnClick{

    [self startDestoryAnimation];
    [self killAll];
}

- (void)killAll {

    [self removeFromSuperview];
    [self.smallCircleView removeFromSuperview];
    self.smallCircleView = nil;
    [self.shapeLayer removeFromSuperlayer];
    self.shapeLayer = nil;
}

- (void)startDestoryAnimation {
    UIImageView *ainmImageView = [[UIImageView alloc] initWithFrame:self.frame];
    ainmImageView.animationImages = self.images;
    ainmImageView.animationRepeatCount = 1;
    ainmImageView.animationDuration = 0.5;
    [ainmImageView startAnimating];
    [self.superview addSubview:ainmImageView];
}
#pragma mark - 设置高亮状态抖动动画
- (void)setHighlighted:(BOOL)highlighted
{
    [self.layer removeAnimationForKey:@"shake"];
    CGFloat shake = 10;
    
    CAKeyframeAnimation *keyAnim = [CAKeyframeAnimation animation];
    keyAnim.keyPath = @"transform.translation.x";
    keyAnim.values = @[@(-shake), @(shake), @(-shake)];
    keyAnim.removedOnCompletion = NO;
    keyAnim.repeatCount = MAXFLOAT;
    keyAnim.duration = 0.3;
    [self.layer addAnimation:keyAnim forKey:@"shake"];
}
@end
