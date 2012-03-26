//
//  Column.h
//  Dachstein
//
//  Created by Josef Deinhofer on 9/1/11.
//  Copyright 2011 TheMountainCalls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMCModel.h"
#import "TMCTile.h"

@class TMCModel;

@interface TMCColumn : NSObject {
    
    int _top;
    int _x;
    int _y;
    int _targetDepth;
    
    TMCColumn* _NW;
    TMCColumn* _N;
    TMCColumn* _NE;
    TMCColumn* _SE;
    TMCColumn* _S;
    TMCColumn* _SW;
    
    TMCColumn* _directions[8];
    
    TMCTile* _tile;
}

- (id) initWithDepth: (int) depthArg x: (int) xArg y: (int) yArg;
- (void) reset;
- (void) configureWithModel: (TMCModel*) model;
- (BOOL) isPickable;
- (void) pick;

@property int top;
@property int x;
@property int y;
@property (readonly) int targetDepth;
@property (assign) TMCTile* tile;
@property (readonly) CCNode* node;
@property (readonly) CCSprite* view;

@end
