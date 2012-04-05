//
//  Created by jdeinhofer on 4/5/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TMCBlossom.h"

@implementation TMCBlossom {
    CGPoint _movement;
    float timeToFullWind;
    float remaining;
}


float randomizeFloatA() {
    return ((float)random() / RAND_MAX);
}

CGPoint randomizePointA() {
    float x = randomizeFloatA() - 0.5f;
    float y = randomizeFloatA() - 0.5f;
    return ccp(x, y);
}

float randomizeInRangeA(float min, float max) {
    float range = max - min;
    return min + range * randomizeFloatA();
}

- (id)init
{
    self = [super init];
    if (self) {
        CGPoint tmp = randomizePointA();
//        _movement = ccp(0,0);
        _movement = ccp(tmp.x * 1500 + 100, tmp.y * 1500 + 300);

        timeToFullWind = randomizeInRangeA(0.1f, 2.0f);
        remaining = timeToFullWind;
    }
    return self;
}

- (void) update: (ccTime) delta
{
    // dampen impulse
    //_movement = ccpMult(_movement, 0.7f);

    CGPoint posOnScreen = [self convertToWorldSpace:self.position];
    float impulseAddY = 10 + 160 * sinf(posOnScreen.x / 100 + posOnScreen.y / 400);
    float impulseAddX = 350 + 50 * sinf(posOnScreen.x / 300 + posOnScreen.y / 200);

    CGPoint impulseAdd = ccp(impulseAddX, impulseAddY);

    if (remaining > 0) {
        remaining -= delta;
    }
    float windStrength = 1.0f - remaining / timeToFullWind;

    impulseAdd = ccpMult(impulseAdd, windStrength);

    _movement = ccpMult(_movement, 0.97f);
    impulseAdd = ccpMult(impulseAdd, 0.03f);
    _movement = ccpAdd(_movement, impulseAdd);

    CGPoint gravity = ccp(0, 120);
    gravity = ccpMult(gravity, (1.0f - windStrength) * delta);

    _movement = ccpAdd(_movement, gravity);

//    impulseAdd = ccpMult(impulseAdd, MIN(1.0f, delta));
//
//    CGPoint impulseOld = ccpMult(_movement, MAX(0, 1.0f - delta));
//
//    _movement = ccpAdd(impulseOld, impulseAdd);

    CGPoint position = self.position;
    position = ccpAdd(position, ccpMult(_movement, delta));
    [self setPosition:position];

    //self.position = ccp(self.position.x + 1, self.position.y);
}

@end