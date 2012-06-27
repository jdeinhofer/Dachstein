//
//  TMCGameView.m
//  Dachstein
//
//  Created by Josef Deinhofer on 12/7/11.
//  Copyright 2011 TheMountainCalls. All rights reserved.
//


#import "TMCGameView.h"

#import "TMCSelectionHighlight.h"
#import "TMCHint.h"
#import "TMCBackground.h"


@interface TMCGameView ()
- (void)setupResourcesAndLayout:(CGSize)screensize;
- (void)setupColumnViewsFromModel:(TMCModel *)model;
- (void)setupBackground;
- (void)setupHudsWith:(CGSize)screenSize;
- (id)findColumnTouchedBy:(UITouch *)touch;
@end

@implementation TMCGameView {
    id <TMCViewControllerDelegate> _controllerDelegate;

    NSDictionary *_columnViewsByColumn;
    CCNode* _columnViewsRoot;
    NSMutableArray* _columnViews;
    TMCBackground* _background;

    TMCSelectionHighlight* _selection;
    TMCHint* _hint;

    NSArray *_huds;
}

@synthesize hudClassic=_hudClassic;


- (id) initWithControllerDelegate:(id<TMCViewControllerDelegate>)delegate model:(TMCModel *) model
{
    self = [super init];
    if (self) {
        _controllerDelegate = delegate;

        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];

        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        [self setupResourcesAndLayout:screenSize];
        [self setupBackground];
        [self setupColumnViewsFromModel: model];
        [self setupHudsWith:screenSize];

        _hint = [[TMCHint alloc] init];
        _selection = [[TMCSelectionHighlight alloc] init];

        [self scheduleUpdate];
    }
    
    return self;
}

- (void) setupResourcesAndLayout: (CGSize)screensize
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"texture_tiles_retina.plist"];
    
    CGPoint screenCenter = ccp(screensize.width / 2, screensize.height / 2);
    [self setAnchorPoint:ccp(0,0)];
    [self setPosition:screenCenter];
}

- (void)setupBackground
{
    _background = [[TMCBackground alloc] init];

    [self addChild:_background];

    if ([TMCGameView isLowRes])
        [_background setScale:0.5f];
}

- (void)setupColumnViewsFromModel:(TMCModel *)model {
    _columnViews = [[NSMutableArray alloc] init];

    NSMutableDictionary *tmpDictionary = [NSMutableDictionary dictionary];
    
    _columnViewsRoot = [[CCNode alloc] init];
    
    [self addChild:_columnViewsRoot];

    for (int y = -COLUMNS_OFFSET; y <= COLUMNS_OFFSET; y++) {
        for (int x = -COLUMNS_OFFSET; x <= COLUMNS_OFFSET; x++) {
            TMCColumn* column = [model getColumnAtX:x Y:y];
            if (column) {
                TMCColumnView* columnView = [[[TMCColumnView alloc] initWithColumn:column] autorelease];
                [_columnViewsRoot addChild:columnView];
                [_columnViews insertObject:columnView atIndex:0];
                [tmpDictionary setObject:columnView forKey:[NSValue valueWithPointer:column]];
            }
        }
    }

    _columnViewsByColumn = [[NSDictionary alloc] initWithDictionary:tmpDictionary copyItems:FALSE];

    if ([TMCGameView isLowRes])
        [_columnViewsRoot setScale: 0.5f];
}

- (void) setSelectionTo: (TMCColumnView*) view
{
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

- (void) playWiggleAnimFor: (TMCColumnView *) view {
    if ([[CCActionManager sharedManager] numberOfRunningActionsInTarget:view] > 0) return;

    [view startWiggleAnim];

    NSArray *neighbors = view.column.neighbors;

    for (TMCColumn *neighbor in neighbors) {
        if (neighbor.top > view.column.top) continue;

        TMCColumnView *neighborView = [_columnViewsByColumn objectForKey:[NSValue valueWithPointer:neighbor]];

        CGPoint neighborPos = neighborView.position;
        CGPoint offset = ccpMult(ccpSub(neighborPos, view.position), 0.05f);

        id moveAway = [CCMoveTo actionWithDuration:0.05f position:ccpAdd(neighborPos, offset)];
        id moveBack = [CCMoveTo actionWithDuration:0.25f position:neighborPos];
        id sequence = [CCSequence actions:moveAway, moveBack, nil];
        [neighborView runAction:sequence];
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
    CGSize textureSize = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Red_1.png"].rect.size;
    float maxDistSqr = (textureSize.width * textureSize.width + textureSize.height * textureSize.height) / 9;
    TMCColumnView *nearest = nil;

    for (TMCColumnView *view in _columnViews) {
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

    return nearest;
}

+ (BOOL) isLowRes {
    CGSize pixelSize = [[CCDirector sharedDirector] winSizeInPixels];
    return (pixelSize.width < 960);
}

- (void)setupHudsWith:(CGSize)screenSize {
    _hudClassic = [[TMCHudClassic alloc] initWithScreenSize:screenSize lowRes:[TMCGameView isLowRes]];
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

- (void)swapViewFor:(TMCColumn *)column {
    TMCColumnView *view = [_columnViewsByColumn objectForKey:[NSValue valueWithPointer:column]];
    [view refresh];
    [view startSnapAnim:SNAP_DURATION];
}

- (void) dealloc
{
    [_background release];
    [_columnViews release];
    [_columnViewsRoot release];
    [_columnViewsByColumn release];
    [_selection release];
    [_hint release];
    [_hudClassic release];
    [_huds release];

    [super dealloc];
}

@end
