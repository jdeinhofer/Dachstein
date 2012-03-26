//
//  TMCGameView.m
//  Dachstein
//
//  Created by Josef Deinhofer on 12/7/11.
//  Copyright 2011 TheMountainCalls. All rights reserved.
//

#import "TMCGameView.h"

@implementation TMCGameView

@synthesize hudClassic=_hudClassic;


- (id) initWithControllerDelegate:(id<TMCViewControllerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _controllerDelegate = delegate;

        // register for touch events
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
        // setup layout
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        [self setupResourcesAndLayout:screenSize];
        [self setupBackground];
        [self setupColumnViews];
        [self setupHudsWith:screenSize];

        _hint = [[TMCHint alloc] init];
        _selection = [[TMCSelectionHighlight alloc] init];

        // start game tick
        [self scheduleUpdate];
    }
    
    return self;
}

- (void) setupResourcesAndLayout: (CGSize)screensize
{
    // TMP! - load lo-res textures for 480x320 devices
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"texture_tiles_retina.plist"];
    
    CGPoint screenCenter = ccp(screensize.width / 2, screensize.height / 2);
    [self setAnchorPoint:ccp(0,0)];
    [self setPosition:screenCenter];
}

- (void)setupBackground
{
    _background = [[TMCBackground alloc] init];

    [self addChild:_background];

    // TMP!
    if ([TMCGameView isLowRes]) [_background setScale:0.5f];
}


- (void)setupColumnViews {
    _columnViews = [[NSMutableArray alloc] init];
    
    _columnViewsRoot = [[CCNode alloc] init];
    
    [self addChild:_columnViewsRoot];

    TMCModel *model = [_controllerDelegate model];

    for (int y = -COLUMNS_OFFSET; y <= COLUMNS_OFFSET; y++) {
        for (int x = -COLUMNS_OFFSET; x <= COLUMNS_OFFSET; x++) {
            TMCColumn* column = [model getColumnAtX:x Y:y];
            if (column) {
                [self setupViewForColumn:column];
            }
        }
    }

    // TMP!
    if ([TMCGameView isLowRes])
        [_columnViewsRoot setScale: 0.5f];
    else
        [_columnViewsRoot setScale: 1.0f];
}


- (void) setSelectionTo: (TMCColumnView*) view
{
    // if something is selected: deselect it
    [_selection removeFromParentAndCleanup:YES];
    
    if (view == nil) return; 

    [view addChild:_selection];
    [_selection restartAnimation];
}


- (void) showHintOn: (TMCColumnView*) view
{
    [view addChild:_hint];
    [_hint restartAnimation];
}

- (NSArray *)getPickableColumnViewsExcluding:(TMCColumnView *)excludedView {
    NSMutableArray* ret = [[[NSMutableArray alloc] init] autorelease];

    for (TMCColumnView * view in _columnViews) {
        if (view != excludedView && [[view column] isPickable]) {
             [ret addObject:view];
        }
    }

    return ret;
}


- (void) setLevel: (int)level
{
    [_background setLevel:level];
}

- (void) setupViewForColumn: (TMCColumn*) column
{
    TMCColumnView* columnView = [[[TMCColumnView alloc] initWithColumn:column] autorelease];
    [_columnViewsRoot addChild:columnView];
    [_columnViews insertObject:columnView atIndex:0];
}

- (void) playGameStartAnimations
{
    for (TMCColumnView* view in _columnViews) {
        [view refresh];
    }
    
    [self updateVerticalOffset];

    float snapDuration = SNAP_DURATION * 1.2;
    NSMutableArray* columnViews = [[_columnViews mutableCopy] autorelease];
    while ([columnViews count] > 0) {
        NSUInteger index = (NSUInteger)(random() % [columnViews count]);
        TMCColumnView* view = [columnViews objectAtIndex:(NSUInteger)index];
        [columnViews removeObjectAtIndex:(NSUInteger)index];
        [view startSnapAnim:snapDuration];
        snapDuration += 0.02;
    }
}

- (void) playGameOverAnimations
{
    float dropDelay = 0;
    NSMutableArray* columnViews = [[_columnViews mutableCopy] autorelease];
    while ([columnViews count] > 0) {
        NSUInteger index = (NSUInteger)(random() % [columnViews count]);
        TMCColumnView* view = [columnViews objectAtIndex:index];
        [columnViews removeObjectAtIndex:index];
        [view startDropAnim:dropDelay];
        dropDelay += 0.005;
    }
}

- (void) updateVerticalOffset
{
    for (TMCColumnView* view in _columnViews) {
        if ([[view column] tile] != nil) {
             [view startRaiseAnim];
        }
    }
}

- (void) update: (ccTime) delta
{
    [_controllerDelegate update: delta];
}


- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    TMCColumnView* touched = [self findColumnTouchedBy:touch];
    [_controllerDelegate columnViewTouched:touched onRelease:FALSE];
    
    return (touched != nil); // YES, wenn ich ihn will
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    TMCColumnView* touched = [self findColumnTouchedBy:touch];
    [_controllerDelegate columnViewTouched:touched onRelease:TRUE];
}

- (id) findColumnTouchedBy:(UITouch*)touch
{
    TMCColumnView *nearestPickable = [self nearestViewTouchedBy:touch flagged:TRUE];
    if (nearestPickable)
        return nearestPickable;
    else
        return [self nearestViewTouchedBy:touch flagged:FALSE];
}

- (TMCColumnView *) nearestViewTouchedBy: (UITouch *) touch flagged: (BOOL) pickable
{
    CGSize textureSize = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Red_1.png"].rect.size;
    float maxDistSqr = (textureSize.width * textureSize.width + textureSize.height * textureSize.height) / 9;
    TMCColumnView *nearest = nil;
    
    for (TMCColumnView *view in _columnViews) {
        if (view.column.isPickable == pickable) {
            CGRect box = view.sprite.boundingBox;
            float viewX = box.origin.x + box.size.width / 2;
            float viewY = box.origin.y + box.size.height / 2;
            
            CGPoint touchLocationView = [view convertTouchToNodeSpace:touch];
            float dX = viewX - touchLocationView.x;
            float dY = viewY - touchLocationView.y;
            
            float distSqr = dX * dX + dY * dY;
            if (distSqr < maxDistSqr) {
                nearest = view;
                maxDistSqr = distSqr;
            }
        }
    }
    
    return nearest;
}

+ (BOOL) isLowRes {
    CGSize pixelSize = [[CCDirector sharedDirector] winSizeInPixels];
    return (pixelSize.width < 960);
}

- (void)setupHudsWith:(CGSize)screenSize {
    _hudClassic = [[TMCHudClassic alloc] initWithScreenSize:screenSize];
    [self addChild:_hudClassic];

    _huds = [[NSArray alloc] initWithObjects:_hudClassic, nil];
}

- (void) showHud: (id)hud {
    for (CCNode *anyHud in _huds) {
        [anyHud setVisible:(anyHud == hud)];
    }
}

- (void) reset
{
    [self setLevel:0];
    [self playGameStartAnimations];
    [self setSelectionTo:nil];
}

- (void) dealloc
{
    [_background release];
    [_columnViews release];
    [_columnViewsRoot release];
    [_selection release];
    [_hint release];
    [_hudClassic release];
    [_huds release];

    [super dealloc];
}

@end
