//
//  TMCGameController.h
//  Dachstein
//
//  Created by Josef Deinhofer on 12/7/11.
//  Copyright 2011 TheMountainCalls. All rights reserved.
//

//#import <Foundation/Foundation.h>

#import "TMCGameView.h"
#import "TMCRules.h"


typedef enum {
    GAMESTATE_NEW,
    GAMESTATE_INIT,
    GAMESTATE_RUNNING,
    GAMESTATE_GAMEOVER
} TMCGameState;

@interface TMCGameController : NSObject <TMCViewControllerDelegate, TMCRulesControllerDelegate>

- (CCScene*) scene;
- (void) update: (ccTime) delta;

@property (readonly) TMCGameView *view;

@end
