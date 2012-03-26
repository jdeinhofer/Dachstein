//
//  Created by jdeinhofer on 3/19/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface TMCProgressBar : CCNode {
    CCSprite *_fgSprite;
    CCSprite *_bgSprite;
    CGSize _sizeFG;
    CGSize _sizeBG;
}
- (id)initWithSizeBG:(CGSize)sizeBG bgFrameName:(NSString *)bgFrameName sizeFG:(CGSize)sizeFG fgFrameName:(NSString *)fgFrameName;

- (void)setProgress:(float)progress;


@end