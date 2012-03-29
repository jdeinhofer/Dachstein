//
//  Created by jdeinhofer on 3/12/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class TMCLabel;
@class TMCTimer;

@interface TMCHudClassic : CCNode
{
    TMCLabel *_scoreLabel;
    TMCLabel *_highscoreLabel;
    TMCLabel *_scoreGainLabel;

    TMCLabel *_pairCounterLabel;
    TMCLabel *_levelLabel;

    TMCTimer *_timer;
    BOOL _isLowRes;
}

- (id)initWithScreenSize:(CGSize)screenSize lowRes:(BOOL)lowRes;

- (void) setupLevelInfo:(CGSize)screenSize;
- (void) updatePairCounter: (int)pairs of: (int)total;
- (void) updateLevelLabel:(int)level;
- (void) updateScoreTo:(int)score highScore:(int)highScore gain:(int)gain bonus:(int)bonus;
- (void) setupProgressBars: (CGSize) screenSize;
- (void) setupScoreLabel: (CGSize) screenSize;

@property (readonly, assign) TMCTimer *timerProgress;

@end