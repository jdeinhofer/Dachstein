//
//  Created by jdeinhofer on 3/14/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface TMCNumberTicker : CCNode {
    NSArray *_frameNames;
    int _digits[10];
    int _visibleDigits;
    CGSize _spriteSize;
}

- (id) initWithFrameName: (NSString *) frameName;
- (void) setValue: (int) value;
- (void)updateDigitSprites:(CCSprite *)spriteTop bottom:(CCSprite *)spriteBottom currentValue:(int)currentValue newValue:(int)value;
- (void)setupDigit:(int)digit frameName:(NSString *)frameName;


@end