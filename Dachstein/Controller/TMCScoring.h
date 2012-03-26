//
//  TMCScoring.h
//  Dachstein
//
//  Created by Josef Deinhofer on 2/16/12.
//  Copyright (c) 2012 TheMountainCalls. All rights reserved.
//

#import "TMCModel.h"

#define SCORE_BASE 100
#define SCORE_BONUS 5

@interface TMCScoring : NSObject {
    TMCModel* _model;

    TMCTile* _lastTile;
    int _bonusLevel;

    int _score;
    int _scoreGainBase;
    int _scoreGainBonus;
    int _scoreGainTotal;

    int _highScore;
}

- (id) initWithModel: (TMCModel*) model;
- (void) reset;
- (void) updateScoreWithTile: (TMCTile*) tile;

@property (readonly) int score;
@property (readonly) int scoreGainBase;
@property (readonly) int scoreGainBonus;

@property (readonly) int highScore;

@end
