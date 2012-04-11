//
//  TMCTimer.m
//  Dachstein
//
//  Created by Josef Deinhofer on 2/16/12.
//  Copyright (c) 2012 TheMountainCalls. All rights reserved.
//

#import "TMCTimer.h"

#define OPACITY_PER_PROGRESS 128

#define ANIMATION_DURATION_OPACITY 3.0f
#define ANIMATION_DURATION_PROGRESS 0.5f

@implementation TMCTimer {
    CCProgressTimer *_timer;
    CCProgressTimer *_light;

    float _visibleProgress;
    float _desiredProgress;

    float _visibleOpacity;
    float _desiredOpacity;

    float _animationDuration;
}

- (id) init
{
    self = [super init];
    if (self) {
        CCSprite* background = [CCSprite spriteWithSpriteFrameName:@"TimerBar_BG.png"];

        _timer = [CCProgressTimer progressWithFile:@"TimerBar_FG.png"];
        _timer.type = kCCProgressTimerTypeHorizontalBarRL;
        _timer.percentage = 100;

        _light = [CCProgressTimer progressWithFile:@"TimerBar_FG_Light.png"];
        _light.type = kCCProgressTimerTypeHorizontalBarRL;
        _light.sprite.opacity = OPACITY_PER_PROGRESS;
        _light.percentage = 100;

        _visibleProgress = 1.0f;
        _desiredProgress = 1.0f;

        _visibleOpacity = OPACITY_PER_PROGRESS;
        _desiredOpacity = OPACITY_PER_PROGRESS;

        [self addChild:background];
        [self addChild:_timer];
        [self addChild:_light];
    }
    
    return self;
}


- (void) setProgress: (float) progress
{
    if (_visibleProgress < progress) {
        _desiredProgress = progress;
        _desiredOpacity = progress * OPACITY_PER_PROGRESS;
        _visibleOpacity = 255;
        _animationDuration = 0;
    }
    else
    {
        _visibleProgress = _desiredProgress = progress;
        _desiredOpacity = _visibleProgress * OPACITY_PER_PROGRESS;
    }

    _timer.percentage = 100 * _visibleProgress;
    _light.percentage = 100 * _visibleProgress;

    GLubyte opacity = (GLubyte)(_visibleOpacity);
    _light.sprite.opacity = opacity;
}

- (void) setProgressImmediately: (float) progress
{
    _desiredProgress = progress;
    _desiredOpacity = progress * OPACITY_PER_PROGRESS;
    _visibleOpacity = _desiredOpacity;
    _visibleProgress = _desiredProgress;

    _timer.percentage = 100 * _visibleProgress;
    _light.percentage = 100 * _visibleProgress;
    _light.sprite.opacity = (GLubyte)_desiredOpacity;
}

- (void) update: (ccTime) delta
{
    _animationDuration += delta;

    float animationProgress = MIN(ANIMATION_DURATION_PROGRESS, _animationDuration);
    float factor = animationProgress / ANIMATION_DURATION_PROGRESS;
    _visibleProgress = (1 - factor) * _visibleProgress + factor * _desiredProgress;

    float animationOpacity = MIN(ANIMATION_DURATION_OPACITY, _animationDuration);
    factor = animationOpacity / ANIMATION_DURATION_OPACITY;
    factor *= factor;
    _visibleOpacity = (1 - factor) * _visibleOpacity + factor * _desiredOpacity;
}

@end
