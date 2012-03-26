//
//  Created by jdeinhofer on 3/19/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TMCProgressBar.h"

@implementation TMCProgressBar

- (id) initWithSizeBG: (CGSize) sizeBG bgFrameName:(NSString *) bgFrameName sizeFG: (CGSize) sizeFG fgFrameName: (NSString *) fgFrameName
{
    self = [super init];
    if (self) {
        _sizeFG = sizeFG;
        _sizeBG = sizeBG;
        _bgSprite = [CCSprite spriteWithSpriteFrameName:bgFrameName];
        _fgSprite = [CCSprite spriteWithSpriteFrameName:fgFrameName];
        
        CGSize bgSpriteSize = _bgSprite.textureRect.size;
        _bgSprite.scaleX = sizeBG.width / bgSpriteSize.width;
        _bgSprite.scaleY = sizeBG.height / bgSpriteSize.height;
        
        CGSize fgSpriteSize = _fgSprite.textureRect.size;
        _fgSprite.scaleX = sizeFG.width / fgSpriteSize.width;
        _fgSprite.scaleY = sizeFG.height / fgSpriteSize.height;
        
        _fgSprite.anchorPoint = ccp(1, 0.5f);
        _fgSprite.position = ccp(sizeFG.width / 2, 0);

        [self addChild:_bgSprite];
        [self addChild:_fgSprite];
    }

    return self;
}

- (void) setProgress: (float) progress
{
    NSAssert(progress >= 0 && progress <= 1, @"Progress must be between 0 and 1");

    CGSize fgSpriteSize = _fgSprite.textureRect.size;
    _fgSprite.scaleX = progress * _sizeFG.width / fgSpriteSize.width;
}

- (void) dealloc
{
    [_fgSprite release];
    [_bgSprite release];

    [super dealloc];
}

@end