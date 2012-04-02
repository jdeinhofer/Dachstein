//
//  TMCGameView.h
//  Dachstein
//
//  Created by Josef Deinhofer on 12/7/11.
//  Copyright 2011 TheMountainCalls. All rights reserved.
//

#import "TMCColumnView.h"
#import "TMCTimer.h"
#import "TMCHudClassic.h"
#import "TMCSelectionHighlight.h"
#import "TMCHint.h"
#import "TMCBackground.h"

@protocol TMCViewControllerDelegate
@required
- (void) columnViewTouched: (id) columnView onRelease: (BOOL) onRelease;
- (void) update: (ccTime) delta;
@end

@interface TMCGameView : CCLayer
{
    id <TMCViewControllerDelegate> _controllerDelegate;

    CCNode* _columnViewsRoot;
    NSMutableArray* _columnViews;
    TMCBackground* _background;

    TMCSelectionHighlight* _selection;
    TMCHint* _hint;

    TMCHudClassic *_hudClassic;
    NSArray *_huds;
}

- (id)initWithControllerDelegate:(id <TMCViewControllerDelegate>)delegate model:(TMCModel *)model;
- (void)setupResourcesAndLayout:(CGSize)screensize;
- (void)setupColumnViewsFromModel:(TMCModel *)model;

- (void)setupBackground;
- (void)setupHudsWith:(CGSize)screenSize;
- (void)showHud:(id)hud;
- (void)reset;
- (id)findColumnTouchedBy:(UITouch *)touch;
- (void)playGameStartAnimations;
- (void)playGameOverAnimations;
- (void)playWiggleAnimFor:(TMCColumnView *)view;
- (void)updateVerticalOffset;
- (void)setSelectionTo:(TMCColumnView *)view;
- (void)showHintOn:(TMCColumnView *)view;
- (NSArray *)getPickableColumnViewsExcluding:(TMCColumnView *)excludedView;
- (void)setLevel:(int)level;
+ (BOOL)isLowRes;

@property(readonly, assign) TMCHudClassic *hudClassic;

@end
