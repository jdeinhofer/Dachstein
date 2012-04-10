//
//  Created by jdeinhofer on 3/28/12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "TMCLabel.h"
#import "TMCGameView.h"

@implementation TMCLabel {
    CCLabelBMFont *_bmfLabel;
}

- (id)initWithFontsize:(int)fontSize {
    self = [super init];
    if (self) {
        if (![TMCGameView isLowRes]) {
            fontSize *= 2;
        }
        NSString *fontFileName = [NSString stringWithFormat:@"Fedora%i.fnt", fontSize];
        _bmfLabel = [[CCLabelBMFont alloc] initWithString:@"" fntFile:fontFileName];
        [self addChild:_bmfLabel];
    }

    return self;
}

- (void) setString: (NSString *) text
{
    [_bmfLabel setString:text];
}

- (void) setOpacity: (GLubyte) opacity
{
    [_bmfLabel setOpacity:opacity];
}

- (void) dealloc
{
    [_bmfLabel release];

    [super dealloc];
}

@end