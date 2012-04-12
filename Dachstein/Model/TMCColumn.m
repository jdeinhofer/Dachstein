//
//  Column.m
//  Dachstein
//
//  Created by Josef Deinhofer on 9/1/11.
//  Copyright 2011 TheMountainCalls. All rights reserved.
//

#import "TMCColumn.h"


#ifndef VIEW_ORTHO
    #define NEIGHBORS_NUM 6
    #define FREE_REQUIRED 3
#else
    #define NEIGHBORS_NUM 4
    #define FREE_REQUIRED 2
#endif

#define DIRECTIONS_NUM (NEIGHBORS_NUM + FREE_REQUIRED - 1)

@implementation TMCColumn {
    int _top;
    int _x;
    int _y;
    int _targetDepth;
    int _topOffset;

    TMCColumn* _directions[DIRECTIONS_NUM];

    NSArray* _neighbors;

    TMCTile* _tile;
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

- (void)configureNeighbors:(int)numNeighbors
{
    NSMutableArray *tmp = [[[NSMutableArray alloc] init] autorelease];
    for (int n = 0; n < numNeighbors; n++) {
        TMCColumn *const neighbor = _directions[n];
        if (neighbor != nil) {
            [tmp addObject:neighbor];
        }
    }

    _neighbors = [[NSArray alloc] initWithArray:tmp];
}

- (void) configureWithModel:(TMCModel *)model
{
#ifndef VIEW_ORTHO
    _directions[0] = [model getColumnAtX:(self.x - 1)    Y:(self.y - 1)];
    _directions[1] = [model getColumnAtX:(self.x)        Y:(self.y - 1)];
    _directions[2] = [model getColumnAtX:(self.x + 1)    Y:(self.y)];
    _directions[3] = [model getColumnAtX:(self.x + 1)    Y:(self.y + 1)];
    _directions[4] = [model getColumnAtX:(self.x)        Y:(self.y + 1)];
    _directions[5] = [model getColumnAtX:(self.x - 1)    Y:(self.y)];
    _directions[6] = _directions[0];
    _directions[7] = _directions[1];
#else
    _directions[0] = [model getColumnAtX:self.x - 1 Y:self.y];
    _directions[1] = [model getColumnAtX:self.x Y:self.y + 1];
    _directions[2] = [model getColumnAtX:self.x + 1 Y:self.y];
    _directions[3] = [model getColumnAtX:self.x Y:self.y - 1];
    _directions[4] = _directions[0];
#endif


    int numNeighbors = NEIGHBORS_NUM;

    [self configureNeighbors:numNeighbors];

}

- (BOOL) isPickable
{
    int free = 0;

    for (int i = 0; i < DIRECTIONS_NUM; i++) {
        TMCColumn *column = _directions[i];
        if (column == nil || [column top] > [self top]) {
            free++;
            if (free == FREE_REQUIRED)
                return TRUE;
        }
        else free = 0;
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
