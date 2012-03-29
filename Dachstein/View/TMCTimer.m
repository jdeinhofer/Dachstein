//
//  TMCTimer.m
//  Dachstein
//
//  Created by Josef Deinhofer on 2/16/12.
//  Copyright (c) 2012 TheMountainCalls. All rights reserved.
//

#import "TMCTimer.h"

@implementation TMCTimer

- (id) init
{
    self = [super init];
    if (self) {
        CCSprite* background = [CCSprite spriteWithSpriteFrameName:@"TimerBar_BG.png"];
        _timer = [CCProgressTimer progressWithFile:@"TimerBar_FG.png"];
        _timer.type = kCCProgressTimerTypeHorizontalBarRL;
        _timer.percentage = 100;
        
        [self addChild:background];
        [self addChild:_timer];
    }
    
    return self;
}

- (void) setProgress: (float) progress
{
    _timer.percentage = 100 * progress;
}

@end
