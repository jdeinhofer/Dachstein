//
//  TMCGameView.h
//  Dachstein
//
//  Created by Josef Deinhofer on 12/7/11.
//  Copyright 2011 TheMountainCalls. All rights reserved.
//

#import "TMCColumnView.h"
#import "TMCHudClassic.h"

@protocol TMCViewControllerDelegate
@required
- (void) columnViewTouched: (id) columnView onRelease: (BOOL) onRelease;
- (void) update: (ccTime) delta;
@end

@interface TMCGameView : CCLayer

- (id)initWithControllerDelegate:(id <TMCViewControllerDelegate>)delegate model:(TMCModel *)model;
- (void)showHud:(id)hud;
- (void)reset;
- (void)playGameStartAnimations;
- (void)playGameOverAnimations;
- (void)playWiggleAnimFor:(TMCColumnView *)view;
- (void)updateVerticalOffset;
- (void)setSelectionTo:(TMCColumnView *)view;
- (void)showHintOn:(TMCColumnView *)view;
- (NSArray *)getPickableColumnViewsExcluding:(TMCColumnView *)excludedView;
- (void)setLevel:(int)level;
- (void)swapViewFor:(TMCColumn *)column;

+ (BOOL)isLowRes;

@property(readonly, assign) TMCHudClassic *hudClassic;

@end
