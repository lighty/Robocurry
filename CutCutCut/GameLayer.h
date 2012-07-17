//
//  titleLabelLayer.h
//  CutCutCut
//
//  Created by 光 渡邊 on 12/07/08.
//  Copyright __MyCompanyName__ 2012年. All rights reserved.
//
#define calculate_determinant_2x2(x1,y1,x2,y2) x1*y2-y1*x2
#define calculate_determinant_2x3(x1,y1,x2,y2,x3,y3) x1*y2+x2*y3+x3*y1-y1*x2-y2*x3-y3*x1
#define frandom (float)arc4random()/UINT64_C(0x100000000)
#define frandom_range(low,high) ((high-low)*frandom)+low
#define random_range(low,high) (arc4random()%(high-low+1))+low
#define midpoint(a,b) (float)(a+b)/2

#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

#import "PolygonSprite.h"
#import "RayCastCallback.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32
#define NABE_SPEED 2
#define MIN_CUT_AREA 1.0

// GameLayer
@interface GameLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
	b2World* world;					// strong ref
    b2Body* groundBody;
	GLESDebugDraw *m_debugDraw;		// strong ref
    
    
    CCArray *_cache;
    
    CGPoint _startPoint;
    CGPoint _endPoint;
    
    RayCastCallback *_rayCastCallback;
    
    b2MouseJoint *_mouseJoint;
    
    // 野菜を画面外からpushするための変数
    double _nextPushTime;
    double _pushInterval;
    int _tmPushCount;
    
    // ナベを画面下からズズッとするための変数
    BOOL _isNabeMoving;
}

// returns a CCScene that contains the GameLayer as the only child
+(CCScene *) scene;

@property(nonatomic,retain)CCArray *cache;

-(b2Vec2*)arrangeVertices:(b2Vec2*)vertices count:(int)count;
-(void)splitPolygonSprite:(PolygonSprite*)sprite;
-(BOOL)areVerticesAcceptable:(b2Vec2*)vertices count:(int)count;
-(b2Body*)createBodyWithPosition:(b2Vec2)position rotation:(float)rotation vertices:(b2Vec2*)vertices vertexCount:(int32)count density:(float)density friction:(float)friction restitution:(float)restitution;

@end

