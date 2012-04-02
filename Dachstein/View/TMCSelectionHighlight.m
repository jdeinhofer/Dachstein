//
//  Created by jdeinhofer on 3/12/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TMCSelectionHighlight.h"


@implementation TMCSelectionHighlight {
    CCSprite *_sprite;
}

- (id) init
{
    self = [super init];
    if (self) {
        _sprite = [[CCSprite alloc] initWithSpriteFrameName:@"Selection.png"];
        [self addChild:_sprite];
    }

    return self;
}

- (void) restartAnimation
{
    [_sprite setOpacity:255];

    id blendIn = [CCFadeTo actionWithDuration:0.6f opacity:128];
    id blendOut = [CCFadeTo actionWithDuration:0.6f opacity:255];
    id sequence = [CCSequence actions:blendIn, blendOut, nil];
    id loop = [CCRepeatForever actionWithAction:sequence];

    [_sprite stopAllActions];
    [_sprite runAction:loop];
}

- (void) dealloc
{
    [_sprite release];

    [super dealloc];
}

@end