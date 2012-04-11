//
//  Created by jdeinhofer on 3/12/12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "TMCTimer.h"
#import "TMCTile.h"

@interface TMCHudClassic : CCNode

- (id)initWithScreenSize:(CGSize)screenSize lowRes:(BOOL)lowRes;
- (void) updatePairCounter: (int)pairs of: (int)total;
- (void) updateLevelLabel:(int)level;
- (void)updateScoreTo:(int)score highScore:(int)highScore;
- (void)updateScoreMessage:(NSString *)text;
- (void)updateChainInfo:(TMCTile *)lastTile;

@property (readonly, assign) TMCTimer *timerProgress;

@end