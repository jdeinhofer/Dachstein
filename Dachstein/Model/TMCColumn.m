//
//  Column.m
//  Dachstein
//
//  Created by Josef Deinhofer on 9/1/11.
//  Copyright 2011 TheMountainCalls. All rights reserved.
//

#import "TMCColumn.h"

@implementation TMCColumn

@synthesize top=_top;
@synthesize x=_x;
@synthesize y=_y;
@synthesize targetDepth=_targetDepth;
@synthesize tile=_tile;
@synthesize neighbors=_neighbors;


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

- (void) configureWithModel:(TMCModel *)model
{
    _directions[0] =    _NW =   [model getColumnAtX:(self.x - 1)    Y:(self.y - 1)];
    _directions[1] =    _N  =   [model getColumnAtX:(self.x)        Y:(self.y - 1)];
    _directions[2] =    _NE =   [model getColumnAtX:(self.x + 1)    Y:(self.y)];
    _directions[3] =    _SE =   [model getColumnAtX:(self.x + 1)    Y:(self.y + 1)];
    _directions[4] =    _S  =   [model getColumnAtX:(self.x)        Y:(self.y + 1)];
    _directions[5] =    _SW =   [model getColumnAtX:(self.x - 1)    Y:(self.y)];
    _directions[6] =    _NW;
    _directions[7] =    _N;

    NSMutableArray *tmp = [[[NSMutableArray alloc] init] autorelease];
    for (int n = 0; n < 6; n++) {
        TMCColumn *const neighbor = _directions[n];
        if (neighbor != nil) {
            [tmp addObject:neighbor];
        }
    }

    _neighbors = [[NSArray alloc] initWithArray:tmp];
}

- (BOOL) isPickable
{
    int free = 0;
    
    for (int i = 0; i < 8; i++) {
        TMCColumn *column = _directions[i];
        if (column == nil || [column top] > [self top]) {
            free++;
            if (free == 3)
                return TRUE;
        }
        else free = 0;
    }
    
    return FALSE;
}

- (void) pick
{
    _top++;
}

- (void) dealloc
{
    [_neighbors release];

    [super dealloc];
}

@end
