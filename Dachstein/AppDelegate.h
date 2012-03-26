//
//  AppDelegate.h
//  Dachstein
//
//  Created by Josef Deinhofer on 9/1/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMCGameController.h"

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
    TMCGameController   *gameController;
}

@property (nonatomic, retain) UIWindow *window;

@end
