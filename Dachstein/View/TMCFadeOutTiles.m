//
//  Created by jdeinhofer on 4/11/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TMCFadeOutTiles.h"


@implementation TMCFadeOutTiles

-(float)testFunc:(ccGridSize)pos time:(ccTime)time
{
//	CGPoint	n = ccpMult(ccp(gridSize_.x, gridSize_.y), (1.0f-time));
//	if ( (pos.x+pos.y) == 0 )
//		return 1.0f;
//
//	return powf( (n.x+n.y) / (pos.x+pos.y), 6 );

    int numTiles = gridSize_.x * gridSize_.y;
    int indexTile = pos.x + (gridSize_.y - pos.y) * gridSize_.x;

    float factorTile = (float) indexTile / (float) numTiles;

    return MAX(0, (time - factorTile) * numTiles);


//    if (time >= factorTile)
//        return 0;
//    else
//        return 1;
}

@end