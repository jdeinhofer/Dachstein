//
//  Model.m
//  Dachstein
//
//  Created by Josef Deinhofer on 9/9/11.
//  Copyright 2011 TheMountainCalls. All rights reserved.
//

#import "TMCModel.h"
#import "TMCColumn.h"
#import <stdlib.h>
#import <time.h>


@implementation TMCModel

int weightedRandom(int count) {
    int weighted = ABS((random() % count) + (random() % count) - count);
    if (weighted == count) return 0; // TODO: understand why "count" can even happen as a value
    return weighted;
}

- (id)init
{
    self = [super init];
    if (self) {
        srandom(time(NULL));
        
        [self initializeColumns];
        [self initializeDeck];
        
        [self configureColumns];
    }
    
    return self;
}

- (void) initializeColumns
{
    _model = [[NSMutableArray alloc] init];
    
    [self addColumnAtDepth: 0 x: 0 y: 0];
    _centerColumn = [_model objectAtIndex:0];
    
    for (int d = 1; d <= COLUMNS_OFFSET; d++) {
        // horizontal rows
        for (int x = -d; x <= 0; x++) {
            [self addColumnAtDepth: d x: x y: -d];
            [self addColumnAtDepth: d x: x + d y: d];
        }
        
        // vertical rows
        for (int y = -d + 1; y <= 0; y++) {
            [self addColumnAtDepth: d x: -d y: y];
            [self addColumnAtDepth: d x: d y: -y];
        }
        
        // skewed rows
        for (int off = 1; off < d; off++) {
            [self addColumnAtDepth: d x: -d + off y: off];
            [self addColumnAtDepth: d x: d - off y: -off];
        }
    }
}

- (void) addColumnAtDepth: (int) depthArg x: (int) xArg y: (int) yArg
{
    if (DEBUG_OUTPUT) {
        CCLOG(@"new column added at %i,%i d:%i", xArg, yArg, depthArg);
    }
    
    TMCColumn* column = [[TMCColumn alloc] initWithDepth: depthArg x: xArg y: yArg];
    [column retain];
    [_model addObject: column];
    mColumnRaster[xArg + COLUMNS_OFFSET][yArg + COLUMNS_OFFSET] = column;
}

- (void) configureColumns
{
    for (TMCColumn* column in _model) {
        [column configureWithModel: self];
    }
}

- (void) resetColumns
{
    for (TMCColumn* column in _model) {
        [column reset];
    }
}

- (void) initializeDeck
{
    _deck = [[NSMutableArray alloc] init];
    for (int color = 0; color < NUM_COLORS; color++) {
        for (int value = 0; value < NUM_VALUES; value++) {
            id tile = [[TMCTile alloc] initWithColor:color Value:value];
            [_deck addObject:tile];
        }
    }
}

- (void) resetDeck
{
    for (TMCTile* tile in _deck) {
        [tile resetStats];
    }
}

- (TMCTile*) randomizeTileFor: (TMCColumn*) column
{
    NSMutableArray* availableTiles;
    
    int vdist = (column.top - column.targetDepth) - (_centerColumn.top - _centerColumn.targetDepth);
    if (vdist > 0) {
        
        [self updateTileStats];
        availableTiles = [[[NSMutableArray alloc] init] autorelease];
        bool isPickable = [column isPickable];
        
        availableTiles = availableTiles;
        
        for (TMCTile* tile in _deck) {
            int numPickable = tile.pickable;
            if (isPickable && numPickable == 0) {
                CCLOG(@"considering tile %i/%i, because of %i/%i", tile.color, tile.value, isPickable, numPickable);
                [availableTiles addObject:tile];
            }
        }

        if ([availableTiles count] < 1) {
            [_model sortUsingComparator:^(TMCColumn* columnA, TMCColumn* columnB) {
                if (columnA.top > columnB.top)    return (NSComparisonResult)NSOrderedDescending;
                if (columnA.top < columnB.top)    return (NSComparisonResult)NSOrderedAscending;
                return (NSComparisonResult)NSOrderedSame;
            }];

            // find topmost pickable column with a tile that has no match yet
            for (TMCColumn* column in _model) {
                if (column.tile.pickable < 2) {
                    [availableTiles addObject:column.tile];
                    break;
                }
            }
            CCLOG(@"no safe tiles found, choosing from those used in the highest columns");
        }
    }
    else {
        availableTiles = _deck;
        CCLOG(@"choosing from all tiles");
    }

    // HOTFIX!
    if ([availableTiles count] < 1) {
        availableTiles = _deck;
    }
    
    int index = random() % [availableTiles count];
    TMCTile* tile = [availableTiles objectAtIndex:index];
    
    return tile;
    
    
//    [self updateTileStats];
//    
//    [_deck sortUsingComparator:^(TMCTile* tileA, TMCTile* tileB) {
//        int tileAValue = tileA.pickable * 10 + tileA.topOffset * 30 + tileA.inUse;
//        int tileBValue = tileB.pickable * 10 + tileB.topOffset * 30 + tileB.inUse;
//        if (tileAValue > tileBValue)    return (NSComparisonResult)NSOrderedDescending;
//        if (tileAValue < tileBValue)    return (NSComparisonResult)NSOrderedAscending;        
//        return (NSComparisonResult)NSOrderedSame;
//    }];
//    
//    int index = weightedRandom([_deck count] / 3);
//    TMCTile* tile = [_deck objectAtIndex:index];
//    
//    return tile;
}

- (void) randomizeInitialTiles
{
    [self resetColumns];
    
    for (TMCColumn* column in _model) {
        [column setTile:[self randomizeTileFor:column]];
    }
}

- (void) updateTileStats
{
    for (TMCTile* tile in _deck) {
        [tile resetStats];
    }
    
    for (TMCColumn* column in _model) {
        TMCTile* tile = column.tile;
        
        tile.inUse++;
        
        if ([column isPickable]) {
            tile.pickable++;
        }
        
        int topOffset = (column.top - column.targetDepth) - (_centerColumn.top - _centerColumn.targetDepth);
        tile.topOffset += topOffset;
    }
}
 
- (TMCColumn*) getColumnAtX:(int)x Y:(int)y
{
    if (x < -COLUMNS_OFFSET) return nil;
    if (x > COLUMNS_OFFSET) return nil;
    if (y < -COLUMNS_OFFSET) return nil;
    if (y > COLUMNS_OFFSET) return nil;
    
    id column = mColumnRaster[x + COLUMNS_OFFSET][y + COLUMNS_OFFSET];
    
    return column;
}

- (NSMutableArray*) getUpdatedDeck
{
    [self updateTileStats];
    return _deck;
}

- (int)getMinTopOffset {
    int minOff = INT32_MAX;

    for (TMCColumn* column in _model) {
        minOff = MIN(minOff, [column top]);
    }
    
    return minOff;
}


- (void) raiseByOne {
    for (TMCColumn* column in _model) {
        column.top--;
    }
}

@end
