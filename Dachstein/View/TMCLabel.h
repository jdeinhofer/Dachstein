//
//  Created by jdeinhofer on 3/28/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


@interface TMCLabel : CCLayer

- (id)initWithFontsize:(int)fontSize;
- (void) setString: (NSString *) text;
- (void)setOpacity:(GLubyte)opacity;

@end