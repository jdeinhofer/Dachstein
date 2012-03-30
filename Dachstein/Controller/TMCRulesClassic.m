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

#define TIMER_SPEEDUP_FACTOR_MAXLEVEL 0.995f
#define TIMER_INCREASE 0.1f
#define TIMER_INCREASE_CHAIN 0.075f

#define PAIRS_PER_LEVEL_1 15
#define PAIRS_PER_LEVEL_INCREASE 5

#define CHAIN_STATE_BUILDUP 0
#define CHAIN_STATE_COUNTDOWN 1

#define CHAIN_COUNTDOWN_TIME_BASE 0.025f
#define CHAIN_COUNTDOWN_TIME_SPEEDUP 0.95f

#define SCORE_BASE 100
#define SCORE_BONUS 25

#define SELECT_SOUNDS_NUM 7

@interface TMCRulesClassic ()
- (void)playSound:(NSString *)stringFormat indexUp:(BOOL)indexUp;

- (void)scoreDominoChain:(TMCTile *)tile;
- (void)scorePerfectChain:(TMCTile *)tile;
- (void)scoreFirstTile:(TMCTile *)tile;
- (void)levelUp;
- (void)cashInChain;
- (void)cashInChainImmediately;
- (void)startChainCountdown;
@end

@implementation TMCRulesClassic {
    int _chainState;
    int _chainLength;
    int _chainBonus;
    float _chainCountdownTime;
    float _chainCountdownTimeLeft;

    int _soundIndex;
}

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
    _bonusLevel = 0;
    
    _pairs_per_level = PAIRS_PER_LEVEL_1;
    _pairs_remaining = _pairs_per_level;

    _chainState = CHAIN_STATE_BUILDUP;

    TMCHudClassic *hud = _controller.view.hudClassic;
    [hud updateScoreTo:0 highScore:_highScore];
    [hud updatePairCounter:0 of:PAIRS_PER_LEVEL_1];
    [hud updateLevelLabel:1];
    [hud.timerProgress setProgress:1];
    [hud updateChainInfo:nil chainLength:0];
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
        _timer_progress = _timer_duration;

//        if (_bonusLevel > 0) {
//            [self startChainCountdown];
//            [self cashInChain];
//        }
//        else {
//            [self cashInChainImmediately];
//            [_controller endGame];
//        }

        [self cashInChainImmediately];
        [_controller endGame];
    }

    float progress = 1.0f - _timer_progress / _timer_duration;
    [_controller.view.hudClassic.timerProgress setProgress:progress];

    if (_chainState == CHAIN_STATE_COUNTDOWN) {
        _chainCountdownTimeLeft -= delta;
        if (_chainCountdownTimeLeft <= 0) {
            _chainCountdownTime *= CHAIN_COUNTDOWN_TIME_SPEEDUP;
            _chainCountdownTimeLeft = _chainCountdownTime;

            [self cashInChain];
        }
    }
}

- (void) selectedTile: (TMCTile*) tile
{
//    if (_lastTile == tile) {
//        [[SimpleAudioEngine sharedEngine] playEffect:@"select_3.wav"];
//    }
//    else if (_lastTile == nil) {
//        [[SimpleAudioEngine sharedEngine] playEffect:@"select_1.wav"];
//    }
//    else if (_lastTile.color == tile.color || _lastTile.value == tile.value) {
//        [[SimpleAudioEngine sharedEngine] playEffect:@"select_2.wav"];
//    }
//    else {
//        [[SimpleAudioEngine sharedEngine] playEffect:@"select_1.wav"];
//    }

    [self playSound:@"select_%i.wav" indexUp:FALSE];
}

- (void) playSound: (NSString *) stringFormat indexUp: (BOOL) indexUp
{
    if (indexUp) {
        _soundIndex = (_soundIndex + 1) % SELECT_SOUNDS_NUM;
    }

    NSString *soundName = [NSString stringWithFormat:stringFormat, _soundIndex + 1];
    [[SimpleAudioEngine sharedEngine] playEffect:soundName];
}

- (void)scoreDominoChain:(TMCTile *)tile {
    _bonusLevel++;
    _scoreGainBonus = 3 * _scoreGainBase / 5;
    CCLOG(@"FITTING TILE! (%i %i)", tile.color, tile.value);

    [_controller.view.hudClassic updateScoreMessage:[NSString stringWithFormat:@"DOMINO CHAIN! %i", _scoreGainBase + _scoreGainBonus]];

    //[[SimpleAudioEngine sharedEngine] playEffect:@"success_2.wav"];
    [self playSound:@"success_%i.wav" indexUp:TRUE];
}

- (void)scorePerfectChain:(TMCTile *)tile {
    _bonusLevel++;
    _scoreGainBonus = _scoreGainBase;
    CCLOG(@"SAME TILE! (%i %i)", tile.color, tile.value);

    [_controller.view.hudClassic updateScoreMessage:[NSString stringWithFormat:@"PERFECT CHAIN! %i", _scoreGainBase + _scoreGainBonus]];

    //[[SimpleAudioEngine sharedEngine] playEffect:@"success_3.wav"];
    [self playSound:@"success_%i.wav" indexUp:TRUE];
}

- (void)scoreFirstTile:(TMCTile *)tile {
    _scoreGainBase = SCORE_BASE;
    _scoreGainBonus = 0;
    CCLOG(@"FIRST TILE! (%i %i)", tile.color, tile.value);

    [_controller.view.hudClassic updateScoreMessage:[NSString stringWithFormat:@"%i", _scoreGainBase + _scoreGainBonus]];

    //[[SimpleAudioEngine sharedEngine] playEffect:@"success_1.wav"];
    [self playSound:@"success_%i.wav" indexUp:FALSE];
}

- (void)scoreAnyTile:(TMCTile *)tile {
    if (_bonusLevel > 0) {
        [self startChainCountdown];
        [[SimpleAudioEngine sharedEngine] playEffect:@"chain_up.wav"];
        _soundIndex = 0;
    } else  {
        [_controller.view.hudClassic updateScoreMessage:[NSString stringWithFormat:@"%i", _scoreGainBase]];
        [self playSound:@"success_%i.wav" indexUp:FALSE];
    }

    _scoreGainBonus = 0;
    _bonusLevel = 0;
    CCLOG(@"ANY TILE! (%i %i)", tile.color, tile.value);

    //[[SimpleAudioEngine sharedEngine] playEffect:@"success_1.wav"];
}

- (void)levelUp {
    _pairs_per_level += PAIRS_PER_LEVEL_INCREASE;
    _pairs_remaining = _pairs_per_level;

    _level++;

    float factor = (float)(MAX_LEVEL - _level) / (float)MAX_LEVEL;
    factor = (factor + factor * factor) / 2;
    _timer_duration = TIMER_DURATION_MIN + factor * (TIMER_DURATION_MAX - TIMER_DURATION_MIN);

    [_controller.view setLevel:_level];
    [_controller.view.hudClassic updateLevelLabel:_level + 1];
}

- (void) pickedTile: (TMCTile*) tile
{
    if (_level < MAX_LEVEL) {
        _pairs_remaining--;
        if (_pairs_remaining == 0) {
            [self levelUp];
        }
    } else {
         _timer_duration *= TIMER_SPEEDUP_FACTOR_MAXLEVEL;
    }

    if (_chainState == CHAIN_STATE_COUNTDOWN) {
        [self cashInChainImmediately];
    }

    if (_lastTile == nil) {
        [self scoreFirstTile:tile];
    }
    else if (_lastTile == tile) {
        [self scorePerfectChain:tile];
    }
    else if (_lastTile.value == tile.value || _lastTile.color == tile.color) {
        [self scoreDominoChain:tile];
    }
    else {
        [self scoreAnyTile:tile];
    }

    _score += _scoreGainBase + _scoreGainBonus;
    _highScore = MAX(_score, _highScore);

    _lastTile = tile;

    CCLOG(@"SCORE: %i  %i %i %i", _score, _scoreGainBase, _scoreGainBonus, _bonusLevel);

    [_controller.view.hudClassic updateChainInfo:_lastTile chainLength:_bonusLevel];
    [_controller.view.hudClassic updateScoreTo:_score highScore:_highScore];
    [_controller.view.hudClassic updatePairCounter:_pairs_per_level - _pairs_remaining of:_pairs_per_level];

    _timer_progress = _timer_progress * (1.0f - TIMER_INCREASE);
}

- (void) cashInChain
{
    _timer_progress = _timer_progress * (1.0f - TIMER_INCREASE_CHAIN);
    _chainLength--;

    _scoreGainBase += SCORE_BONUS;
    _score += _scoreGainBase;
    _highScore = MAX(_score, _highScore);

    if (_chainLength == 0) {
        _chainState = CHAIN_STATE_BUILDUP;
    }

    [_controller.view.hudClassic updateChainInfo:_lastTile chainLength:_chainLength];
    [_controller.view.hudClassic updateScoreTo:_score highScore:_highScore];
    [_controller.view.hudClassic updateScoreMessage:[NSString stringWithFormat:@"CHAIN UP! %i", _scoreGainBase]];
}

- (void) cashInChainImmediately
{
    while (_chainLength > 0) {
        [self cashInChain];
    }
}

- (void) startChainCountdown
{
    _chainLength = _bonusLevel;
    _bonusLevel = 0;

    _chainBonus = _scoreGainBase;
    _chainCountdownTime = CHAIN_COUNTDOWN_TIME_BASE;
    _chainCountdownTimeLeft = _chainCountdownTime;
    _chainState = CHAIN_STATE_COUNTDOWN;
}

@end
