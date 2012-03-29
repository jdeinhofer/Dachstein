//
//  Created by jdeinhofer on 3/28/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

#define FONT_OUTLINE @"SFFedora"
#define FONT_LABEL @"SFFedora"


@interface TMCLabel : CCLayer {
    CCLabelTTF *_outline1;
    CCLabelTTF *_outline2;
    CCLabelTTF *_label;
}
- (id)initWithFontsize:(float)fontSize;
- (void) setString: (NSString *) text;

- (void)setOpacity:(GLubyte)opacity;


@end