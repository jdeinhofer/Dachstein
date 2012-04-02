//
//  Model.h
//  Dachstein
//
//  Created by Josef Deinhofer on 9/9/11.
//  Copyright 2011 TheMountainCalls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMCColumn.h"
#import "TMCTile.h"
#import "GameConfig.h"

#define COLUMNS_NUM 5
#define COLUMNS_OFFSET (COLUMNS_NUM / 2)

@class TMCColumn;

@interface TMCModel : NSObject

- (void) resetColumns;
- (void) randomizeInitialTiles;
- (void) updateTileStats;
- (TMCColumn*) getColumnAtX: (int) x Y: (int) y;
- (TMCTile*) randomizeTileFor: (TMCColumn*) column;
- (int) getMinTopOffset;
- (void) raiseByOne;
- (BOOL) noMatchingTiles;
- (TMCColumn *) swapHighestPickableColumn;

@end

