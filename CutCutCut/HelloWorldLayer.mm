//
//  HelloWorldLayer.mm
//  CutCutCut
//
//  Created by 光 渡邊 on 12/07/08.
//  Copyright __MyCompanyName__ 2012年. All rights reserved.
//

#import "Watermelon.h"

// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

enum {
	kTagParentNode = 1,
};


#pragma mark - HelloWorldLayer

@interface HelloWorldLayer()
-(void) initPhysics;
-(void) addNewSpriteAtPosition:(CGPoint)p;
-(void) createMenu;
@end

int comparetor(const void *a, const void *b) {
    const b2Vec2 *va = (const b2Vec2 *)a;
    const b2Vec2 *vb = (const b2Vec2 *)b;
    if (va->x > vb->x) {
        return 1;
    } else if (va->x < vb->x) {
        return -1;
    }
    return 0;
}

@implementation HelloWorldLayer

@synthesize cache = _cache;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		
		// enable events
		
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		//CGSize s = [CCDirector sharedDirector].winSize;
		
		// init physics
		[self initPhysics];
		
        [self initSprites];
        _rayCastCallback = new RayCastCallback();
        
		[self scheduleUpdate];
	}
	return self;
}

-(void)initSprites
{
    _cache = [[CCArray alloc] initWithCapacity:53];
    
    // Just create one sprite for now. This whole method will be replaced later.
    PolygonSprite *sprite = [[Watermelon alloc] initWithWorld:world];
    [self addChild:sprite z:1];
    [sprite activateCollisions];
    [_cache addObject:sprite];    
}

-(void) dealloc
{
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
	
    [_cache release];
    _cache = nil;
    
	[super dealloc];
}	

-(void) initPhysics
{
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	b2Vec2 gravity;
	gravity.Set(0.0f, -10.0f);
	world = new b2World(gravity);
	
	
	// Do we want to let bodies sleep?
	world->SetAllowSleeping(true);
	
	world->SetContinuousPhysics(true);
	
	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	world->SetDebugDraw(m_debugDraw);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);		
	
	
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	b2Body* groundBody = world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2EdgeShape groundBox;		
	
	// bottom
	
	groundBox.Set(b2Vec2(0,0), b2Vec2(s.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// top
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);
	
	// left
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(0,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// right
	groundBox.Set(b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
}

-(void) draw
{
	//
	// IMPORTANT:
	// This is only for debug purposes
	// It is recommend to disable it
	//
	[super draw];
	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
    
    ccDrawLine(_startPoint, _endPoint);
	
	world->DrawDebugData();	
	
	kmGLPopMatrix();
}

-(void) update: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);	
    [self checkAndSliceObjects];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
	}
    [self clearSlices];
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches){
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector]convertToGL:location];
        _startPoint = location;
        _endPoint = location;
    }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches){
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector]convertToGL:location];
        _endPoint = location;
    }
    
    if (ccpLengthSQ(ccpSub(_startPoint, _endPoint)) > 25) {
        world->RayCast(_rayCastCallback, 
                       b2Vec2(_startPoint.x / PTM_RATIO, _startPoint.y / PTM_RATIO),
                       b2Vec2(_endPoint.x / PTM_RATIO, _endPoint.y / PTM_RATIO));
        world->RayCast(_rayCastCallback, 
                       b2Vec2(_endPoint.x / PTM_RATIO, _endPoint.y / PTM_RATIO),
                       b2Vec2(_startPoint.x / PTM_RATIO, _startPoint.y / PTM_RATIO));
        _startPoint = _endPoint;
    }
    
}

-(void)splitPolygonSprite:(PolygonSprite *)sprite
{
    PolygonSprite *newSprite1, *newSprite2;
    
    // our original shape's attribute
    b2Fixture *originalFixture = sprite.body->GetFixtureList();
    b2PolygonShape *originalPolygon = (b2PolygonShape*)originalFixture->GetShape();
    int vertexCount = originalPolygon->GetVertexCount();
    
    // our determinant(to be described later) and iterator
    float determinant;
    int i;
    
    // you store the vertices of our two new sprites here
    b2Vec2 *sprite1Vertices = (b2Vec2*)calloc(24, sizeof(b2Vec2));
    b2Vec2 *sprite2Vertices = (b2Vec2*)calloc(24, sizeof(b2Vec2));
    b2Vec2 *sprite1VerticesSorted, *sprite2VerticesSorted;
    
    int sprite1VerticesCount = 0;
    int sprite2VerticesCount = 0;
    
    // step1
    // the entry and exit point of our cut are considered vertices of our two new sprites, so you add these before anything else
    sprite1Vertices[sprite1VerticesCount++] = sprite.entryPoint;
    sprite1Vertices[sprite1VerticesCount++] = sprite.exitPoint;
    sprite2Vertices[sprite2VerticesCount++] = sprite.entryPoint;
    sprite2Vertices[sprite2VerticesCount++] = sprite.exitPoint;

    // step2
    // iterate through all the vertices and add them to each sprite's shape
    for (i=0; i<vertexCount; i++) {
        b2Vec2 point = originalPolygon->GetVertex(i);
        
        // you check if our point is not the same as our entry or exit point first
        b2Vec2 diffFromEntryPoint = point - sprite.entryPoint;
        b2Vec2 diffFromExitPoint = point - sprite.exitPoint;
        
        if ( (diffFromEntryPoint.x == 0 && diffFromEntryPoint.y == 0) || (diffFromExitPoint.x == 0 && diffFromExitPoint.y == 0) ) {
        }else {
            determinant = calculate_determinant_2x3(sprite.entryPoint.x, sprite.entryPoint.y, sprite.exitPoint.x, sprite.exitPoint.y, point.x, point.y);
            if (determinant > 0) {
                // if the determinant is positive, then the three points are in clockwise order
                sprite1Vertices[sprite1VerticesCount++] = point;
            } else {
                // if the determinant is 0, the points are on the same line.
                // if the determinant is negative, then the three points are in counter-clockwise order
                sprite2Vertices[sprite2VerticesCount++] = point;
            } // endif
        } // endif
    } // endFor

    // step3
    // Box2D needs vertices to be arrenged in counter-clockwise order so you reorder our points using custom function
    sprite1VerticesSorted = [self arrangeVertices:sprite1Vertices count:sprite1VerticesCount];
    sprite2VerticesSorted = [self arrangeVertices:sprite2Vertices count:sprite2VerticesCount];
    
    CCLOG(@"sprite1VerticesCount:%d sprite2VerticesCount:%d",sprite1VerticesCount, sprite2VerticesCount);
    for (int i=0; i<sprite1VerticesCount; i++) {
        //b2Vec2 b = sprite1VerticesSorted[i];
        CCLOG(@"sprite1VerticesSorted[%d] x:%f y:%F",i, sprite1VerticesSorted[i].x*PTM_RATIO, sprite1VerticesSorted[i].y*PTM_RATIO);
    }
    
    // step4
    // Box2D has some restrictions with difining shapes, so you have to consider these.
    // You only cut the shape if both shapes pass certain requirements from our function
    BOOL sprite1VerticesAcceptable = [self areVerticesAcceptable:sprite1VerticesSorted count:sprite1VerticesCount];
    BOOL sprite2VerticesAcceptable = [self areVerticesAcceptable:sprite2VerticesSorted count:sprite2VerticesCount];
    
    // step5
    // you destroy the old shape and create the new shapes and sprites
    if (sprite1VerticesAcceptable && sprite2VerticesAcceptable) {
        // create the first sprite's body
        b2Body *body1 = [self createBodyWithPosition:sprite.body->GetPosition() 
                                            rotation:sprite.body->GetAngle() 
                                            vertices:sprite1VerticesSorted
                                         vertexCount:sprite1VerticesCount
                                             density:originalFixture->GetDensity()
                                            friction:originalFixture->GetFriction()
                                         restitution:originalFixture->GetRestitution()];
        // create the first sprite
        newSprite1 = [PolygonSprite spriteWithTexture:sprite.texture body:body1 original:NO];
        [self addChild:newSprite1 z:1];
        
        // create the second sprite's body
        b2Body *body2 = [self createBodyWithPosition:sprite.body->GetPosition() 
                                            rotation:sprite.body->GetAngle() 
                                            vertices:sprite2VerticesSorted
                                         vertexCount:sprite2VerticesCount
                                             density:originalFixture->GetDensity()
                                            friction:originalFixture->GetFriction()
                                         restitution:originalFixture->GetRestitution()];
        // create the second sprite
        newSprite2 = [PolygonSprite spriteWithTexture:sprite.texture body:body2 original:NO];
        [self addChild:newSprite2 z:1];
        
        // you don't need the old shape & sprite anymore so you either destroy it or squirrel it away
        if (sprite.original) {
            [sprite deactivateCollisions];
            sprite.position = ccp(-256, -256);
            sprite.sliceEntered = NO;
            sprite.sliceExited = NO;
            sprite.entryPoint.SetZero();
            sprite.exitPoint.SetZero();
        } else {
            world->DestroyBody(sprite.body);
            [self removeChild:sprite cleanup:YES];
        }
    } else {
        sprite.sliceEntered = NO;
        sprite.sliceExited = NO;
    }
    
    // free up our allocated vectors
    free(sprite1VerticesSorted);
    free(sprite2VerticesSorted);
    free(sprite1Vertices);
    free(sprite2Vertices);
}

-(b2Body*)createBodyWithPosition:(b2Vec2)position rotation:(float)rotation vertices:(b2Vec2 *)vertices vertexCount:(int32)count density:(float)density friction:(float)friction restitution:(float)restitution
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = position;
    bodyDef.angle = rotation;
    b2Body *body = world->CreateBody(&bodyDef);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = density;
    fixtureDef.friction = friction;
    fixtureDef.restitution = restitution;
    
    b2PolygonShape shape;
    shape.Set(vertices, count);
    fixtureDef.shape = &shape;
    body->CreateFixture(&fixtureDef);
    
    return body;
}

-(b2Vec2*)arrangeVertices:(b2Vec2 *)vertices count:(int)count
{
    float determinant;
    int iCounterClockWise = 1;
    int iClockWise = count - 1;
    int i;
    
    b2Vec2 referencePointA,referencePointB;
    b2Vec2 *sortedVertices = (b2Vec2*)calloc(count, sizeof(b2Vec2));
    
    qsort(vertices, count, sizeof(b2Vec2), comparetor);
    
    sortedVertices[0] = vertices[0];
    referencePointA = vertices[0];
    referencePointB = vertices[count-1];
    
    for (i=1; i<count-1; i++) {
        determinant = calculate_determinant_2x3(referencePointA.x, referencePointA.y, referencePointB.x, referencePointB.y, vertices[i].x, vertices[i].y);
        if (determinant <0) {
            sortedVertices[iCounterClockWise++] = vertices[i];
        } else {
            sortedVertices[iClockWise--] = vertices[i];
        }
    }
    
    sortedVertices[iCounterClockWise] = vertices[count-1];
    return sortedVertices;
}

-(BOOL)areVerticesAcceptable:(b2Vec2 *)vertices count:(int)count
{
    return YES;
}

-(void)checkAndSliceObjects
{
    double curTime = CACurrentMediaTime();
    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()) {
        if (b->GetUserData() != NULL) {
            PolygonSprite *sprite = (PolygonSprite*)b->GetUserData();
            
            if (sprite.sliceEntered && curTime > sprite.sliceEntryTime) {
                sprite.sliceEntered = NO;
            }
            else if (sprite.sliceEntered && sprite.sliceExited)
            {
                [self splitPolygonSprite:sprite];
            }
        }
    }
}

-(void)clearSlices
{
    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()) {
        if (b->GetUserData() != NULL) {
            PolygonSprite *sprite = (PolygonSprite*)b->GetUserData();
            sprite.sliceEntered = NO;
            sprite.sliceExited = NO;
        }
    }
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

@end
