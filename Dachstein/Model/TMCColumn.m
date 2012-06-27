//
//  Column.m
//  Dachstein
//
//  Created by Josef Deinhofer on 9/1/11.
//  Copyright 2011 TheMountainCalls. All rights reserved.
//

#import "TMCColumn.h"


#define NEIGHBORS_NUM 8
#define FREE_REQUIRED 3

#define DIRECTIONS_NUM (NEIGHBORS_NUM + FREE_REQUIRED - 1)


@implementation TMCColumn {
    TMCColumn* _directions[DIRECTIONS_NUM];
}

@synthesize top=_top;
@synthesize x=_x;
@synthesize y=_y;
@synthesize targetDepth=_targetDepth;
@synthesize tile=_tile;
@synthesize neighbors=_neighbors;
@synthesize topOffset=_topOffset;


- (id) initWithDepth: (int) depthArg x: (int) xArg y: (int) yArg;
{
    self = [super init];
    if (self) {
        _top = depthArg;
        _targetDepth = depthArg;
        _x = xArg;
        _y = yArg;
    }

    return self;
}

- (void) reset
{
    _top = _targetDepth;
    _tile = nil;
}

- (void)configureNeighbors
{
    NSMutableArray *tmp = [[[NSMutableArray alloc] init] autorelease];
    for (int n = 0; n < NEIGHBORS_NUM; n++) {
        TMCColumn *const neighbor = _directions[n];
        if (neighbor != nil) {
            [tmp addObject:neighbor];
        }
    }

    _neighbors = [tmp copy];
}

- (void) configureWithModel:(TMCModel *)model
{
    _directions[0] = [model getColumnAtX:self.x - 1 Y:self.y];
    _directions[1] = [model getColumnAtX:self.x - 1 Y:self.y + 1];
    _directions[2] = [model getColumnAtX:self.x     Y:self.y + 1];
    _directions[3] = [model getColumnAtX:self.x + 1 Y:self.y + 1];
    _directions[4] = [model getColumnAtX:self.x + 1 Y:self.y];
    _directions[5] = [model getColumnAtX:self.x + 1 Y:self.y - 1];
    _directions[6] = [model getColumnAtX:self.x     Y:self.y - 1];
    _directions[7] = [model getColumnAtX:self.x - 1 Y:self.y - 1];
    _directions[8] = _directions[0];
    _directions[9] = _directions[1];

    [self configureNeighbors];
}

- (BOOL)isColumnFree:(TMCColumn *)column {
    return column == nil || [column top] > [self top];
}

- (BOOL) isPickable
{
    for (int corner = 0; corner < 4; corner++) {
        if (
            [self isColumnFree:_directions[corner * 2]] &&
            [self isColumnFree:_directions[corner * 2 + 1]] &&
            [self isColumnFree:_directions[corner * 2 + 2]]
        ) {
            return TRUE;
        }
    }

    return FALSE;
}

- (void) pick
{
    _top++;
    self.tile = nil;
}

- (void) dealloc
{
    [_neighbors release];

    [super dealloc];
}

@end
