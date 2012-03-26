//
//  Created by jdeinhofer on 3/14/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TMCNumberTicker.h"


@implementation TMCNumberTicker


- (id)initWithFrameName:(NSString *)frameName {
    self = [super init];
    if (self) {
        NSMutableArray *tmpNames = [NSMutableArray arrayWithCapacity:10];
        NSString *tmpName = [NSString stringWithFormat:@"%@_%i.png", frameName, 0];

        _spriteSize = [[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:tmpName] rect].size;

        for(int i = 0; i < 10; i++) {
            [tmpNames addObject:[NSString stringWithFormat:@"%@_%i.png", frameName, i]];
            _digits[i] = 0;

            [self setupDigit:i frameName:tmpName];
        }

        _visibleDigits = 0;
        _frameNames = [[NSArray arrayWithArray:tmpNames] retain];
    }

    return self;
}

- (void) setValue: (int) value {
    CCArray *sprites = [self children];

    for( int i = 0; i < 10; i++) {
        
        CCSprite *spriteTop = [sprites objectAtIndex:i*2];
        CCSprite *spriteBottom = [sprites objectAtIndex:i*2+1];
        
        if (value == 0) {
            spriteTop.visible = FALSE;
            spriteBottom.visible = FALSE;
        }
        else {
            spriteBottom.visible = TRUE;
            
            if (i > _visibleDigits) {
                spriteTop.visible = FALSE;
                _visibleDigits = i;
            }
            else
            {
                spriteTop.visible = TRUE;
            }
    
            int digit = value % 10;
            int currentDigit = _digits[i];

            if (digit != currentDigit) {
                [self updateDigitSprites:spriteTop bottom:spriteBottom currentValue:currentDigit newValue:digit];
                
                _digits[i] = digit;
            }
    
            value = value / 10;
        }
    }

    [self setPosition:ccp(5 * _spriteSize.width, 0)];
}


- (void) updateDigitSprites: (CCSprite *) spriteTop bottom: (CCSprite *) spriteBottom currentValue: (int) currentValue newValue: (int) value
{
    NSString *spriteFrameNameTop = [_frameNames objectAtIndex:currentValue];
    CCSpriteFrame *spriteFrameTop = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameNameTop];
    [spriteTop setDisplayFrame:spriteFrameTop];

    NSString *spriteFrameNameBottom = [_frameNames objectAtIndex:value];
    CCSpriteFrame *spriteFrameBottom = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameNameBottom];
    [spriteBottom setDisplayFrame:spriteFrameBottom];

    [spriteTop setScaleY:1];
    [spriteBottom setScaleY:0];

    [spriteTop runAction:[CCEaseSineOut actionWithAction:[CCScaleTo actionWithDuration:1 scaleX:1 scaleY:0]]];
    [spriteBottom runAction:[CCEaseSineOut actionWithAction:[CCScaleTo actionWithDuration:1 scaleX:1 scaleY:1]]];
}


- (void)setupDigit:(int)digit frameName:(NSString *)frameName {
    CCSprite *spriteTop = [CCSprite spriteWithSpriteFrameName:frameName];
    [spriteTop setAnchorPoint:ccp(0.5f, 1)];
    [spriteTop setScaleY:0];

    CCSprite *spriteBottom = [CCSprite spriteWithSpriteFrameName:frameName];
    [spriteBottom setAnchorPoint:ccp(0.5f, 0)];
    [spriteBottom setScaleY:1];

    CGPoint spriteTopPosition = ccp(-1 * digit * _spriteSize.width, _spriteSize.height / 2);
    [spriteTop setPosition:spriteTopPosition];
    CGPoint spriteBottomPosition = ccp(-1 * digit * _spriteSize.width, _spriteSize.height / -2);
    [spriteBottom setPosition:spriteBottomPosition];

    [self addChild:spriteTop];
    [self addChild:spriteBottom];
}

@end