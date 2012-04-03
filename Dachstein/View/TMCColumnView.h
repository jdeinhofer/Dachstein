//
//  TMCColumnView.h
//  Dachstein
//
//  Created by Josef Deinhofer on 2/13/12.
//  Copyright (c) 2012 TheMountainCalls. All rights reserved.
//

#import "TMCColumn.h"

#define SNAP_DURATION 0.20f

#define BLUE 0
#define GREEN 1
#define RED 2

@interface TMCColumnView : CCNode

- (id) initWithColumn: (TMCColumn*) column;
- (void) refresh;
- (void) startRaiseAnim;
- (void) startSnapAnim: (float) duration;
- (void) startDropAnim: (float) delay;
- (void) startWiggleAnim;

+ (NSString*) spriteFrameNameForTile: (TMCTile*) tile;

@property (readonly) CCSprite* sprite;
@property (readonly) TMCColumn* column;

@end
