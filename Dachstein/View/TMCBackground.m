//
//  Created by jdeinhofer on 3/13/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TMCBackground.h"

#import "TMCFadeOutTiles.h"

@implementation TMCBackground {
    NSArray *_backgrounds;
    CCNode *_currentBackground;
    CCNode *_previousBackground;
    int _currentLevel;
}

- (id) init
{
    self = [super init];
    if (self) {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"texture_background_1.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"texture_background_2.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"texture_background_3.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"texture_background_4.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"texture_background_5.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"texture_background_6.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"texture_background_7.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"texture_background_8.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"texture_background_9.plist"];
        
        _backgrounds = [[NSArray alloc] initWithObjects:
            [CCSprite spriteWithSpriteFrameName:@"background_1.png"],
            [CCSprite spriteWithSpriteFrameName:@"background_2.png"],
            [CCSprite spriteWithSpriteFrameName:@"background_3.png"],
            [CCSprite spriteWithSpriteFrameName:@"background_4.png"],
            [CCSprite spriteWithSpriteFrameName:@"background_5.png"],
            [CCSprite spriteWithSpriteFrameName:@"background_6.png"],
            [CCSprite spriteWithSpriteFrameName:@"background_7.png"],
            [CCSprite spriteWithSpriteFrameName:@"background_8.png"],
            [CCSprite spriteWithSpriteFrameName:@"background_9.png"],
            nil
        ];

        _currentLevel = -1;

        [self setLevel:0];
    }

    return self;
}

- (void) setLevel: (int) level
{
    CCNode *nextBackground = [_backgrounds objectAtIndex:(NSUInteger)(level % [_backgrounds count])];
    
    if (nextBackground == _currentBackground)
        return;
    
    if (level < _currentLevel) {
        [self removeAllChildrenWithCleanup:YES];
        [self addChild:nextBackground];
    }
    else {
        int currentLayer = _currentBackground.zOrder;
        [self addChild:nextBackground z:currentLayer - 1];
        
        id transitionAction = [CCFadeOutBLTiles actionWithSize: ccg(12,9) duration:1.0f];
//        id transitionAction = [TMCFadeOutTiles actionWithSize: ccg(4,3) duration:5.0f];
        id stopGridAction = [CCStopGrid action];
        id finishAction = [CCCallFunc actionWithTarget:self selector:@selector(finishTransition)];
        id sequence = [CCSequence actions:transitionAction, stopGridAction, finishAction, nil];
        [_currentBackground runAction:sequence];

        _previousBackground = _currentBackground;
    }

    _currentLevel = level;
    _currentBackground = nextBackground;
}

- (void) finishTransition
{
    [_previousBackground removeFromParentAndCleanup:YES];
}

- (void) dealloc
{
    [_backgrounds release];

    [super dealloc];
}

@end