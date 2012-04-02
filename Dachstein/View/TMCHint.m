//
//  Created by jdeinhofer on 3/12/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TMCHint.h"

#define HINT_DURATION_SHORT 0.3f
#define HINT_DURATION_LONG 0.6f
#define HINT_FADEOUT_MULTIPLIER 1.5f
#define HINT_DELAY 0.15f


@interface TMCHint ()
- (void)removeFromParent;
@end

@implementation TMCHint {
    CCSprite *_spriteA;
    CCSprite *_spriteB;
}

- (id) init
{
    self = [super init];
    if (self) {
        _spriteA = [[[CCSprite alloc] initWithSpriteFrameName:@"Hint.png"] autorelease];
        _spriteB = [[[CCSprite alloc] initWithSpriteFrameName:@"Hint.png"] autorelease];
        [_spriteB setFlipX:TRUE];

        [self addChild:_spriteA];
        [self addChild:_spriteB];
    }

    return self;
}

- (void) restartAnimation
{
    [_spriteA setOpacity:0];
    [_spriteB setOpacity:0];

    id blendInA = [CCEaseSineOut actionWithAction:[CCFadeIn actionWithDuration:HINT_DURATION_SHORT]];
    id blendOutA = [CCEaseSineInOut actionWithAction:[CCFadeOut actionWithDuration:HINT_DURATION_LONG]];
    id sequenceA = [CCSequence actions:blendInA, blendOutA, nil];
    [_spriteA runAction:sequenceA];

    id delay = [CCDelayTime actionWithDuration:HINT_DELAY];
    id blendInB = [CCEaseSineOut actionWithAction:[CCFadeIn actionWithDuration:HINT_DURATION_SHORT * HINT_FADEOUT_MULTIPLIER]];
    id blendOutB = [CCEaseSineInOut actionWithAction:[CCFadeOut actionWithDuration:HINT_DURATION_LONG * HINT_FADEOUT_MULTIPLIER]];
    id removeFromParent = [CCCallFunc actionWithTarget:self selector:@selector(removeFromParent)];
    id sequenceB = [CCSequence actions:delay, blendInB, blendOutB, removeFromParent, nil];
    [_spriteB runAction:sequenceB];
}

- (void) removeFromParent
{
    [self removeFromParentAndCleanup:YES];
}

- (void) dealloc
{
    [_spriteA release];
    [_spriteB release];

    [super dealloc];
}

@end