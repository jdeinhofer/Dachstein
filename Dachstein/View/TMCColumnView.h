//
//  TMCColumnView.h
//  Dachstein
//
//  Created by Josef Deinhofer on 2/13/12.
//  Copyright (c) 2012 TheMountainCalls. All rights reserved.
//

#import "CCNode.h"
#import "TMCColumn.h"

#define SNAP_DURATION 0.20f
#define SNAP_DISTANCE -500

#define DROP_DURATION 0.20f
#define DROP_DISTANCE -1000

#define RAISE_DURATION 0.2f

#define SHADE_OPACITY_QUADRATIC 25.0f
#define SHADE_OPACITY_LINEAR 25.0f
#define SHADE_OPACITY_PERY 0.3f
#define SHADE_OPACITY_MAX 200.0f

#define SPRITE_OFFSET_FACTOR_Y 0.86f
#define SPRITE_OFFSET_FACTOR_Z (1.0f - SPRITE_OFFSET_FACTOR_Y)
#define SCALE 1.0f

#define WIGGLE_DURATION_HORIZONTAL 0.1f
#define WIGGLE_HORIZONTAL 2.0f
#define WIGGLE_DURATION_ROTATION 0.06f
#define WIGGLE_ANGLE 2.0f


@interface TMCColumnView : CCNode {
    TMCColumn* _column;
    CCSprite* _sprite;

    CCSprite* _shadow;
}

- (id) initWithColumn: (TMCColumn*) column;
- (void) refresh;

- (CGPoint)calculatePosition;

- (void) startRaiseAnim;
- (void) startSnapAnim: (float) duration;
- (void) startDropAnim: (float) delay;
- (void) startWiggleAnim;


- (int) calculateShadowOpacity;
+ (NSString*) spriteFrameNameForTile: (TMCTile*) tile;

@property (readonly) CCSprite* sprite;
@property (readonly) TMCColumn* column;

@end
