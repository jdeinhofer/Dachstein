//
//  Created by jdeinhofer on 3/28/12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "TMCLabel.h"

@implementation TMCLabel {
    CCLabelTTF *_outline1;
    CCLabelTTF *_outline2;
    CCLabelTTF *_label;
}

- (id)initWithFontsize:(float)fontSize {
    self = [super init];
    if (self) {
        _outline1 = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(1000, fontSize * 2) alignment:UITextAlignmentCenter fontName:FONT_OUTLINE fontSize:fontSize];
        _outline2 = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(1000, fontSize * 2) alignment:UITextAlignmentCenter fontName:FONT_OUTLINE fontSize:fontSize];
        _label = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(1000, fontSize * 2) alignment:UITextAlignmentCenter fontName:FONT_LABEL fontSize:fontSize];

        [_outline1 setAnchorPoint:ccp(0.5f, 0.5f)];
        [_outline2 setAnchorPoint:ccp(0.5f, 0.5f)];
        [_label setAnchorPoint:ccp(0.5f, 0.5f)];

        [self addChild:_outline1];
        [self addChild:_outline2];
        [self addChild:_label];

        _outline1.color = ccc3(0, 0, 0);
        _outline2.color = ccc3(0, 0, 0);
        _label.color = ccc3(255, 255, 255);

        _outline1.position = ccp(-fontSize/10, fontSize/10);
        _outline1.position = ccp(fontSize/15, -fontSize/15);
    }

    return self;
}

- (void) setString: (NSString *) text
{
    [_outline1 setString:text];
    [_outline2 setString:text];
    [_label setString:text];
}

- (void) setOpacity: (GLubyte) opacity
{
    [_outline1 setOpacity:opacity];
    [_outline2 setOpacity:opacity];
    [_label setOpacity:opacity];
}

@end