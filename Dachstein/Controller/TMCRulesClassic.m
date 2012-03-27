//
//  TMCRulesClassic.m
//  Dachstein
//
//  Created by Josef Deinhofer on 2/17/12.
//  Copyright (c) 2012 TheMountainCalls. All rights reserved.
//

#import "TMCRulesClassic.h"

#define MAX_LEVEL 8

#define TIMER_DURATION_MAX 45.0f
#define TIMER_DURATION_MIN 15.0f

#define TIMER_SPEEDUP_FACTOR_MAXLEVEL 0.99f
#define TIMER_INCREASE 0.2f

#define PAIRS_PER_LEVEL_1 10
#define PAIRS_PER_LEVEL_INCREASE 5


@implementation TMCRulesClassic

- (id<TMCRules>) initWithController: (id <TMCRulesControllerDelegate>) controller
{
    self = [super init];
    if (self) {
        _controller = controller;

        [_controller.view showHud:[_controller.view hudClassic]];
    }
    
    return self;
}

- (void) prepareGame
{
    _lastTile = nil;

    _score = 0;
    _scoreGainBase = 0;
    _scoreGainBonus = 0;
    _scoreGainTotal = 0;
    _bonusLevel = 0;
    
    _pairs_per_level = PAIRS_PER_LEVEL_1;
    _pairs_remaining = _pairs_per_level;

    TMCHudClassic *hud = _controller.view.hudClassic;
    [hud updateScoreTo:0 highScore:_highScore gain:0 bonus:0];
    [hud updatePairCounter:0 of:PAIRS_PER_LEVEL_1];
    [[hud timerProgress] setProgress:0];
}

- (void) startGame
{
    _level = 0;
    _timer_duration = TIMER_DURATION_MAX;
    _timer_progress = 0;
}

- (void) update: (ccTime) delta
{
    _timer_progress += delta;
    if (_timer_progress > _timer_duration) {
        // GAME OVER!
        [_controller endGame];
        _timer_progress = _timer_duration;
    }
    float progress = 1.0f - _timer_progress / _timer_duration;
    [_controller.view.hudClassic.timerProgress setProgress:progress];
}

- (void) selectedTile: (TMCTile*) tile
{
    if (_lastTile == tile) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"select_3.wav"];
    }
    else if (_lastTile == nil) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"select_1.wav"];
    }
    else if (_lastTile.color == tile.color || _lastTile.value == tile.value) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"select_2.wav"];
    }
    else {
        [[SimpleAudioEngine sharedEngine] playEffect:@"select_1.wav"];
    }
}

- (void) pickedTile: (TMCTile*) tile
{
    if (_level < MAX_LEVEL) {
        _pairs_remaining--;
        if (_pairs_remaining == 0) {
            _pairs_per_level += PAIRS_PER_LEVEL_INCREASE;
            _pairs_remaining = _pairs_per_level;

            _level++;

            _timer_progress = 0;
            
            float factor = (float)(MAX_LEVEL - _level) / (float)MAX_LEVEL;
            factor = (factor + factor * factor) / 2;
            _timer_duration = TIMER_DURATION_MIN + factor * (TIMER_DURATION_MAX - TIMER_DURATION_MIN);

            [_controller.view setLevel:_level];
        }
    } else {
         _timer_duration *= TIMER_SPEEDUP_FACTOR_MAXLEVEL;
    }
    float levelProgress = 1.0f - (float) _pairs_remaining / (float) _pairs_per_level;
    [_controller.view.hudClassic.levelProgress setProgress:levelProgress];

    [_controller.view.hudClassic updatePairCounter:_pairs_per_level - _pairs_remaining of:_pairs_per_level];
    
    // very first tile
    if (_lastTile == nil) {
        _scoreGainBase = SCORE_BASE;
        _scoreGainBonus = 0;
        CCLOG(@"FIRST TILE! (%i %i)", tile.color, tile.value);

        [[SimpleAudioEngine sharedEngine] playEffect:@"success_1.wav"];
    }
    // a tile matching in at least one aspect
    else if (_lastTile.value == tile.value || _lastTile.color == tile.color) {

        if (_lastTile == tile) {
            _scoreGainBase += SCORE_BASE / 2;
            _bonusLevel += 2;
            _scoreGainBonus = _scoreGainBase;
            CCLOG(@"SAME TILE! (%i %i)", tile.color, tile.value);

            [[SimpleAudioEngine sharedEngine] playEffect:@"success_3.wav"];

        } else {
            _scoreGainBase += SCORE_BASE / 10;
            _bonusLevel += 1;
            _scoreGainBonus = _scoreGainBase / 2;
            CCLOG(@"FITTING TILE! (%i %i)", tile.color, tile.value);

            [[SimpleAudioEngine sharedEngine] playEffect:@"success_2.wav"];
        }
    }
    // a totally unrelated tile
    else {
        _scoreGainBonus = 0;
        _bonusLevel = 0;
        CCLOG(@"ANY TILE! (%i %i)", tile.color, tile.value);

        [[SimpleAudioEngine sharedEngine] playEffect:@"success_1.wav"];
    }

    _scoreGainTotal = _scoreGainBase + _scoreGainBonus;

    _score += _scoreGainTotal;
    _highScore = MAX(_score, _highScore);

    CCLOG(@"SCORE: %i  %i %i %i", _score, _scoreGainBase, _scoreGainBonus, _bonusLevel);

    _lastTile = tile;

    [_controller.view.hudClassic updateScoreTo:_score highScore:_highScore gain:_scoreGainBase bonus:_scoreGainBonus];
    
    //_timer_progress = MAX(0, _timer_progress - _timer_duration * TIMER_INCREASE);
    _timer_progress = _timer_progress * (1.0f - TIMER_INCREASE);
}


@end
