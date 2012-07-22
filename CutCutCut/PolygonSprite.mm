//
//  PolygonSprite.m
//  CutCutCut
//
//  Created by 光 渡邊 on 12/07/08.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "PolygonSprite.h"

@implementation PolygonSprite

@synthesize body = _body;
@synthesize original = _original;
@synthesize centroid = _centroid;

@synthesize entryPoint = _entryPoint;
@synthesize exitPoint = _exitPoint;
@synthesize sliceEntered = _sliceEntered;
@synthesize sliceExited = _sliceExited;
@synthesize sliceEntryTime = _sliceEntryTime;
@synthesize canGrab = _canGrab;
@synthesize area = _area;
@synthesize tag = _tag;

+(id)spriteWithFile:(NSString *)filename body:(b2Body *)body original:(BOOL)original
{
    return [[[self alloc] initWithFile:filename body:body original:original] autorelease];
}

+(id)spriteWithTexture:(CCTexture2D *)texture body:(b2Body *)body original:(BOOL)original
{
    return [[[self alloc] initWithTexture:texture body:body original:original] autorelease];
}

+(id)spriteWithWorld:(b2World *)world
{
    return [[[self alloc] initWithWorld:world] autorelease];
}

-(id)initWithFile:(NSString *)filename body:(b2Body *)body original:(BOOL)original
{
    NSAssert(filename != nil, @"Invalid filename for sprite");
    CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:filename];
    return [self initWithTexture:texture body:body original:original];
}

-(id)initWithTexture:(CCTexture2D *)texture body:(b2Body *)body original:(BOOL)original
{
    // gather all the vertices from our Box2D shape
    b2Fixture *originalFixture = body->GetFixtureList();
    b2PolygonShape *shape = (b2PolygonShape*)originalFixture->GetShape();
    int vertexCount = shape->GetVertexCount();
    NSMutableArray *points = [NSMutableArray arrayWithCapacity:vertexCount];
    for (int i = 0; i < vertexCount; i++) {
        CGPoint p = ccp(shape->GetVertex(i).x * PTM_RATIO, shape->GetVertex(i).y * PTM_RATIO);
        [points addObject:[NSValue valueWithCGPoint:p]];
    }
    
    _sliceExited = NO;
    _sliceEntered = NO;
    _entryPoint.SetZero();
    _exitPoint.SetZero();
    _sliceExited = 0;
    _canGrab = YES;
    
    if ((self = [super initWithPoints:points andTexture:texture]))
    {
        _body = body;
        _body->SetUserData(self);
        _original = original;
        // gets the center of the polygon
        _centroid = self.body->GetLocalCenter();
        
        self.anchorPoint = ccp(_centroid.x * PTM_RATIO / texture.contentSize.width, _centroid.y * PTM_RATIO / texture.contentSize.height);
        _area = [self culcArea];
        //CCLOG(@"area : %f", _area);
    }
    return self;
}

-(id)initWithWorld:(b2World *)world
{
    // nothing to do here
    return nil;
}

-(void)setPosition:(CGPoint)position
{
    [super setPosition:position];
    _body->SetTransform(b2Vec2(position.x/PTM_RATIO, position.y/PTM_RATIO), _body->GetAngle());
}

-(b2Body*)createBodyForWorld:(b2World *)world position:(b2Vec2)position rotation:(float)rotation vertices:(b2Vec2 *)vertices vertexCount:(int32)count density:(float)density friction:(float)friction restitution:(float)restitution
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = position;
    bodyDef.angle = rotation;
    bodyDef.linearDamping = 0.2;
    b2Body *body = world->CreateBody(&bodyDef);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = density;
    fixtureDef.friction = friction;
    fixtureDef.restitution = restitution;
    fixtureDef.filter.categoryBits = 0;
    fixtureDef.filter.maskBits = 0;
    
    b2PolygonShape shape;
    shape.Set(vertices, count);
    fixtureDef.shape = &shape;
    body->CreateFixture(&fixtureDef);
    
    return body;
}

-(void)activateCollisions
{
    b2Fixture *fixture = _body->GetFixtureList();
    b2Filter filter = fixture->GetFilterData();
    // カテゴリーbitはどこか1桁だけbitを立てておく方がよさそう
    // マスクは、各bitが意味するカテゴリと衝突させたいなら1で埋める
    // activeの場合は野菜と壁に衝突
    filter.categoryBits = 0x0004;   // 0100 
    filter.maskBits = 0x0007;       // 0111
    fixture->SetFilterData(filter);
}

-(void)deactivateCollisions
{
    b2Fixture *fixture = _body->GetFixtureList();
    b2Filter filter = fixture->GetFilterData();
    // ナベの壁には衝突させたい
    filter.categoryBits = 0x0004;   // 0100
    filter.maskBits = 0x0003;       // 0011
    fixture->SetFilterData(filter);
}

// returns the transform matrix according the Chipmunk Body values
-(CGAffineTransform) nodeToParentTransform
{	
	b2Vec2 pos  = _body->GetPosition();
	
	float x = pos.x * PTM_RATIO;
	float y = pos.y * PTM_RATIO;
	
	if ( ignoreAnchorPointForPosition_ ) {
		x += anchorPointInPoints_.x;
		y += anchorPointInPoints_.y;
	}
	
	// Make matrix
	float radians = _body->GetAngle();
	float c = cosf(radians);
	float s = sinf(radians);
	
	if( ! CGPointEqualToPoint(anchorPointInPoints_, CGPointZero) ){
		x += c*-anchorPointInPoints_.x + -s*-anchorPointInPoints_.y;
		y += s*-anchorPointInPoints_.x + c*-anchorPointInPoints_.y;
	}   
	
	// Rot, Translate Matrix
	transform_ = CGAffineTransformMake( c,  s,
									   -s,	c,
									   x,	y );	
	
	return transform_;
}

-(b2MouseJoint*)testPointWithLocation:(b2Vec2)location groundBody:(b2Body *)groundBody world:(b2World *)world
{
    if (!_canGrab) {
        return nil;
    }
    for (b2Fixture* f = _body->GetFixtureList(); f;f = f->GetNext()) {
        // 1回しかループしない想定...
        //CCLOG(@"location.x:%f location.y:%f", location.x, location.y);
        if (f->TestPoint(location)) {
            //CCLOG(@"testPoint");
            b2MouseJointDef md;
            md.bodyA = groundBody;
            md.bodyB = _body;
            md.target = location;
            md.collideConnected = true;
            md.maxForce = 1000.0f * _body->GetMass();
            _body->SetAwake(true);
            return (b2MouseJoint *)world->CreateJoint(&md);
        }
    }
    return nil;
}

-(float32)culcArea
{
    b2Fixture *originalFixture = _body->GetFixtureList();
    b2PolygonShape *originalPolygon = (b2PolygonShape*)originalFixture->GetShape();
    int count = originalPolygon->GetVertexCount();
    
    b2Vec2 *vertices = (b2Vec2*)calloc(24, sizeof(b2Vec2));
//    vertices[sprite1VerticesCount++] = sprite.entryPoint;
    
    
    float32 area = 0.0f;
    int i;
    b2Vec2 pRef(0.0f,0.0f);
    for (i=0; i<count; ++i)
    {
        
        b2Vec2 p1 = pRef;
        b2Vec2 p2 = originalPolygon->GetVertex(i);
        b2Vec2 p3 = i + 1 < count ? originalPolygon->GetVertex(i+1) : originalPolygon->GetVertex(0);
        
        b2Vec2 e1 = p2 - p1;
        b2Vec2 e2 = p3 - p1;
        
        float32 D = b2Cross(e1, e2);
        
        float32 triangleArea = 0.5f * D;
        area += triangleArea;
    }
    return area;
}

@end
