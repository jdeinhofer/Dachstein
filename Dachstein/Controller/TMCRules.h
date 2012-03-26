//
//  TMCRules.h
//  Dachstein
//
//  Created by Josef Deinhofer on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TMCModel.h"
#import "TMCGameView.h"
#import "TMCTile.h"


@protocol TMCRulesControllerDelegate

- (void) prepareGame;
- (void) startGame;
- (void) endGame;

@property (readonly) TMCGameView *view;

@end

@protocol TMCRules <NSObject>

- (id <TMCRules>) initWithController: (id <TMCRulesControllerDelegate>) model;
- (void) update: (ccTime) delta;
- (void) pickedTile: (TMCTile*) tile;
- (void) prepareGame;
- (void) startGame;

@end

