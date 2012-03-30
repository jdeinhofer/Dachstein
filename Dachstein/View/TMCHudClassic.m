//
//  Created by jdeinhofer on 3/12/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TMCHudClassic.h"
#import "TMCTimer.h"
#import "TMCLabel.h"
#import "TMCTile.h"
#import "TMCColumnView.h"


@implementation TMCHudClassic

@synthesize timerProgress=_timer;


- (id)initWithScreenSize:(CGSize)screenSize lowRes:(BOOL)lowRes {
    self = [super init];
    if (self) {
        _isLowRes = lowRes;
        [self setupProgressBars:screenSize];
        [self setupScoreLabel:screenSize];
        [self setupLevelInfo:screenSize];
        [self setupChainInfo:screenSize];
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
    _highscoreLabel.position = ccp(screenSize.width / 2.5f, screenSize.height / 2 - 16);
    [self addChild:_highscoreLabel];

    _messageLabel = [[TMCLabel alloc] initWithFontsize:24];
    _messageLabel.position = ccp(0, screenSize.height / 2 - 50);
    [self addChild:_messageLabel];
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

- (void) setupChainInfo: (CGSize)screenSize
{
    _lastTile = [[CCSprite alloc] initWithSpriteFrameName:@"Red_1.png"];

    CGSize tileSize = _lastTile.contentSize;

    if (_isLowRes) {
        _lastTile.scale = 0.5f;
        tileSize = CGSizeMake(tileSize.width * 0.5f, tileSize.height * 0.5f);
    }

    CGPoint position = ccp(screenSize.width / -2 + tileSize.width * 0.6f, screenSize.height / 2 - tileSize.height * 0.6f);

    _lastTile.position = position;
    [self addChild:_lastTile];
    _lastTile.visible = false;

    _chainLength = [[TMCLabel alloc] initWithFontsize:24];
    _chainLength.position = position;
    [self addChild:_chainLength];
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

- (void)updateScoreTo:(int)score highScore:(int)highScore {
    NSString* scoreString = [NSString stringWithFormat:@"%i", score];
    [_scoreLabel setString:scoreString];

    NSString* highScoreString = [NSString stringWithFormat:@"%i", highScore];
    [_highscoreLabel setString:highScoreString];
}

- (void) updateScoreMessage: (NSString *) text
{
    [_messageLabel setString:text];

    if (text == nil) {
        [_messageLabel setOpacity:0];
    }
    else {
        [_messageLabel setOpacity:255];

        id delay = [CCDelayTime actionWithDuration:0.5f];
        id fadeOut = [CCFadeOut actionWithDuration:0.3f];
        id ease = [CCEaseSineIn actionWithAction:fadeOut];
        id sequence = [CCSequence actions:delay, ease, nil];

        [_messageLabel stopAllActions];
        [_messageLabel runAction:sequence];
    }
}

- (void) updateChainInfo: (TMCTile *) lastTile chainLength: (int) chainLength
{
    if (lastTile == nil) {
        _lastTile.visible = false;
        _chainLength.visible = false;
    }
    else {
        _lastTile.visible = true;
        NSString *lastTileFrameName = [TMCColumnView spriteFrameNameForTile:lastTile];
        [_lastTile setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:lastTileFrameName]];

        if (chainLength > 0) {
            NSString *chainString = [NSString stringWithFormat:@"%i", chainLength];
            [_chainLength setString:chainString];
            _chainLength.visible = true;
        } else {
            _chainLength.visible = false;
        }

    }
}

- (void) dealloc
{
    [_levelLabel release];
    [_pairCounterLabel release];
    [_highscoreLabel release];
    [_messageLabel release];
    [_scoreLabel release];

    [_lastTile release];
    [_chainLength release];

    [_timer release];

    [super dealloc];
}

@end