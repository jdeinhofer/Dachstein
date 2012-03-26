//
//  Created by jdeinhofer on 3/12/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TMCHudClassic.h"


@implementation TMCHudClassic

@synthesize timerProgress=_timerProgress;
@synthesize levelProgress=_levelProgress;

- (id) initWithScreenSize: (CGSize) screenSize
{
    self = [super init];
    if (self) {
        [self setupProgressBars:screenSize];
        [self setupScoreLabel:screenSize];
        [self setupPairCounterLabel:screenSize];

        // TMP!
        //_scoreTicker = [[TMCNumberTicker alloc] initWithFrameName:@"ScoreFont_L"];
        //[self addChild:_scoreTicker];


    }

    return self;
}


- (void) setupProgressBars: (CGSize) screenSize
{
//    _timer = [[TMCTimer alloc] init];
//    [_timer setPosition:ccp(0, screenSize.height / 2 - 7)];
//    [self addChild:_timer];
//
//    // TMP!
//    if ([TMCGameView isLowRes]) [_timer setScale:0.5f];



    CGSize levelProgressSize = CGSizeMake(screenSize.width, 8);
    _levelProgress = [[TMCProgressBar alloc] initWithSizeBG:levelProgressSize bgFrameName:@"LevelProgressBar_BG.png" sizeFG:levelProgressSize fgFrameName:@"LevelProgressBar_FG.png"];
    [_levelProgress setPosition:ccp(0, screenSize.height / 2 - 4)];
    [self addChild:_levelProgress];

    CGSize pgbSize = CGSizeMake(screenSize.width - 4, 6);
    _timerProgress = [[TMCProgressBar alloc] initWithSizeBG:pgbSize bgFrameName:@"TimerProgressBar_BG.png" sizeFG:pgbSize fgFrameName:@"TimerProgressBar_FG.png"];
    [_timerProgress setPosition:ccp(0, screenSize.height / 2 - 2)];
    [self addChild:_timerProgress];
}


- (void) setupScoreLabel: (CGSize) screenSize
{
    _TMPscoreLabel = [[CCLabelTTF labelWithString:@""
                         dimensions:CGSizeMake(320, 50) alignment:UITextAlignmentCenter
                         fontName:@"Arial" fontSize:32.0] retain];
    _TMPscoreLabel.position = ccp(0, screenSize.height / 2 - (_TMPscoreLabel.contentSize.height/2) - 7);
    _TMPscoreLabel.color = ccc3(20,20,20);
    [self addChild:_TMPscoreLabel];

    _TMPhighScoreLabel = [[CCLabelTTF labelWithString:@""
                         dimensions:CGSizeMake(320, 50) alignment:UITextAlignmentCenter
                         fontName:@"Arial" fontSize:24.0] retain];
    _TMPhighScoreLabel.position = ccp(screenSize.width / - 3.5f, screenSize.height / 2 - (_TMPhighScoreLabel.contentSize.height/2) - 7);
    _TMPhighScoreLabel.color = ccc3(20,20,20);
    [self addChild:_TMPhighScoreLabel];

    _TMPscoreGainLabel = [[CCLabelTTF labelWithString:@""
                             dimensions:CGSizeMake(320, 50) alignment:UITextAlignmentCenter
                             fontName:@"Arial" fontSize:24.0] retain];
    _TMPscoreGainLabel.position = ccp(screenSize.width / 3.5f, screenSize.height / 2 - (_TMPscoreGainLabel.contentSize.height/2) - 7);
    _TMPscoreGainLabel.color = ccc3(20,20,20);
    [self addChild:_TMPscoreGainLabel];
}

- (void) setupPairCounterLabel: (CGSize)screenSize
{
    _TMPpairCounterLabel = [[CCLabelTTF labelWithString:@""
                             dimensions:CGSizeMake(100, 24) alignment:UITextAlignmentLeft
                             fontName:@"Arial" fontSize:24.0] retain];
    _TMPpairCounterLabel.position = ccp(screenSize.width / -2 + 52, screenSize.height / -2 + (_TMPpairCounterLabel.contentSize.height/2) + 2);
    _TMPpairCounterLabel.color = ccc3(20,20,20);
    [self addChild:_TMPpairCounterLabel];
}

- (void)updatePairCounter:(int)pairs of:(int)total {
    NSString *pairsString = [NSString stringWithFormat:@"%i/%i", pairs, total];
    [_TMPpairCounterLabel setString:pairsString];
}


- (void)updateScoreTo:(int)score highScore:(int)highScore gain:(int)gain bonus:(int)bonus {
    NSString* scoreString = [NSString stringWithFormat:@"%i", score];
    [_TMPscoreLabel setString:scoreString];

    NSString* highScoreString = [NSString stringWithFormat:@"%i", highScore];
    [_TMPhighScoreLabel setString:highScoreString];

    NSString* scoreGainString;
    if (bonus > 0)
        scoreGainString = [NSString stringWithFormat:@"+ %i + %i", gain, bonus];
    else
        scoreGainString = [NSString stringWithFormat:@"+ %i", gain];
    [_TMPscoreGainLabel setString:scoreGainString];

    if (gain + bonus == 0)
        [_TMPscoreGainLabel setOpacity:0];
    else {
        [_TMPscoreGainLabel setOpacity:255];

        id fadeOut = [CCFadeOut actionWithDuration:3.0f];
        id ease = [CCEaseSineInOut actionWithAction:fadeOut];
        [_TMPscoreGainLabel stopAllActions];
        [_TMPscoreGainLabel runAction:ease];
    }

    // TMP!
    [_scoreTicker setValue:score];
}

- (void) dealloc
{
    [_TMPhighScoreLabel release];
    [_TMPscoreLabel release];
    [_TMPscoreGainLabel release];
    [_TMPpairCounterLabel release];

    [_timerProgress release];
    [_levelProgress release];

    [super dealloc];
}

@end