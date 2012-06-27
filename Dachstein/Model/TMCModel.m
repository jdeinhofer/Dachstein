//
//  Model.m
//  Dachstein
//
//  Created by Josef Deinhofer on 9/9/11.
//  Copyright 2011 TheMountainCalls. All rights reserved.
//

#import "TMCModel.h"


@interface TMCModel ()
- (void)initializeColumns;
- (void)configureColumns;
- (void)initializeDeck;
- (int)countMatchableTiles;
- (void)addColumnAtDepth:(int)depthArg x:(int)xArg y:(int)yArg;
@end

@implementation TMCModel {
    TMCColumn *mColumnRaster [COLUMNS_NUM][COLUMNS_NUM];
    NSMutableArray *_columns;
    NSMutableArray *_deck;
    TMCColumn *_centerColumn;
}

- (id)init
{
    self = [super init];
    if (self) {
        srandom((unsigned int)time(NULL));

        [self initializeColumns];
        [self initializeDeck];
        [self configureColumns];
    }
    
    return self;
}
- (void) initializeColumns
{
    _columns = [[NSMutableArray alloc] init];

    [self addColumnAtDepth: 0 x: 0 y: 0];
    _centerColumn = [_columns objectAtIndex:0];

    // 1 / n
    [self addColumnAtDepth:1 x:-1 y:-1];
    [self addColumnAtDepth:1 x:0 y:-1];
    [self addColumnAtDepth:1 x:1 y:-1];

    // 1 / e/w
    [self addColumnAtDepth:1 x:-1 y:0];
    [self addColumnAtDepth:1 x:1 y:0];

    // 1 / s
    [self addColumnAtDepth:1 x:-1 y:1];
    [self addColumnAtDepth:1 x:0 y:1];
    [self addColumnAtDepth:1 x:1 y:1];

    // 2 / n
    [self addColumnAtDepth:2 x:-1 y:-2];
    [self addColumnAtDepth:2 x:0 y:-2];
    [self addColumnAtDepth:2 x:1 y:-2];

    // 2 / s
    [self addColumnAtDepth:2 x:-1 y:2];
    [self addColumnAtDepth:2 x:0 y:2];
    [self addColumnAtDepth:2 x:1 y:2];

    // 2 / e
    [self addColumnAtDepth:2 x:-2 y:1];
    [self addColumnAtDepth:2 x:-2 y:0];
    [self addColumnAtDepth:2 x:-2 y:-1];

    // 2 / w
    [self addColumnAtDepth:2 x:2 y:1];
    [self addColumnAtDepth:2 x:2 y:0];
    [self addColumnAtDepth:2 x:2 y:-1];
}

- (void) addColumnAtDepth: (int) depthArg x: (int) xArg y: (int) yArg
{
    TMCColumn* column = [[[TMCColumn alloc] initWithDepth: depthArg x: xArg y: yArg] autorelease];
    [_columns addObject: column];
    mColumnRaster[xArg + COLUMNS_OFFSET][yArg + COLUMNS_OFFSET] = column;
}

- (void) configureColumns
{
    for (TMCColumn* column in _columns) {
        [column configureWithModel: self];
    }
}

- (void) resetColumns
{
    for (TMCColumn* column in _columns) {
        [column reset];
    }
}

- (void) initializeDeck
{
    _deck = [[NSMutableArray alloc] init];
    for (int color = 0; color < NUM_COLORS; color++) {
        for (int value = 0; value < NUM_VALUES; value++) {
            id tile = [[[TMCTile alloc] initWithColor:color Value:value] autorelease];
            [_deck addObject:tile];
        }
    }
}

- (void)sortColumnsByTopOffset {
    [_columns sortUsingComparator:^(TMCColumn* columnA, TMCColumn* columnB) {
       if (columnA.topOffset > columnB.topOffset)    return (NSComparisonResult)NSOrderedDescending;
       if (columnA.topOffset < columnB.topOffset)    return (NSComparisonResult)NSOrderedAscending;
       return (NSComparisonResult)NSOrderedSame;
    }];
}

- (int)countMatchableTiles {
    NSMutableArray *matchableTiles = [NSMutableArray array];
    for (TMCTile *tile in _deck) {
        if (tile.pickable > 1)
            [matchableTiles addObject:tile];
    }
    int matchables = matchableTiles.count;
    return matchables;
}

- (TMCTile *)randomizeTileFor:(TMCColumn *)column
{
    [self updateTileStats];

    CCLOG(@"randomizing column %i %i", column.x, column.y);

    if ([self countMatchableTiles] < 2) {
        CCLOG(@"not enough matching tiles, choosing a match-able tile");
        NSMutableArray *availableTiles = [NSMutableArray array];
        for (TMCTile *tile in _deck) {
            if (tile.pickable > 0) {
                [availableTiles addObject:tile];
            }
        }

        return [availableTiles objectAtIndex:(NSUInteger)(random() % availableTiles.count)];
    }

    else if (column.topOffset > 0) {
        NSMutableArray *impracticalTiles = [NSMutableArray array];
        for (TMCTile *tile in _deck) {
            if (tile.inUse == 0) {
                [impracticalTiles addObject:tile];
            }
        }
        if (impracticalTiles.count == 0) {
            for (TMCTile *tile in _deck) {
                if (tile.pickable == 0) {
                    [impracticalTiles addObject:tile];
                }
            }
        }
        if (impracticalTiles.count > 0) {
            CCLOG(@"lower-than-desired column, choosing from impractical tiles");
            return [impracticalTiles objectAtIndex:(NSUInteger)(random() % impracticalTiles.count)];
        }
        else {
            CCLOG(@"lower-than-desired column, but failed to find an impractical tile");
        }
    }


    CCLOG(@"pruning selection of available tiles by topOffset, choosing from at least 3");

    [self sortColumnsByTopOffset];
    NSMutableArray *availableTiles = [[_deck mutableCopy] autorelease];

    int columnsIndex = _columns.count;

    while (availableTiles.count > 3 && columnsIndex > 0) {
        columnsIndex--;
        TMCColumn *tmpC = [_columns objectAtIndex:(NSUInteger)columnsIndex];

        if (tmpC.topOffset == 0) break;

        TMCTile *tile = tmpC.tile;
        [availableTiles removeObject:tile];
        CCLOG(@"pruning [%i %i] because it is contained in [%i %i] with topOffset %i", tile.color, tile.value, tmpC.x, tmpC.y, tmpC.topOffset);
    }

    for (TMCTile *availableTile in availableTiles) {
        CCLOG(@"available: [%i %i]", availableTile.color, availableTile.value);
    }

    TMCTile *ret = [availableTiles objectAtIndex:(NSUInteger)random() % availableTiles.count];

    return ret;
}

- (void) randomizeInitialTiles
{
    [self resetColumns];
    
    for (TMCColumn* column in _columns) {
        [column setTile:[_deck objectAtIndex:(NSUInteger)(random() % _deck.count)]];
    }
}

- (void) updateTileStats
{
    for (TMCTile* tile in _deck) {
        [tile resetStats];
    }
    
    for (TMCColumn* column in _columns) {
        TMCTile* tile = column.tile;
        
        tile.inUse++;
        
        if ([column isPickable]) {
            tile.pickable++;
        }
        
        int topOffset = (column.top - column.targetDepth) - (_centerColumn.top - _centerColumn.targetDepth);
        column.topOffset = topOffset;
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

- (int)getMinTopOffset {
    int minOff = INT32_MAX;

    for (TMCColumn* column in _columns) {
        minOff = MIN(minOff, [column top]);
    }
    
    return minOff;
}

- (void) raiseByOne {
    for (TMCColumn* column in _columns) {
        column.top--;
    }
}

- (BOOL) noMatchingTiles
{
    [self updateTileStats];

    for (TMCTile *tile in _deck) {
        if (tile.pickable > 1)
            return FALSE;
    }

    return TRUE;
}

- (TMCColumn *) swapHighestPickableColumn
{
    // determine the highest pickable column
    TMCColumn *highest = [self getColumnAtX:COLUMNS_OFFSET Y:COLUMNS_OFFSET];
    for (TMCColumn *column in _columns) {
        if ([column isPickable] && column.top < highest.top) {
            highest = column;
        }
    }

    // collect all columns at the this height
    NSMutableArray *highestPickableColumns = [NSMutableArray array];
    for (TMCColumn *column in _columns) {
        if ([column isPickable] && column.top == highest.top) {
            [highestPickableColumns addObject:column];
        }
    }

    // randomly choose one of them
    int randomIndex = random() % highestPickableColumns.count;
    TMCColumn *swappedColumn = [highestPickableColumns objectAtIndex:(NSUInteger) randomIndex];

    // collect all pickable tiles which are not the one swapped out
    NSMutableArray *pickableTiles = [NSMutableArray array];
    TMCTile *swappedTile = swappedColumn.tile;
    for (TMCTile *tile in _deck) {
        if (tile != swappedTile && tile.pickable > 0) {
            [pickableTiles addObject:tile];
        }
    }

    // randomly choose one of those
    randomIndex = random() % pickableTiles.count;
    TMCTile *swappedInTile = [pickableTiles objectAtIndex:(NSUInteger)randomIndex];

    swappedColumn.tile = swappedInTile;

    CCLOG(@"SWAPPING COLUMN AT %i %i", swappedColumn.x, swappedColumn.y);

    return swappedColumn;
}

- (void) dealloc {
    [_columns release];
    [_deck release];

    [super dealloc];
}

@end
