//
//  TMCScoring.m
//  Dachstein
//
//  Created by Josef Deinhofer on 2/16/12.
//  Copyright (c) 2012 TheMountainCalls. All rights reserved.
//

#import "TMCScoring.h"

@implementation TMCScoring

@synthesize score=_score;
@synthesize scoreGainBase=_scoreGainBase;
@synthesize scoreGainBonus=_scoreGainBonus;
@synthesize highScore=_highScore;

- (id) initWithModel: (TMCModel*) model
{
    self = [super init];
    if (self) {
        _model = model;
        [self reset];
        _highScore = 0;
    }
    
    return self;
}

- (void) reset {
    _lastTile = nil;

    _score = 0;
    _scoreGainBase = 0;
    _scoreGainBonus = 0;
    _scoreGainTotal = 0;
    _bonusLevel = 0;
}

- (void) updateScoreWithTile: (TMCTile*) tile
{
    // very first tile
    if (_lastTile == nil) {
        _scoreGainBase = SCORE_BASE;
        _scoreGainBonus = 0;
        CCLOG(@"FIRST TILE! (%i %i)", tile.color, tile.value);
    }
    // a tile matching in at least one aspect
    else if (_lastTile.value == tile.value || _lastTile.color == tile.color) {

        if (_lastTile == tile) {
            _scoreGainBase += SCORE_BASE / 2;
            _bonusLevel += 2;
            _scoreGainBonus = _scoreGainBase;
            CCLOG(@"SAME TILE! (%i %i)", tile.color, tile.value);
        } else {
            _scoreGainBase += SCORE_BASE / 10;
            _bonusLevel += 1;
            _scoreGainBonus = _scoreGainBase / 2;
            CCLOG(@"FITTING TILE! (%i %i)", tile.color, tile.value);
        }
    }
    // a totally unrelated tile
    else {
        _scoreGainBonus = 0;
        _bonusLevel = 0;
        CCLOG(@"ANY TILE! (%i %i)", tile.color, tile.value);
    }

    _scoreGainTotal = _scoreGainBase + _scoreGainBonus;
    
    _score += _scoreGainTotal;
    _highScore = MAX(_score, _highScore);
    
    CCLOG(@"SCORE: %i  %i %i %i", _score, _scoreGainBase, _scoreGainBonus, _bonusLevel);

    _lastTile = tile;
}

@end
