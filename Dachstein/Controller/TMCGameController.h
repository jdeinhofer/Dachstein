//
//  TMCGameController.h
//  Dachstein
//
//  Created by Josef Deinhofer on 12/7/11.
//  Copyright 2011 TheMountainCalls. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SimpleAudioEngine.h"

#import "TMCModel.h"
#import "TMCTile.h"
#import "TMCColumn.h"
#import "TMCGameView.h"
#import "TMCScoring.h"
#import "TMCRules.h"
#import "TMCRulesClassic.h"


#define HINT_TIMER_DELAY 8.0f

typedef enum {
    GAMESTATE_NEW,
    GAMESTATE_INIT,
    GAMESTATE_RUNNING,
    GAMESTATE_GAMEOVER
} TMCGameState;


@interface TMCGameController : NSObject <TMCViewControllerDelegate, TMCRulesControllerDelegate>
{
    TMCModel* _model;
    TMCGameView* _view;
    id <TMCRules> _rules;

    TMCGameState _gameState;

    TMCColumnView* _selectedColumnView;
}

- (CCScene*) scene;

- (void) resetHintTimer;
- (void) showHint;
- (void) setSelectedView: (TMCColumnView*) view;
- (void) startBackgroundAmbience;
- (void) startBackgroundMusic;
- (void) prepareGame;
- (void) startGame;
- (void) endGame;
- (void) enableGame;
- (void) update: (ccTime) delta;

@property (readonly) TMCGameView *view;


@end
