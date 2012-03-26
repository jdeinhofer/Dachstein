//
//  Tile.m
//  Dachstein
//
//  Created by Josef Deinhofer on 9/1/11.
//  Copyright 2011 TheMountainCalls. All rights reserved.
//

#import "TMCTile.h"

@implementation TMCTile

@synthesize value=_value;
@synthesize color=_color;
@synthesize inUse=_inUse;
@synthesize pickable=_pickable;
@synthesize topOffset=_topOffset;

- (id) initWithColor:(int)colorArg Value:(int)valueArg
{
    self = [self init];
    
    self.color = colorArg;
    self.value = valueArg;
    
    return self;
}

- (void) resetStats
{
    _inUse = 0;
    _pickable = 0;
    _topOffset = 0;
}

@end
