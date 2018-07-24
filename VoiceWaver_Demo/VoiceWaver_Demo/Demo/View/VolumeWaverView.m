//
//  VolumeWaverView.m
//  VoiceWaver_Demo
//
//  Created by MrYeL on 2018/7/20.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import "VolumeWaverView.h"
#import "GridsView.h"

@interface VolumeWaverView()

@property (strong, nonatomic) NSOperationQueue *queue;

/** <#desc#>*/
@property (nonatomic, strong) GridsView * gridsView;

@end



@implementation VolumeWaverView

- (UIView *)gridsView {
    
    if (_gridsView == nil) {
        _gridsView = [[GridsView alloc] initWithFrame:self.bounds];
        [_gridsView configLineWidth:Xmargin andXcount:Xcount yCount:10];

    }
    return _gridsView;
}

- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 5;
    }
    return _queue;
}

- (instancetype)initWithFrame:(CGRect)frame andType:(VolumeWaverType)type {

    if (self = [self initWithFrame:frame]) {
        
        self.showType = type;
    }
    return self;
    
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeRedraw;
        self.backgroundColor = [UIColor cyanColor];
        
        //监听声波改变
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView:) name:@"updateMeters" object:nil];

    }
    return self;
}
#pragma mark - Action
- (void)updateView:(NSNotification *)notice{
    
    self.soundMeters = notice.object;
//    [self setNeedsDisplay];
}

- (void)setSoundMeters:(NSArray *)soundMeters {
    [self.queue addOperationWithBlock:^{
    
        NSArray *objectArray = soundMeters;
        NSInteger count = objectArray.count;
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:objectArray];
        NSMutableArray *valueArray = [NSMutableArray array];
        int index = 0;
        for (int i = 0; i < count; i ++) {
            if (!tempArray.count) {
                break;
            }
            index = arc4random() % tempArray.count;
            NSNumber *value = tempArray[index];
            if (![value isKindOfClass:[NSNumber class]]) {
                continue;
            }
            [valueArray addObject:value];
            [tempArray removeObjectAtIndex:index];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            _soundMeters = valueArray;
            [self setNeedsDisplay];
        });
    }];
}
- (void)drawRect:(CGRect)rect {
    
    if (self.soundMeters && self.soundMeters.count) {
        // 上下文
        CGContextRef context = UIGraphicsGetCurrentContext();
        // 设置线的顶角样式
        CGContextSetLineCap(context, kCGLineCapSquare);
        // 设置线的连接样式
        CGContextSetLineJoin(context, kCGLineJoinRound);
        // 颜色
        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        
        CGFloat noVoice = -46.0;// 该值代表低于-46.0的声音都认为无声音
        CGFloat maxVolume = 55.0; // 该值代表最高声音为55.0
        
        switch (self.showType) {
            case VolumeWaverType_Bar:{
                
                CGFloat lineWidth = (self.frame.size.width - (Xcount -1)*Xmargin )/Xcount;
                //线宽
                CGContextSetLineWidth(context, lineWidth);
                
//                UIBezierPath *path = [UIBezierPath bezierPath];//
                
                for (int i = 0; i < self.soundMeters.count; i ++) {
                    
                    CGFloat soundValue = [self.soundMeters[self.soundMeters.count - i - 1] floatValue];
                    CGFloat barHeight = maxVolume - (soundValue - noVoice);
                    CGPoint point = CGPointMake(i * ( Xmargin + lineWidth)+ lineWidth *0.5, rect.size.height);
                  
//                    [path moveToPoint:point];
//                    [path addLineToPoint:CGPointMake(point.x, barHeight)];
                    
                    CGContextMoveToPoint(context, point.x, point.y);
                    CGContextAddLineToPoint(context, point.x, barHeight);

                }
                
                //添加
//                CGContextAddPath(context, path.CGPath);
                
            }
                break;
                
            case VolumeWaverType_Line:{
                
//                CGFloat lineWidth = 1.5;
//                CGContextSetLineWidth(context, lineWidth);
//                for (int i = 0; i < self.soundMeters.count; i ++) {
//
//                    CGFloat soundValue = [self.soundMeters[i] floatValue];
//                    CGFloat barHeight = maxVolume - (soundValue - noVoice);
//
//                    CGPoint point = CGPointMake(i * lineWidth * 2 + lineWidth, rect.size.height);
//                    CGContextAddLineToPoint(context, point.x, barHeight);
//                    CGContextMoveToPoint(context, point.x, barHeight);

//                }
                
            }
                
                break;
                
            default:
                break;
        }
        
        CGContextStrokePath(context);
        
        [self addSubview: self.gridsView];
        
    }
    
}
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
