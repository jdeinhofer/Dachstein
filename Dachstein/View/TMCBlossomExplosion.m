//
//  Created by jdeinhofer on 4/3/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TMCBlossomExplosion.h"
#import "TMCColumnView.h"
#import "TMCGameView.h"
#import "CCActionInterval.h"
#import "TMCBlossom.h"


@implementation TMCBlossomExplosion {
    NSArray *_frameNames;
    BOOL _lowRes;
    TMCTile *_tile;
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

        _tile = tile;

//        self.scale = 2;
//        _lowRes = [TMCGameView isLowRes];
//        if (_lowRes)
//        {
//            self.scale *= 0.5;
//        }
    }

    return self;
}

#define DURATION 0.7f
#define DURATION_EXPLO_MIN 0.15f
#define DURATION_EXPLO_MAX 0.22f

- (void)createBlossom {
    NSString *frameName = [_frameNames objectAtIndex:random() % 3];

    CCSprite *blossomSprite = [CCSprite spriteWithSpriteFrameName:frameName];
    blossomSprite.rotation = randomizeFloat() * 360;
    blossomSprite.scale = 4.0f;//(_lowRes) ? 2.0f : 4.0f;

    CGPoint explo = randomizePoint();
    explo = ccpNormalize(explo);
    explo = ccpMult(explo, randomizeInRange(50, 90));
    explo.x *= 1.5f;
    explo = ccpAdd(explo, ccp(0, 30));
    float durationExplo = randomizeInRange(DURATION_EXPLO_MIN, DURATION_EXPLO_MAX);
    id moveExplo = [CCMoveTo actionWithDuration:durationExplo position:explo];

    ccBezierConfig flyOut;
    flyOut.controlPoint_1 = explo;
    flyOut.controlPoint_2 = ccpAdd(explo, ccp(0, 30));
    flyOut.endPosition = ccpAdd(flyOut.controlPoint_2, ccp(50 * (DURATION - durationExplo), 10 * (DURATION - durationExplo)));
    id moveFlyOut = [CCBezierBy actionWithDuration:DURATION - durationExplo bezier:flyOut];

    blossomSprite.position = ccpMult(explo, 0.1f);

    id explosionSequence = [CCSequence actions:moveExplo, moveFlyOut, nil];
    [blossomSprite runAction:explosionSequence];

    float rotationAngle = randomizeInRange(-240, 240);
    id rotation = [CCRotateBy actionWithDuration:DURATION angle:rotationAngle];
    id rotationEase = [CCEaseSineOut actionWithAction:rotation];
    [blossomSprite runAction:rotationEase];

//    id fadeOut = [CCEaseExponentialIn actionWithAction:[CCFadeOut actionWithDuration:DURATION]];
    id fadeDelay = [CCDelayTime actionWithDuration:DURATION * 0.6f];
    id fadeOut = [CCFadeOut actionWithDuration:DURATION * 0.4f];
    id fadeSequence = [CCSequence actions:fadeDelay, fadeOut, nil];
    [blossomSprite runAction:fadeSequence];

    [self addChild:blossomSprite];
}

- (void) spawnBlossom
{
    NSString *frameName = [_frameNames objectAtIndex:random() % 3];
    CCSprite *blossomSprite = [TMCBlossom spriteWithSpriteFrameName:frameName];

    [self addChild:blossomSprite];

    blossomSprite.rotation = randomizeFloat() * 360;
    blossomSprite.scale = 2.0f;

    CGPoint position = ccpNormalize(randomizePoint());
    float randomScale = randomizeFloat();
    position.x *= 100 * randomScale;
    position.y *= 50 * randomScale;

    blossomSprite.position = position;

    [blossomSprite scheduleUpdate];
}

- (void) start
{
    for (int i = 0; i < 20; i++) {
        [self spawnBlossom];
    }

//    for (int i = 0; i < 30; i++) {
//        [self createBlossom];
//    }

//    CCSprite *tile = [CCSprite spriteWithSpriteFrameName:[TMCColumnView spriteFrameNameForTile:_tile]];
//    CCSprite *light = [CCSprite spriteWithSpriteFrameName:[TMCColumnView spriteFrameNameForTile:_tile]];
//    [light setColor: ccc3(255,0,255)];
//    //[self addChild:tile];
//    [self addChild:light];
//
//    id tileFade = [CCFadeOut actionWithDuration:0.2f];
//    [tile runAction:tileFade];
//
//    id lightFadeIn = [CCFadeIn actionWithDuration:2.2f];
//    id lightFadeOut = [CCFadeOut actionWithDuration:3.3f];
//    id lightSequence = [CCSequence actions:lightFadeIn, lightFadeOut, nil];
//    [light runAction:lightSequence];


    id delay = [CCDelayTime actionWithDuration:15.0f];
    id remove = [CCCallFuncN actionWithTarget:self selector:@selector(remove)];
    id sequence = [CCSequence actions:delay, remove, nil];

    [self runAction:sequence];
}

- (void)remove
{
    [self removeFromParentAndCleanup:YES];
}


@end