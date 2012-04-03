//
//  TMCGameController.m
//  Dachstein
//
//  Created by Josef Deinhofer on 12/7/11.
//  Copyright 2011 TheMountainCalls. All rights reserved.
//

#import "TMCGameController.h"

#import "SimpleAudioEngine.h"
#import "TMCRulesClassic.h"
#import "TMCBlossomExplosion.h"

#define HINT_TIMER_DELAY 8.0f


@interface TMCGameController ()
- (void)resetHintTimer;
- (void)showHint;

- (void)startExplosionOnView:(TMCColumnView *)columnView;

- (void)handleNoMatchSituation;

- (void)prepareGame;
- (void)startBackgroundAmbience;
- (void)setSelectedView:(TMCColumnView *)view;
- (void)startBackgroundMusic;
- (void)startGame;
- (void)endGame;
- (void)enableGame;
@end

@implementation TMCGameController {
    TMCModel *_model;
    TMCGameView *_view;
    id <TMCRules> _rules;
    TMCGameState _gameState;
    TMCColumnView *_selectedColumnView;
}

@synthesize view = _view;

- (id)init
{
    self = [super init];
    
    if (self) {
        _model = [[TMCModel alloc] init];
        _view = [[TMCGameView alloc] initWithControllerDelegate: self model: _model];
        _rules = [[TMCRulesClassic alloc] initWithController: self];
        
        _selectedColumnView = nil;
        
        [self startBackgroundAmbience];
    }
    
    return self;
}

- (void)startExplosionOnView:(TMCColumnView *)columnView {
    TMCBlossomExplosion *explosion = [[TMCBlossomExplosion alloc] initWithTile:columnView.column.tile];
    explosion.position = columnView.position;
    [columnView.parent addChild:explosion];
    [explosion start];
}

- (void)removePair:(TMCColumnView *)columnView pickedColumn:(TMCColumn *)pickedColumn selectedColumn:(TMCColumn *)selectedColumn {
    int topOff = [_model getMinTopOffset];

    [_rules pickedTile:[pickedColumn tile]];

    [self startExplosionOnView:columnView];
    [self startExplosionOnView:_selectedColumnView];

    [selectedColumn pick];
    [pickedColumn pick];

    int newTopOff = [_model getMinTopOffset];
    if (topOff != newTopOff) {
        [_model raiseByOne];
        [_view updateVerticalOffset];
    }

    [selectedColumn setTile:[_model randomizeTileFor:selectedColumn]];
    [pickedColumn setTile:[_model randomizeTileFor:pickedColumn]];

    [_selectedColumnView refresh];
    [columnView refresh];

    [_selectedColumnView startSnapAnim: SNAP_DURATION];
    [columnView startSnapAnim: SNAP_DURATION + 0.075f];

    [self setSelectedView:nil];

    [self handleNoMatchSituation];
}

- (void) handleNoMatchSituation
{
    if ([_model noMatchingTiles]) {
        TMCColumn *swappedColumn = [_model swapHighestPickableColumn];
        [_view swapViewFor: swappedColumn];
    }
}

- (void) columnViewTouched: (TMCColumnView*) columnView onRelease:(BOOL)onRelease
{
    if (_gameState == GAMESTATE_GAMEOVER)
        return;

    if (_gameState == GAMESTATE_NEW) {
        [self prepareGame];
        return;
    }

    TMCColumn* column = [columnView column];
    TMCColumn* selectedColumn = [_selectedColumnView column];

    if (column == nil) {
        [self setSelectedView:nil];
    }
    else if (![column isPickable]) {
        if (!onRelease) {
            [_view playWiggleAnimFor:columnView];
            [[SimpleAudioEngine sharedEngine] playEffect:@"blocked.wav"];
        }
    }
    else if (_selectedColumnView != columnView && [selectedColumn tile] == [column tile]) {
        [self removePair:columnView pickedColumn:column selectedColumn:selectedColumn];
    }
    else if (_selectedColumnView != columnView && !onRelease) {
        [self setSelectedView:columnView];

        if (_gameState == GAMESTATE_INIT) {
            [self startGame];
        }
    }

    [self resetHintTimer];
}

- (void) prepareGame
{
    _gameState = GAMESTATE_INIT;
    [_model resetColumns];
    [_model randomizeInitialTiles];
    [_view reset];
    [_rules prepareGame];
    [self setSelectedView:nil];
    [self resetHintTimer];

    [self startBackgroundMusic];
}

- (void) startGame
{
    _gameState = GAMESTATE_RUNNING;
    [_rules startGame];
}

- (void) endGame
{
    _gameState = GAMESTATE_GAMEOVER;
    [[CCScheduler sharedScheduler] unscheduleSelector:@selector(showHint) forTarget:self];
    [_view playGameOverAnimations];
    [self startBackgroundAmbience];

    [_view runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2], [CCCallFunc actionWithTarget:self selector:@selector(enableGame)], nil]];
}

- (void) enableGame
{
    _gameState = GAMESTATE_NEW;
}

- (void) resetHintTimer
{
    [[CCScheduler sharedScheduler] unscheduleSelector:@selector(showHint) forTarget:self];
    [[CCScheduler sharedScheduler] scheduleSelector:@selector(showHint) forTarget:self interval:HINT_TIMER_DELAY paused:false];
}

- (void)highlightRandomizedViewIn:(NSMutableArray *)matchingTile {
    TMCColumnView *randomizedView = [matchingTile objectAtIndex:(NSUInteger)(random() % [matchingTile count])];
    [_view showHintOn:randomizedView];
}

- (void)highLightMatchingTile {
    TMCTile *tile = [[_selectedColumnView column] tile];

    NSArray *pickableViews = [_view getPickableColumnViewsExcluding:_selectedColumnView];
    NSMutableArray *viewsContainingMatchingTile = [[[NSMutableArray alloc] init] autorelease];
    for(TMCColumnView *view in pickableViews) {
        if (view.column.tile == tile) {
            [viewsContainingMatchingTile addObject:view];
        }
    }

    [self highlightRandomizedViewIn:viewsContainingMatchingTile];
}

- (void)highlightPairableView {
    NSArray *pickableViews = [_view getPickableColumnViewsExcluding:nil];
    NSMutableArray *pairableViews = [[[NSMutableArray alloc] init] autorelease];
    for (TMCColumnView *view in pickableViews) {
        if (view.column.tile.pickable > 1) {
            [pairableViews addObject:view];
        }
    }

    [self highlightRandomizedViewIn:pairableViews];
}

- (void) showHint
{
    [_model updateTileStats];

    if (_selectedColumnView != nil && [[[_selectedColumnView column] tile] pickable] > 1) {
        [self highLightMatchingTile];
    }
    else {
        [self highlightPairableView];
    }
}

- (void) setSelectedView: (TMCColumnView*) view
{
    _selectedColumnView = view;
    [_view setSelectionTo:view];

    if (view != nil) {
        [_rules selectedTile:view.column.tile];
    }
}

- (void)startBackgroundAmbience
{
    [[CDAudioManager sharedManager] playBackgroundMusic:@"ambience.mp3" loop:YES];
}

- (void)startBackgroundMusic
{
    [[CDAudioManager sharedManager] playBackgroundMusic:@"music.mp3" loop:YES];
}

- (void) update: (ccTime) delta
{
    if (_gameState == GAMESTATE_RUNNING) {
        [_rules update:delta];
    }
}

-(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	TMCGameView *layer = _view;
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void) dealloc
{
    [_model release];
    [_view release];
    [_rules release];

    [super dealloc];
}

@end
