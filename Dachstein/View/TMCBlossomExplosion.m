//
//  Created by jdeinhofer on 4/3/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TMCBlossomExplosion.h"
#import "TMCColumnView.h"
#import "TMCGameView.h"


@implementation TMCBlossomExplosion {
    NSArray *_frameNames;
}

float randomizeFloat() {
    return ((float)random() / RAND_MAX);
}

CGPoint randomizePoint() {
    float x = randomizeFloat() - 0.5f;
    float y = randomizeFloat() - 0.5f;
    return ccp(x, y);
}

float randomizeInRange(float min, float max) {
    float range = max - min;
    return min + range * randomizeFloat();
}


- (id)initWithTile:(TMCTile *)tile {
    self = [super init];
    if (self) {
        switch (tile.color) {
            case RED:
                _frameNames = [[NSArray alloc] initWithObjects:@"Blossom_Red_1.png", @"Blossom_Red_2.png", @"Blossom_Red_3.png", nil];
                break;
            case GREEN:
                _frameNames = [[NSArray alloc] initWithObjects:@"Blossom_Green_1.png", @"Blossom_Green_2.png", @"Blossom_Green_3.png", nil];
                break;
            case BLUE:
                _frameNames = [[NSArray alloc] initWithObjects:@"Blossom_Blue_1.png", @"Blossom_Blue_2.png", @"Blossom_Blue_3.png", nil];
                break;
        }

        if (![TMCGameView isLowRes]) {
            self.scale = 0.5;
        }
    }

    return self;
}

#define DURATION 1.0f
#define DURATION_EXPLO_MIN 0.15f
#define DURATION_EXPLO_MAX 0.22f

- (void)createBlossom {
    NSString *frameName = [_frameNames objectAtIndex:random() % 3];

    CCSprite *blossomSprite = [CCSprite spriteWithSpriteFrameName:frameName];
    blossomSprite.rotation = randomizeFloat() * 360;
    blossomSprite.scale = 4.0f;

    CGPoint explo = randomizePoint();
    explo = ccpNormalize(explo);
    explo = ccpMult(explo, randomizeInRange(160, 400));
    explo.x *= 1.5f;
    explo = ccpAdd(explo, ccp(0, 30));
    float durationExplo = randomizeInRange(DURATION_EXPLO_MIN, DURATION_EXPLO_MAX);
    id moveExplo = [CCMoveTo actionWithDuration:durationExplo position:explo];

    ccBezierConfig flyOut;
    flyOut.controlPoint_1 = explo;
    flyOut.controlPoint_2 = ccpAdd(explo, ccp(0, 30));
    flyOut.endPosition = ccpAdd(flyOut.controlPoint_2, ccp(150 * DURATION, 30 * DURATION));
    id moveFlyOut = [CCBezierBy actionWithDuration:DURATION - durationExplo bezier:flyOut];

    blossomSprite.position = ccpMult(explo, 0.1f);

    id explosionSequence = [CCSequence actions:moveExplo, moveFlyOut, nil];
    [blossomSprite runAction:explosionSequence];

    float rotationAngle = randomizeInRange(-240, 240);
    id rotation = [CCRotateBy actionWithDuration:DURATION angle:rotationAngle];
    id rotationEase = [CCEaseSineOut actionWithAction:rotation];
    [blossomSprite runAction:rotationEase];

//    id fadeOut = [CCEaseExponentialIn actionWithAction:[CCFadeOut actionWithDuration:DURATION]];
    id fadeDelay = [CCDelayTime actionWithDuration:DURATION * 0.2f];
    id fadeOut = [CCFadeOut actionWithDuration:DURATION * 0.8f];
    id fadeSequence = [CCSequence actions:fadeDelay, fadeOut, nil];
    [blossomSprite runAction:fadeSequence];

    [self addChild:blossomSprite];
}

- (void) start
{
    for (int i = 0; i < 20; i++) {
        [self createBlossom];
    }

    id delay = [CCDelayTime actionWithDuration:DURATION];
    id remove = [CCCallFuncN actionWithTarget:self selector:@selector(remove)];
    id sequence = [CCSequence actions:delay, remove, nil];

    [self runAction:sequence];
}

- (void)remove
{
    [self removeFromParentAndCleanup:YES];
}


@end