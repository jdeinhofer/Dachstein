//
//  TMCRulesClassic.h
//  Dachstein
//
//  Created by Josef Deinhofer on 2/17/12.
//  Copyright (c) 2012 TheMountainCalls. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TMCGameController.h"
#import "TMCRules.h"

@interface TMCRulesClassic : NSObject <TMCRules>
{
    id<TMCRulesControllerDelegate> _controller;

    int _level;
    float _timer_duration;
    float _timer_progress;

    int _pairs_per_level;
    int _pairs_remaining;

    TMCTile* _lastTile;
    int _bonusLevel;

    int _score;
    int _scoreGainBase;
    int _scoreGainBonus;
    int _scoreGainTotal;

    int _highScore;
}

@end
