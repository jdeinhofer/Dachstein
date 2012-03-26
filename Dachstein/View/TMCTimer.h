//
//  TMCTimer.h
//  Dachstein
//
//  Created by Josef Deinhofer on 2/16/12.
//  Copyright (c) 2012 TheMountainCalls. All rights reserved.
//

#import "CCNode.h"

@interface TMCTimer : CCNode {
    CCProgressTimer* _timer;
}

- (id) init;
- (void) setProgress: (float) progress;

@end
