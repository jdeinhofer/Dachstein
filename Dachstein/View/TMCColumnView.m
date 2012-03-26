//
//  TMCColumnView.m
//  Dachstein
//
//  Created by Josef Deinhofer on 2/13/12.
//  Copyright (c) 2012 TheMountainCalls. All rights reserved.
//

#import "TMCColumnView.h"

@implementation TMCColumnView

@synthesize sprite=_sprite;
@synthesize column=_column;

- (id) initWithColumn:(TMCColumn *)column
{
    self = [super init];
    if (self) {
        _column = column;
        _column.view = self;
        _sprite = [CCSprite alloc];
        
        [self addChild:_sprite];

        _shadow = [[CCSprite alloc] initWithSpriteFrameName:@"Red_1.png"];
        [_shadow setColor:ccc3(0, 0, 0)];
        [self addChild:_shadow];
        [_shadow setOpacity:0];
    }
    
    return self;
}

- (void) refresh
{
    // update sprite view
    TMCTile* tile = [_column tile];
    NSString* spriteFrameName = [TMCColumnView spriteFrameNameForTile:tile];
	[_sprite initWithSpriteFrameName:spriteFrameName];
    
    // update position
    CGPoint position = [self calculatePosition];
    
    [self setPosition:position];
}

- (CGPoint)calculatePosition
{
    int x = _column.x;
    int y = _column.y;
    int z = _column.top;
    
    float contentHeight = _sprite.contentSize.height;
    float contentWidth = _sprite.contentSize.width;

    float tileHeight = contentHeight * 0.85f;
    float tileStep = contentHeight - tileHeight;
    float tileWidth = contentWidth;

    float xx = x * tileWidth / 2;
    float xy = -y * tileWidth * 3 / 4;

    float yx = -x * tileHeight / 2;
    float yy = -y * tileHeight / 4;
    float yz = -z * tileStep;    

    CGPoint position = ccp(xx + xy, yx + yy + yz);
    
    return position;
}

- (void) startRaiseAnim
{
    CGPoint desiredPosition = [self calculatePosition];
    
    id moveAction = [CCMoveTo actionWithDuration:RAISE_DURATION position:desiredPosition];
    [self runAction:moveAction];
    
    id brightenAction = [CCFadeTo actionWithDuration:RAISE_DURATION opacity:(GLubyte)[self calculateShadowOpacity]];

    [_shadow runAction:brightenAction];
}

- (void) startSnapAnim: (float) duration
{
    CGPoint currentPosition = [self calculatePosition];
    float cX = currentPosition.x;
    float cY = currentPosition.y;
    [self setPosition:ccp(cX, cY + SNAP_DISTANCE)];
    id moveAction = [CCMoveTo actionWithDuration:duration position:ccp(cX, cY)];
    id snapAction = [CCEaseBackOut actionWithAction:moveAction];
    
    [self runAction:snapAction];

    [_shadow setOpacity:255];
    id brightenAction = [CCFadeTo actionWithDuration:duration opacity:(GLubyte)[self calculateShadowOpacity]];

    [_shadow runAction:brightenAction];
}

- (int) calculateShadowOpacity
{
    float quadratic = SHADE_OPACITY_QUADRATIC * (1.0f - 1.0f / (1.0f + [_column top]));
    float linear = SHADE_OPACITY_LINEAR * [_column top];
    float opacityOfLevel = quadratic + linear;
    float opacityCorrectionY = 25 * SHADE_OPACITY_PERY * (_column.y + _column.x) * -1;

    float total = opacityOfLevel + opacityCorrectionY;

    total = MAX(0, total);
    total = MIN(255, total);

    float corrected = SHADE_OPACITY_MAX * total / 255;
    
    int opacity = (int) corrected;
    
    return opacity;
}

- (void) startDropAnim: (float) delay
{
    id delayAction = [CCDelayTime actionWithDuration:delay];
    id moveAction = [CCMoveBy actionWithDuration:DROP_DURATION position:ccp(0, DROP_DISTANCE)];
    id jumpAction = [CCEaseExponentialIn actionWithAction:moveAction];
    
    id sequence = [CCSequence actions: delayAction, jumpAction, nil];
    
    [self runAction:sequence];
}

- (void) startWiggleAnim
{
    CGPoint endPosition = [self calculatePosition];
    
    id moveLeft = [CCMoveTo actionWithDuration:WIGGLE_DURATION_HORIZONTAL / 2 position:ccp(endPosition.x - WIGGLE_HORIZONTAL, endPosition.y)];
    id moveRight = [CCMoveTo actionWithDuration:WIGGLE_DURATION_HORIZONTAL position:ccp(endPosition.x + WIGGLE_HORIZONTAL, endPosition.y)];
    id reposition = [CCMoveTo actionWithDuration:WIGGLE_DURATION_HORIZONTAL / 2 position:endPosition];

    id sequence = [CCSequence actions: moveLeft, moveRight, reposition, nil];

    [self runAction:sequence];

    id rotateLeft1 = [CCRotateTo actionWithDuration:WIGGLE_DURATION_ROTATION / 2 angle:WIGGLE_ANGLE];
    id rotateRight1 = [CCRotateTo actionWithDuration:WIGGLE_DURATION_ROTATION angle:-WIGGLE_ANGLE];
    id rotateLeft2 = [CCRotateTo actionWithDuration:WIGGLE_DURATION_ROTATION angle:WIGGLE_ANGLE];
    id rotateRight2 = [CCRotateTo actionWithDuration:WIGGLE_DURATION_ROTATION angle:-WIGGLE_ANGLE];
    id rotateBack = [CCRotateTo actionWithDuration:WIGGLE_DURATION_ROTATION / 2 angle:0];

    id sequence2 = [CCSequence actions: rotateLeft1, rotateRight1, rotateLeft2, rotateRight2, rotateBack, nil];
    
    [self runAction:sequence2];
}

+ (NSString*) spriteFrameNameForTile: (TMCTile*) tile
{
    switch (tile.color) {
        case 0:
            switch (tile.value) {
                case 0: return @"Blue_1.png";
                case 1: return @"Blue_2.png";
                case 2: return @"Blue_3.png";
                case 3: return @"Blue_4.png";
            }
            break;
        case 1:
            switch (tile.value) {
                case 0: return @"Green_1.png";
                case 1: return @"Green_2.png";
                case 2: return @"Green_3.png";
                case 3: return @"Green_4.png";
            }
            break;
        case 2:
            switch (tile.value) {
                case 0: return @"Red_1.png";
                case 1: return @"Red_2.png";
                case 2: return @"Red_3.png";
                case 3: return @"Red_4.png";
            }
            break;
        case 3:
            switch (tile.value) {
                case 0: return @"Orange_1.png";
                case 1: return @"Orange_2.png";
                case 2: return @"Orange_3.png";
                case 3: return @"Orange_4.png";
            }
            break;
    }
    
    // default
    return nil;
    
//    return @"Red_1.png";
}

- (void) dealloc
{
    [_sprite release];
    [_shadow release];

    [super dealloc];
}

@end
