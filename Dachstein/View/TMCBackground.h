//
//  Created by jdeinhofer on 3/13/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface TMCBackground : CCNode {
    NSArray *_backgrounds;
    CCNode *_currentBackground;
    CCNode *_previousBackground;
    int _currentLevel;
}

- (id) init;
- (void) setLevel: (int) level;
- (void) finishTransition;


@end