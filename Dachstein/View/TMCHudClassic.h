//
//  Created by jdeinhofer on 3/12/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

#import "TMCTimer.h"
#import "TMCNumberTicker.h"
#import "TMCProgressBar.h"

@interface TMCHudClassic : CCNode
{
//    TMCTimer* _timer;
    CCLabelTTF* _TMPscoreLabel;
    CCLabelTTF* _TMPhighScoreLabel;
    CCLabelTTF* _TMPscoreGainLabel;
    CCLabelTTF* _TMPpairCounterLabel;
    TMCNumberTicker* _scoreTicker;
    TMCProgressBar* _timerProgress;
    TMCProgressBar* _levelProgress;
}

- (id) initWithScreenSize: (CGSize) screenSize;

- (void) setupPairCounterLabel:(CGSize)screenSize;
- (void) updatePairCounter: (int)pairs of: (int)total;
- (void) updateScoreTo:(int)score highScore:(int)highScore gain:(int)gain bonus:(int)bonus;
- (void) setupProgressBars: (CGSize) screenSize;
- (void) setupScoreLabel: (CGSize) screenSize;

//@property (readonly, assign) TMCTimer *timer;

@property (readonly, assign) TMCProgressBar *timerProgress;
@property (readonly, assign) TMCProgressBar *levelProgress;

@end