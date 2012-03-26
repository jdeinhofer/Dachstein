//
//  Created by jdeinhofer on 3/12/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@interface TMCHint : CCNode {
    CCSprite *_spriteA;
    CCSprite *_spriteB;
}

- (id) init;
- (void) restartAnimation;
- (void) removeFromParent;

@end