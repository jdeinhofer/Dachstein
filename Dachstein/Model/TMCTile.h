//
//  Tile.h
//  Dachstein
//
//  Created by Josef Deinhofer on 9/1/11.
//  Copyright 2011 TheMountainCalls. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NUM_COLORS 3
#define NUM_VALUES 3

@interface TMCTile : NSObject
{
    int _value;
    int _color;
    int _inUse;
    int _pickable;
    int _topOffset;
}

- (id) initWithColor: (int) colorArg Value:(int) valueArg;
- (void) resetStats;

@property int value;
@property int color;
@property int inUse;
@property int pickable;
@property int topOffset;

@end
