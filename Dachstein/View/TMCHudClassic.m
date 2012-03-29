//
//  Created by jdeinhofer on 3/12/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TMCHudClassic.h"
#import "TMCTimer.h"
#import "TMCLabel.h"


@implementation TMCHudClassic

@synthesize timerProgress=_timer;


- (id)initWithScreenSize:(CGSize)screenSize lowRes:(BOOL)lowRes {
    self = [super init];
    if (self) {
        _isLowRes = lowRes;
        [self setupProgressBars:screenSize];
        [self setupScoreLabel:screenSize];
        [self setupLevelInfo:screenSize];
    }

    return self;
}

- (void) setupProgressBars: (CGSize) screenSize
{
    _timer = [[TMCTimer alloc] init];
    [_timer setPosition:ccp(0, screenSize.height / 2 - 12)];
    [self addChild:_timer];

    // TMP!
    if (_isLowRes) [_timer setScale:0.5f];
}

- (void) setupScoreLabel: (CGSize) screenSize
{
    _scoreLabel = [[TMCLabel alloc] initWithFontsize:18];
    _scoreLabel.position = ccp(0, screenSize.height / 2 - 25);
    [self addChild:_scoreLabel];

    _highscoreLabel = [[TMCLabel alloc] initWithFontsize:14];
    _highscoreLabel.position = ccp(screenSize.width / - 2.5f, screenSize.height / 2 - 16);
    [self addChild:_highscoreLabel];

    _scoreGainLabel = [[TMCLabel alloc] initWithFontsize:14];
    _scoreGainLabel.position = ccp(screenSize.width / 2.5f, screenSize.height / 2 - 16);
    [self addChild:_scoreGainLabel];
}

- (void) setupLevelInfo: (CGSize)screenSize
{
    _pairCounterLabel = [[TMCLabel alloc] initWithFontsize:14];
    _pairCounterLabel.position = ccp(screenSize.width / -2.4, screenSize.height / -2 + 12);
    [self addChild:_pairCounterLabel];

    _levelLabel = [[TMCLabel alloc] initWithFontsize:14];
    _levelLabel.position  = ccp(screenSize.width / 2.4, screenSize.height / -2 + 12);
    [self addChild:_levelLabel];
}

- (void)updatePairCounter:(int)pairs of:(int)total {
    NSString *pairsString = [NSString stringWithFormat:@"%i/%i", pairs, total];
    [_pairCounterLabel setString:pairsString];
}

- (void) updateLevelLabel: (int) level
{
    NSString *levelString = [NSString stringWithFormat:@"LEVEL %i", level];
    [_levelLabel setString:levelString];
}

- (void)updateScoreTo:(int)score highScore:(int)highScore gain:(int)gain bonus:(int)bonus {
    NSString* scoreString = [NSString stringWithFormat:@"%i", score];
    [_scoreLabel setString:scoreString];

    NSString* highScoreString = [NSString stringWithFormat:@"%i", highScore];
    [_highscoreLabel setString:highScoreString];

    NSString* scoreGainString;
    if (bonus > 0)
        scoreGainString = [NSString stringWithFormat:@"+ %i + %i", gain, bonus];
    else
        scoreGainString = [NSString stringWithFormat:@"+ %i", gain];

    [_scoreGainLabel setString:scoreGainString];

    if (gain + bonus == 0)
        [_scoreGainLabel setOpacity:0];
    else {
        [_scoreGainLabel setOpacity:255];

        id fadeOut = [CCFadeOut actionWithDuration:3.0f];
        id ease = [CCEaseSineInOut actionWithAction:fadeOut];
        [_scoreGainLabel stopAllActions];
        [_scoreGainLabel runAction:ease];
    }
}

- (void) dealloc
{
    [_levelLabel release];
    [_pairCounterLabel release];
    [_highscoreLabel release];
    [_scoreGainLabel release];
    [_scoreLabel release];

    [_timer release];

    [super dealloc];
}

@end