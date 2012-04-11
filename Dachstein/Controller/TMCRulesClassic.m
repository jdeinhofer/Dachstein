//
//  TMCRulesClassic.m
//  Dachstein
//
//  Created by Josef Deinhofer on 2/17/12.
//  Copyright (c) 2012 TheMountainCalls. All rights reserved.
//

#import "TMCRulesClassic.h"
#import "SimpleAudioEngine.h"


#define MAX_LEVEL 8

#define TIMER_DURATION_MAX 45.0f
#define TIMER_DURATION_MIN 25.0f

#define TIMER_SPEEDUP_FACTOR_MAXLEVEL 0.995f

#define TIMER_INCREASE 0.05f
#define TIMER_INCREASE_DOMINO 0.075f
#define TIMER_INCREASE_PERFECT 0.125f

#define PAIRS_PER_LEVEL_1 10
#define PAIRS_PER_LEVEL_INCREASE 5

#define SCORE_BASE 100
#define SCORE_BONUS_DOMINO 25
#define SCORE_BONUS_PERFECT 50

#define SELECT_SOUNDS_NUM 7

#define ALERT_DURATION 7.0f

@interface TMCRulesClassic ()
- (void)playSound:(NSString *)stringFormat indexUp:(BOOL)indexUp;
- (void)scoreDominoChain:(TMCTile *)tile;
- (void)scorePerfectChain:(TMCTile *)tile;
- (void)scoreFirstTile:(TMCTile *)tile;
- (void)levelUp;
@end

@implementation TMCRulesClassic {
    id<TMCRulesControllerDelegate> _controller;

    TMCHudClassic *_hud;

    int _level;
    float _timer_duration;
    float _timer_progress;

    int _pairs_per_level;
    int _pairs_remaining;

    TMCTile* _lastTile;

    int _score;
    int _scoreGain;
    int _highScore;

    int _soundIndex;

    BOOL _alertActive;
    ALuint _alertId;
    ccTime _alertDuration;
}

- (id<TMCRules>) initWithController: (id <TMCRulesControllerDelegate>) controller
{
    self = [super init];
    if (self) {
        _controller = controller;

        [_controller.view showHud:[_controller.view hudClassic]];
        _hud = _controller.view.hudClassic;
    }
    
    return self;
}

- (void) prepareGame
{
    _lastTile = nil;

    _score = 0;
    _scoreGain = SCORE_BASE;

    _pairs_per_level = PAIRS_PER_LEVEL_1;
    _pairs_remaining = _pairs_per_level;

    _alertActive = FALSE;

    [_hud updateScoreTo:0 highScore:_highScore];
    [_hud updatePairCounter:0 of:PAIRS_PER_LEVEL_1];
    [_hud updateLevelLabel:1];
    [_hud.timerProgress setProgressImmediately:1];
    [_hud updateChainInfo:nil];
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

        [_controller endGame];

        if (_score >= _highScore) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"gameover_high.mp3"];
        } else {
            [[SimpleAudioEngine sharedEngine] playEffect:@"gameover_low.mp3"];
        }
    }

    float progress = 1.0f - _timer_progress / _timer_duration;
    [_controller.view.hudClassic.timerProgress setProgress:progress];

    if (!_alertActive && (_timer_duration - _timer_progress) < ALERT_DURATION) {
        _alertActive = TRUE;
        _alertDuration = 0;
        _alertId = [[SimpleAudioEngine sharedEngine] playEffect:@"alert.mp3"];
    }
    if (_alertActive && (_timer_duration - _timer_progress) >= ALERT_DURATION) {
        [[SimpleAudioEngine sharedEngine] stopEffect:_alertId];
        _alertActive = FALSE;
    }

    if (_alertActive) {
        if (_alertDuration < ALERT_DURATION) {
            _alertDuration += delta;
        } else {
            _alertActive = false;
        }
    }
}

- (void) selectedTile: (TMCTile*) tile
{
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
    CCLOG(@"FITTING TILE! (%i %i)", tile.color, tile.value);
    _scoreGain += SCORE_BONUS_DOMINO;
    _timer_progress = MAX(0, _timer_progress  - TIMER_INCREASE_DOMINO * _timer_duration);
    [_controller.view.hudClassic updateScoreMessage:[NSString stringWithFormat:@"DOMINO CHAIN! %i", _scoreGain]];
    [self playSound:@"success_%i.wav" indexUp:TRUE];
}

- (void)scorePerfectChain:(TMCTile *)tile {
    CCLOG(@"SAME TILE! (%i %i)", tile.color, tile.value);
    _scoreGain += SCORE_BONUS_PERFECT;
    _timer_progress = MAX(0, _timer_progress  - TIMER_INCREASE_PERFECT * _timer_duration);
    [_controller.view.hudClassic updateScoreMessage:[NSString stringWithFormat:@"PERFECT CHAIN! %i", _scoreGain]];
    [self playSound:@"success_%i.wav" indexUp:TRUE];
}

- (void)scoreFirstTile:(TMCTile *)tile {
    CCLOG(@"FIRST TILE! (%i %i)", tile.color, tile.value);
    [_controller.view.hudClassic updateScoreMessage:[NSString stringWithFormat:@"%i", _scoreGain]];
    [self playSound:@"success_%i.wav" indexUp:FALSE];
}

- (void)scoreAnyTile:(TMCTile *)tile {
    CCLOG(@"ANY TILE! (%i %i)", tile.color, tile.value);
    _timer_progress = MAX(0, _timer_progress  - TIMER_INCREASE * _timer_duration);
    [_controller.view.hudClassic updateScoreMessage:[NSString stringWithFormat:@"%i", _scoreGain]];
    _soundIndex = 0;
    [self playSound:@"success_%i.wav" indexUp:FALSE];
}

- (void)levelUp {
    _pairs_per_level += PAIRS_PER_LEVEL_INCREASE;
    _pairs_remaining = _pairs_per_level;

    if (_level < MAX_LEVEL) {
        _level++;

        [_controller.view setLevel:_level];
        [_hud updateLevelLabel:_level + 1];

        float factor = (float)(MAX_LEVEL - _level) / (float)MAX_LEVEL;
        factor = (factor + factor * factor) / 2;
        _timer_duration = TIMER_DURATION_MIN + factor * (TIMER_DURATION_MAX - TIMER_DURATION_MIN);
    }
    else {
         _timer_duration *= TIMER_SPEEDUP_FACTOR_MAXLEVEL;
    }

    _timer_progress = 0;

}

- (void) pickedTile: (TMCTile*) tile
{
    _pairs_remaining--;
    if (_pairs_remaining == 0) {
        [self levelUp];
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

    _score += _scoreGain;
    _highScore = MAX(_score, _highScore);

    _lastTile = tile;

    CCLOG(@"SCORE: %i (+%i)", _score, _scoreGain);

    [_hud updateChainInfo:_lastTile];
    [_hud updateScoreTo:_score highScore:_highScore];
    [_hud updatePairCounter:_pairs_per_level - _pairs_remaining of:_pairs_per_level];
}

@end
