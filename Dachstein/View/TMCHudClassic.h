//
//  Created by jdeinhofer on 3/12/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class TMCLabel;
@class TMCTimer;
@class TMCTile;

@interface TMCHudClassic : CCNode
{
    TMCLabel *_scoreLabel;
    TMCLabel *_highscoreLabel;
    TMCLabel *_messageLabel;

    TMCLabel *_pairCounterLabel;
    TMCLabel *_levelLabel;

    CCSprite *_lastTile;
    TMCLabel *_chainLength;

    TMCTimer *_timer;
    BOOL _isLowRes;
}

- (id)initWithScreenSize:(CGSize)screenSize lowRes:(BOOL)lowRes;

- (void) setupLevelInfo:(CGSize)screenSize;

- (void)setupChainInfo:(CGSize)screenSize;

- (void) updatePairCounter: (int)pairs of: (int)total;
- (void) updateLevelLabel:(int)level;

- (void)updateScoreTo:(int)score highScore:(int)highScore;

- (void)updateScoreMessage:(NSString *)text;


- (void)updateChainInfo:(TMCTile *)lastTile chainLength:(int)chainLength;

- (void) setupProgressBars: (CGSize) screenSize;
- (void) setupScoreLabel: (CGSize) screenSize;

@property (readonly, assign) TMCTimer *timerProgress;

@end