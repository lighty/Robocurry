//
//  GameLayer.mm
//  CutCutCut
//
//  Created by 光 渡邊 on 12/07/08.
//  Copyright __MyCompanyName__ 2012年. All rights reserved.
//

#import "Ninjin.h"
#import "Potato_m.h"
#import "Potato_d.h"
#import "Onion.h"
#import "Roo.h"
#import "Nasu.h"
#import "Paprika_r.h"
#import "Paprika_y.h"
#import "Pork.h"
#import "Ika.h"

#import "Nabe.h"
// Import the interfaces
#import "GameLayer.h"
#import "DekiagaLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "CCAnimationHelper.h"

#pragma mark - GameLayer

@interface GameLayer()
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

@implementation GameLayer

@synthesize nabeContents = _nabeContents;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
        
        _canSliceObject = YES;
        _canTouch = YES;
        _mouseJoints = CFDictionaryCreateMutable(NULL, 5, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        _startPoints = CFDictionaryCreateMutable(NULL, 5, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        _endPoints = CFDictionaryCreateMutable(NULL, 5, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        
		[self initPhysics];
		
        [self initSprites];
        [self initRobo];
        _rayCastCallback = new RayCastCallback();
        
        [self initSounds];
        
		[self scheduleUpdate];

        [self initBackground];

        _nextPushTime = CACurrentMediaTime() + 1;
        
        [self initNabe];
        
        [self initScene];
        
	}
	return self;
}
-(void)initBackground
{
    CGSize screen = [[CCDirector sharedDirector] winSize];
    CCSprite *background = [CCSprite spriteWithFile:@"bg1.png"];
    background.position = ccp(screen.width/2 + 1,screen.height/2 + 1);
    [self addChild:background z:-1];
}

-(void)initSounds
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"se_waterdrop" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((CFURLRef)url, &waterDropSoundID);

    path = [[NSBundle mainBundle] pathForResource:@"se_fire" ofType:@"mp3"];
    url = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((CFURLRef)url, &fireSoundID);

    path = [[NSBundle mainBundle] pathForResource:@"se_cut" ofType:@"mp3"];
    url = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((CFURLRef)url, &cutSoundID);

    path = [[NSBundle mainBundle] pathForResource:@"se_te" ofType:@"mp3"];
    url = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((CFURLRef)url, &teSoundID);
    
    path = [[NSBundle mainBundle] pathForResource:@"se_kachi" ofType:@"mp3"];
    url = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((CFURLRef)url, &kachiSoundID);
    
}


-(void)initNabe
{
    // ナベの内容物
    _nabeContents = [[NSMutableDictionary alloc]init];
    [_nabeContents setObject:[NSNumber numberWithFloat:0] forKey:[Roo class]];
    
    CGSize screen = [[CCDirector sharedDirector] winSize];
    CCSprite *nabe = [CCSprite spriteWithFile:@"nabe0.png"];
    nabe.position = ccp((screen.width/2), nabe.texture.contentSize.height/2);
    // ナベのタグをどっかに定義したい
    [self addChild:nabe z:Z_NABE tag:kTagNabe];
    
    CCSprite *nabe_front = [CCSprite spriteWithFile:@"nabe_front0.png"];
    nabe_front.position = ccp((screen.width/2), nabe_front.texture.contentSize.height/2);
    [self addChild:nabe_front z:Z_NABE_FRONT tag:kTagNabeFront];
    
    // 水の部分
    CCSprite *water_front = [CCSprite spriteWithFile:@"water_front.png"];
    water_front.position = ccp((screen.width/2), nabe_front.texture.contentSize.height/2 + 14);
    [self addChild:water_front z:Z_NABE_WATER_FRONT tag:kTagNabeWaterFront];
    CCSprite *water_back = [CCSprite spriteWithFile:@"water_back.png"];
    water_back.position = ccp((screen.width/2), nabe_front.texture.contentSize.height/2 + 14);
    [self addChild:water_back z:Z_NABE_WATER_BACK tag:kTagNabeWaterBack];
    

    // Define the ground body.
	b2BodyDef nabeBodyDef;
	nabeBodyDef.position.Set((screen.width/2-nabe.texture.contentSize.width/2)/PTM_RATIO, 8/PTM_RATIO);
    b2Body* nabeBody;
	nabeBody = world->CreateBody(&nabeBodyDef);
    nabeBody->SetUserData(@"nabe_body");
   	b2EdgeShape groundBox;	
    {
        groundBox.Set(b2Vec2(30.0/PTM_RATIO,100.0/PTM_RATIO), b2Vec2(33.0/PTM_RATIO,-5.0/PTM_RATIO));
		nabeBody->CreateFixture(&groundBox,0);
    }
    {
        // bottomはぶつかると野菜がbodyを失うので、ナベのtopからの参入以外では触れられないように間隔を空けておく
        groundBox.Set(b2Vec2(34.0/PTM_RATIO,0.0/PTM_RATIO), b2Vec2(221.0/PTM_RATIO,0.0/PTM_RATIO));
		b2Fixture *nabeBottomFixture = nabeBody->CreateFixture(&groundBox,0);
		nabeBottomFixture->SetUserData(@"nabe_bottom_fixture");
    }
    {
        groundBox.Set(b2Vec2(222.0/PTM_RATIO,-5.0/PTM_RATIO), b2Vec2(225.0/PTM_RATIO,100.0/PTM_RATIO));
		nabeBody->CreateFixture(&groundBox,0);
    }
    // top
    b2Body* nabeTopBody;
    nabeTopBody = world->CreateBody(&nabeBodyDef);
    groundBox.Set(b2Vec2(44.0/PTM_RATIO,93.0/PTM_RATIO), b2Vec2(203.0/PTM_RATIO,93.0/PTM_RATIO));
    b2Fixture *sensorFixture = nabeTopBody->CreateFixture(&groundBox,0);
    nabeTopBody->SetUserData(@"nabe_top");
    //sensorFixture->SetUserData(@"nabe_top");
    //sensorFixture->SetSensor(true); // sensor cannot get contact point
    b2Filter filter = sensorFixture->GetFilterData();
    // 水のセンサーは2桁目のbitを立てる
    filter.categoryBits = 0x0002;   // 0010
    filter.maskBits = 0x0007;       // 0111
    sensorFixture->SetFilterData(filter);
    
    // 水に野菜が入ったときに沈み込むエフェクトをかけるための判定用のbody
    //b2Body* nabeTopBody;
    
    
    
    // 発射ボタン
    CCSprite *button = [CCSprite spriteWithFile:@"switch_disabled.png"];
    button.position = ccp((screen.width-32), screen.height-96);
    [self addChild:button z:Z_SWITCH tag:kTagButton];
    _fireButtonEnabled = NO;
    _fireButtonPushing = NO;

}

-(void)blinkingButton:(ccTime *)timer
{
    CCAnimation* animation = [CCAnimation animationWithFile:@"switch" frameCount:2 delay:0.2f];
    id anim = [CCAnimate actionWithAnimation:animation];
    id act = [CCSequence actions:anim, nil];
    id repeat_act = [CCRepeatForever actionWithAction:act];
    CCSprite* sprite = [self getChildByTag:kTagButton];
    //CCLOG(@"animation.frames:%d",animation.frames.count);
    CCSprite *button_blink = [CCSprite spriteWithSpriteFrame:[[animation.frames objectAtIndex:0] spriteFrame]];
    button_blink.position = sprite.position;
    
    [button_blink runAction:repeat_act];
    [self removeChild:sprite cleanup:YES];
    // ナベのタグをどっかに定義したい
    [self addChild:button_blink z:Z_SWITCH tag:kTagButton];
    _fireButtonEnabled = YES;
}

-(void) initScene
{
    CGSize size = [[CCDirector sharedDirector] winSize];

    CCMenuItem *returnItem = [CCMenuItemImage itemWithNormalImage:@"modoru.png" selectedImage:@"modoru_selected.png" target:self selector:@selector(onReturn:)];
    CCMenu *menu = [CCMenu menuWithItems:returnItem, nil];
    menu.position = ccp(returnItem.boundingBox.size.width /2 , size.height - returnItem.boundingBox.size.height / 2);
    [self addChild:menu z:Z_MODORU];
}

-(void) onReturn:(id)item
{
    AudioServicesPlaySystemSound(teSoundID);
    [[CCDirector sharedDirector] popScene];
}

-(void)initSprites
{
    // 野菜作成の準備
    NSMutableDictionary *vegeDefine = [NSMutableDictionary dictionary];
    [vegeDefine setObject:[NSNumber numberWithInt:5] forKey:[Ninjin class]];
    [vegeDefine setObject:[NSNumber numberWithInt:1] forKey:[Potato_d class]];
    [vegeDefine setObject:[NSNumber numberWithInt:5] forKey:[Potato_m class]];
    [vegeDefine setObject:[NSNumber numberWithInt:5] forKey:[Onion class]];
    [vegeDefine setObject:[NSNumber numberWithInt:15] forKey:[Roo class]];
    [vegeDefine setObject:[NSNumber numberWithInt:5] forKey:[Nasu class]];
    [vegeDefine setObject:[NSNumber numberWithInt:5] forKey:[Paprika_r class]];
    [vegeDefine setObject:[NSNumber numberWithInt:5] forKey:[Paprika_y class]];
    [vegeDefine setObject:[NSNumber numberWithInt:5] forKey:[Ika class]];
    [vegeDefine setObject:[NSNumber numberWithInt:5] forKey:[Pork class]];
    NSArray *vegeDefineKeys = [vegeDefine allKeys];
    _vegeArray = [[NSMutableArray alloc]init];
    int vegeDefineCount = [vegeDefineKeys count];
    id clazz = NULL;
    int keisu;
    for (int i = 0; i < vegeDefineCount; i++) {
        clazz = [vegeDefineKeys objectAtIndex:i];
        NSNumber *num = (NSNumber*)[vegeDefine objectForKey:clazz];
        keisu = [num intValue];
        // keisu回分オブジェクトを作成
        for (int j=0; j < keisu; j++) {
            [_vegeArray addObject:clazz];
        }
    }
    //[self createVegetableRandom:NULL];
    _createVegeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 // 時間間隔(秒)
                                     target:self //呼び出すオブジェクト
                                   selector:@selector(createVegetableRandom:)
                                   userInfo:nil
                                    repeats:NO];
    _tmPushCount = 0;
}

-(void)createVegetableRandom:(ccTime)timer
{
    CGSize screen = [[CCDirector sharedDirector]winSize];
    // ランダムで作成するものを決める
    id clazz = [_vegeArray objectAtIndex:random_range(0, [_vegeArray count]-1)];
    // Just create one sprite for now. This whole method will be replaced later.
    PolygonSprite *sprite = [[clazz alloc] initWithWorld:world];
    [self addChild:sprite z:Z_VEGE];
    [sprite activateCollisions];
    
    // ランダムで作成する場所を決める
    switch (random_range(0, 3)) {
        case 0:
            sprite.position = ccp(-256,screen.height/2);
            sprite.body->ApplyLinearImpulse(b2Vec2(100,0), b2Vec2(sprite.body->GetPosition()));
            break;
        case 1:
            sprite.position = ccp(screen.width,screen.height/2);
            sprite.body->ApplyLinearImpulse(b2Vec2(-100,0), b2Vec2(sprite.body->GetPosition()));
            break;
        case 2:
            sprite.position = ccp(screen.width/3,screen.height);
            sprite.body->ApplyLinearImpulse(b2Vec2(0,-100), b2Vec2(sprite.body->GetPosition()));
            break;
        case 3:
            sprite.position = ccp(screen.width/3*2,screen.height);
            sprite.body->ApplyLinearImpulse(b2Vec2(0,-100), b2Vec2(sprite.body->GetPosition()));
            break;
            
        default:
            break;
    }
    

    // ランダムで作成する時間を決める
    if (_createVegeTimer != nil) {
        _createVegeTimer = [NSTimer scheduledTimerWithTimeInterval:frandom_range(2.0, 4.0) // 時間間隔(秒)
                                                            target:self //呼び出すオブジェクト
                                                          selector:@selector(createVegetableRandom:)
                                                          userInfo:nil
                                                           repeats:NO];
    }
     _tmPushCount++;
}

-(void) dealloc
{
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
	
//    [_cache release];
//    _cache = nil;

    delete _contactListener;
	[super dealloc];
    
    _vegeArray = nil;
    _nabeContents = nil;
    _roboLimbs = nil;
    _roboLimbJoints = nil;
    
}	

-(void) initRobo
{
    
//    CCSprite *ikasprite = [CCSprite spriteWithFile:@"ika.png"];
//    [self addChild:ikasprite z:Z_ROBO tag:kTagRobo];
//    ikasprite.position = ccp(200,200);
    
    // ロボワールドの初期化
	b2Vec2 gravity;
	gravity.Set(0.0f, 0.0f);
	_roboWorld = new b2World(gravity);
	_roboWorld->SetAllowSleeping(true);
	_roboWorld->SetContinuousPhysics(true);
	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	//_roboWorld->SetDebugDraw(m_debugDraw);
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
    flags += b2Draw::e_jointBit;
    flags += b2Draw::e_aabbBit;
    flags += b2Draw::e_pairBit;
    flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);		
    
    // 加速度センサーの初期化
    UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
    accelerometer.updateInterval = 0.02;
    accelerometer.delegate = self;
    
    _roboLimbs = [[NSMutableArray alloc] init];
    _roboLimbJoints = [[NSMutableArray alloc] init];
    
    //ロボ本体
    CGSize screen = [[CCDirector sharedDirector] winSize];
    b2Body* roboBody;
    {
        CCSprite *sprite = [CCSprite spriteWithFile:@"robot.png"];
        [self addChild:sprite z:Z_ROBO tag:kTagRobo];
        sprite.position = ccp(screen.width - sprite.boundingBox.size.width/2, screen.height - sprite.boundingBox.size.height/2);
        
        b2BodyDef roboBodyDef;
        roboBodyDef.type = b2_staticBody;
        roboBodyDef.position = b2Vec2(sprite.position.x / PTM_RATIO, sprite.position.y / PTM_RATIO);
        roboBodyDef.userData = sprite;
        roboBody = _roboWorld->CreateBody(&roboBodyDef);

        b2PolygonShape roboShape;
        roboShape.SetAsBox(64 / PTM_RATIO * 0.5f, 64 / PTM_RATIO * 0.5f);
        b2FixtureDef roboFixtureDef;
        roboFixtureDef.density = 1;
        roboFixtureDef.filter.categoryBits = 0;
        roboFixtureDef.filter.maskBits = 0;
        roboFixtureDef.shape = &roboShape;
        roboBody->CreateFixture( &roboFixtureDef );
    }
    
    // ロボ右足
    {
        CCSprite *sprite = [CCSprite spriteWithFile:@"robo_leg.png"];
        [self addChild:sprite z:Z_ROBO_LEG tag:kTagRoboLegR];
        [_roboLimbs addObject:sprite];
        sprite.position = ccp(screen.width - sprite.boundingBox.size.width/2 -16, screen.height - sprite.boundingBox.size.height/2 -48);
        b2BodyDef legBodyDef;
        legBodyDef.type = b2_dynamicBody;
        legBodyDef.position = b2Vec2(sprite.position.x / PTM_RATIO, sprite.position.y / PTM_RATIO);
        legBodyDef.userData = sprite;
        b2Body* legBody = _roboWorld->CreateBody(&legBodyDef);
        
        b2PolygonShape legShape;
        legShape.SetAsBox(32.0 / PTM_RATIO * 0.5f, 32.0 / PTM_RATIO * 0.5f);
        b2FixtureDef legFixtureDef;
        legFixtureDef.density = 10;
        legFixtureDef.filter.categoryBits = 0x0010;   // 1000 
        legFixtureDef.filter.maskBits = 0x0007;       // 0100 野菜とだけぶつかる
        legFixtureDef.shape = &legShape;
        legBody->CreateFixture( &legFixtureDef );
        
        b2RevoluteJointDef revoluteJointDef;
        revoluteJointDef.bodyA = roboBody;
        revoluteJointDef.bodyB = legBody;
        revoluteJointDef.collideConnected = false;
        revoluteJointDef.localAnchorA.Set(16.0 / PTM_RATIO * 0.5f, -32.0 / PTM_RATIO * 0.5f);//the top right corner of the box
        revoluteJointDef.localAnchorB.Set(0, 8.0 / PTM_RATIO);
        [_roboLimbJoints addObject:[NSValue valueWithPointer:(b2RevoluteJoint*)_roboWorld->CreateJoint( &revoluteJointDef )]];
        
        //legBody->ApplyForce(b2Vec2(1000,0), b2Vec2(legBody->GetPosition()));
    }
    
    // ロボ左足
    {
        CCSprite *sprite = [CCSprite spriteWithFile:@"robo_leg.png"];
        [self addChild:sprite z:Z_ROBO_LEG tag:kTagRoboLegL];
        [_roboLimbs addObject:sprite];
        sprite.position = ccp(screen.width - sprite.boundingBox.size.width/2 -31, screen.height - sprite.boundingBox.size.height/2 -48);
        b2BodyDef legBodyDef;
        legBodyDef.type = b2_dynamicBody;
        legBodyDef.position = b2Vec2(sprite.position.x / PTM_RATIO, sprite.position.y / PTM_RATIO);
        legBodyDef.userData = sprite;
        b2Body* legBody = _roboWorld->CreateBody(&legBodyDef);
        
        b2PolygonShape legShape;
        legShape.SetAsBox(32 / PTM_RATIO * 0.5f, 32 / PTM_RATIO * 0.5f);
        b2FixtureDef legFixtureDef;
        legFixtureDef.density = 10;
        legFixtureDef.filter.categoryBits = 0x0010;   // 1000 
        legFixtureDef.filter.maskBits = 0x0007;       // 0100 野菜とだけぶつかる
        legFixtureDef.shape = &legShape;
        legBody->CreateFixture( &legFixtureDef );
        
        b2RevoluteJointDef revoluteJointDef;
        revoluteJointDef.bodyA = roboBody;
        revoluteJointDef.bodyB = legBody;
        revoluteJointDef.collideConnected = false;
        revoluteJointDef.localAnchorA.Set(-16.0 / PTM_RATIO * 0.5f, -32.0 / PTM_RATIO * 0.5f);//the top right corner of the box
        revoluteJointDef.localAnchorB.Set(0, 8.0 / PTM_RATIO);//center of the circle
        (b2RevoluteJoint*)_roboWorld->CreateJoint( &revoluteJointDef );
    }
    
    // ロボ右アーム2
    b2Body* arm2Rbody;
    {
        CCSprite *sprite = [CCSprite spriteWithFile:@"robo_arm2.png"];
        [self addChild:sprite z:Z_ROBO_ARM2 tag:kTagRoboArm2R];
        [_roboLimbs addObject:sprite];
        sprite.position = ccp(screen.width - sprite.boundingBox.size.width/2 -16, screen.height - sprite.boundingBox.size.height/2 -18);
        b2BodyDef arm2BodyDef;
        arm2BodyDef.type = b2_dynamicBody;
        arm2BodyDef.position = b2Vec2(sprite.position.x / PTM_RATIO, sprite.position.y / PTM_RATIO);
        arm2BodyDef.userData = sprite;
        arm2Rbody = _roboWorld->CreateBody(&arm2BodyDef);
        
        b2PolygonShape arm2Shape;
        arm2Shape.SetAsBox(8.0 / PTM_RATIO * 0.5f, 32.0 / PTM_RATIO * 0.5f);
        b2FixtureDef arm2FixtureDef;
        arm2FixtureDef.density = 10;
        arm2FixtureDef.filter.categoryBits = 0x0010;   // 1000 
        arm2FixtureDef.filter.maskBits = 0x0007;       // 0100 野菜とだけぶつかる
        arm2FixtureDef.shape = &arm2Shape;
        arm2Rbody->CreateFixture( &arm2FixtureDef );
        
        b2RevoluteJointDef revoluteJointDef;
        revoluteJointDef.bodyA = roboBody;
        revoluteJointDef.bodyB = arm2Rbody;
        revoluteJointDef.collideConnected = false;
        revoluteJointDef.localAnchorA.Set(21.0 / PTM_RATIO * 0.5f, 12.0 / PTM_RATIO * 0.5f);//the top right corner of the box
        revoluteJointDef.localAnchorB.Set(0, 16.0 / PTM_RATIO);
        //[_roboLimbJoints addObject:[NSValue valueWithPointer:(b2RevoluteJoint*)_roboWorld->CreateJoint( &revoluteJointDef )]];
        _roboWorld->CreateJoint( &revoluteJointDef );
    }
    
    // ロボ右アーム1
    b2Body* arm1Rbody;
    {
        CCSprite *sprite = [CCSprite spriteWithFile:@"robo_arm1.png"];
        [self addChild:sprite z:Z_ROBO_ARM1 tag:kTagRoboArm1R];
        [_roboLimbs addObject:sprite];
        sprite.position = ccp(screen.width - sprite.boundingBox.size.width/2 -16, screen.height - sprite.boundingBox.size.height/2 -18);
        b2BodyDef arm1BodyDef;
        arm1BodyDef.type = b2_dynamicBody;
        arm1BodyDef.position = b2Vec2(sprite.position.x / PTM_RATIO, sprite.position.y / PTM_RATIO);
        arm1BodyDef.userData = sprite;
        arm1Rbody = _roboWorld->CreateBody(&arm1BodyDef);
        
        b2PolygonShape arm1Shape;
        arm1Shape.SetAsBox(8.0 / PTM_RATIO * 0.5f, 32.0 / PTM_RATIO * 0.5f);
        b2FixtureDef arm1FixtureDef;
        arm1FixtureDef.density = 10;
        arm1FixtureDef.filter.categoryBits = 0x0010;   // 1000 
        arm1FixtureDef.filter.maskBits = 0x0007;       // 0100 野菜とだけぶつかる
        arm1FixtureDef.shape = &arm1Shape;
        arm1Rbody->CreateFixture( &arm1FixtureDef );
        
        b2RevoluteJointDef revoluteJointDef;
        revoluteJointDef.bodyA = arm2Rbody;
        revoluteJointDef.bodyB = arm1Rbody;
        revoluteJointDef.collideConnected = false;
        revoluteJointDef.localAnchorA.Set(0, 0);//the top right corner of the box
        revoluteJointDef.localAnchorB.Set(0, 15.0 / PTM_RATIO);
        _roboWorld->CreateJoint( &revoluteJointDef );
    }
    
    // ロボ左アーム2
    b2Body* arm2Lbody;
    {
        CCSprite *sprite = [CCSprite spriteWithFile:@"robo_arm2.png"];
        [self addChild:sprite z:Z_ROBO_ARM2 tag:kTagRoboArm2R];
        [_roboLimbs addObject:sprite];
        sprite.position = ccp(screen.width - sprite.boundingBox.size.width/2 -31, screen.height - sprite.boundingBox.size.height/2 -18);
        b2BodyDef arm2BodyDef;
        arm2BodyDef.type = b2_dynamicBody;
        arm2BodyDef.position = b2Vec2(sprite.position.x / PTM_RATIO, sprite.position.y / PTM_RATIO);
        arm2BodyDef.userData = sprite;
        arm2Lbody = _roboWorld->CreateBody(&arm2BodyDef);
        
        b2PolygonShape arm2Shape;
        arm2Shape.SetAsBox(8.0 / PTM_RATIO * 0.5f, 32.0 / PTM_RATIO * 0.5f);
        b2FixtureDef arm2FixtureDef;
        arm2FixtureDef.density = 10;
        arm2FixtureDef.filter.categoryBits = 0x0010;   // 1000 
        arm2FixtureDef.filter.maskBits = 0x0007;       // 0100 野菜とだけぶつかる
        arm2FixtureDef.shape = &arm2Shape;
        arm2Lbody->CreateFixture( &arm2FixtureDef );
        
        b2RevoluteJointDef revoluteJointDef;
        revoluteJointDef.bodyA = roboBody;
        revoluteJointDef.bodyB = arm2Lbody;
        revoluteJointDef.collideConnected = false;
        revoluteJointDef.localAnchorA.Set(-21.0 / PTM_RATIO * 0.5f, 12.0 / PTM_RATIO * 0.5f);//the top right corner of the box
        revoluteJointDef.localAnchorB.Set(0, 16.0 / PTM_RATIO);
        //[_roboLimbJoints addObject:[NSValue valueWithPointer:(b2RevoluteJoint*)_roboWorld->CreateJoint( &revoluteJointDef )]];
        _roboWorld->CreateJoint( &revoluteJointDef );
    }
    
    // ロボ左アーム1
    b2Body* arm1Lbody;
    {
        CCSprite *sprite = [CCSprite spriteWithFile:@"robo_arm1.png"];
        [self addChild:sprite z:Z_ROBO_ARM1 tag:kTagRoboArm2L];
        [_roboLimbs addObject:sprite];
        sprite.position = ccp(screen.width - sprite.boundingBox.size.width/2 -31, screen.height - sprite.boundingBox.size.height/2 -18);
        b2BodyDef arm1BodyDef;
        arm1BodyDef.type = b2_dynamicBody;
        arm1BodyDef.position = b2Vec2(sprite.position.x / PTM_RATIO, sprite.position.y / PTM_RATIO);
        arm1BodyDef.userData = sprite;
        arm1Lbody = _roboWorld->CreateBody(&arm1BodyDef);
        
        b2PolygonShape arm1Shape;
        arm1Shape.SetAsBox(8.0 / PTM_RATIO * 0.5f, 32.0 / PTM_RATIO * 0.5f);
        b2FixtureDef arm1FixtureDef;
        arm1FixtureDef.density = 10;
        arm1FixtureDef.filter.categoryBits = 0x0010;   // 1000 
        arm1FixtureDef.filter.maskBits = 0x0007;       // 0100 野菜とだけぶつかる
        arm1FixtureDef.shape = &arm1Shape;
        arm1Lbody->CreateFixture( &arm1FixtureDef );
        
        b2RevoluteJointDef revoluteJointDef;
        revoluteJointDef.bodyA = arm2Lbody;
        revoluteJointDef.bodyB = arm1Lbody;
        revoluteJointDef.collideConnected = false;
        revoluteJointDef.localAnchorA.Set(0, 0);//the top right corner of the box
        revoluteJointDef.localAnchorB.Set(0, 15.0 / PTM_RATIO);
        _roboWorld->CreateJoint( &revoluteJointDef );
    }
    
   
    
}

-(void) initPhysics
{
	
	b2Vec2 gravity;
	//gravity.Set(0.0f, -10.0f);
	gravity.Set(0.0f, 0.0f);
	world = new b2World(gravity);
	
	
	// Do we want to let bodies sleep?
	world->SetAllowSleeping(true);
	
	world->SetContinuousPhysics(true);
	
	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	//world->SetDebugDraw(m_debugDraw);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
			flags += b2Draw::e_jointBit;
			flags += b2Draw::e_aabbBit;
			flags += b2Draw::e_pairBit;
			flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);		
	
	
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	groundBody = world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
//	b2EdgeShape groundBox;		
	
	// bottom
	
//	groundBox.Set(b2Vec2(0,0), b2Vec2(s.width/PTM_RATIO,0));
//	groundBody->CreateFixture(&groundBox,0);
//	
//	// top
//	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO));
//	groundBody->CreateFixture(&groundBox,0);
//	
//	// left
//	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(0,0));
//	groundBody->CreateFixture(&groundBox,0);
//	
//	// right
//	groundBox.Set(b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,0));
//	groundBody->CreateFixture(&groundBox,0);
    
    // ナベの衝突判定
    _contactListener = new ContactListener();
    _contactListener->SetNode(self);
    world->SetContactListener(_contactListener);
    
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
    
    //ccDrawLine(_startPoint, _endPoint);
//	
	world->DrawDebugData();	
    _roboWorld->DrawDebugData();
	
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
	_roboWorld->Step(dt, velocityIterations, positionIterations);	
    [self checkAndSliceObjects];    
    
    // ロボの動き
    for (b2Body* body = _roboWorld->GetBodyList(); body != nil; body = body->GetNext()) {
        CCSprite* sprite = (CCSprite*)body->GetUserData();         
        if([_roboLimbs containsObject:sprite]){
            // 位置と傾きを変更 
            b2Vec2 vec = body->GetPosition();
            sprite.position = ccpMult(CGPointMake(vec.x, vec.y), PTM_RATIO);
            float angle = body->GetAngle();
            sprite.rotation = CC_RADIANS_TO_DEGREES(-angle);
        }
    }
    b2RevoluteJoint* revoluteJoint;
//    for (NSValue* value in _roboLimbJoints) {
//        revoluteJoint = (b2RevoluteJoint*)[value pointerValue];
//        CCLOG(@"%f",revoluteJoint->GetJointSpeed());
//        revoluteJoint->SetMotorSpeed(revoluteJoint->GetJointSpeed()-1);
//    }
        
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration *)acceleration{
    accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
    accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
    prevX = accelX;
    prevY = accelY;
    // accelerometer values are in "Portrait" mode. Change them to Landscape left
    // multiply the gravity by 10
    b2Vec2 gravity( -accelY * 10, accelX * 10);
    _roboWorld->SetGravity( gravity );
    
//    for (b2Body* body = _roboWorld->GetBodyList(); body != nil; body = body->GetNext()) {
//        CCSprite* sprite = (CCSprite*)body->GetUserData();         
//        if([_roboLimbs containsObject:sprite]){
//            body->ApplyForce(b2Vec2(acceleration.x,acceleration.y), b2Vec2(0, 8.0 / PTM_RATIO));
//        }
//    }
}


-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //CCLOG(@"touch! count:%d", [touches count]);
    if (!_canTouch) {
        return;
    }
    for(UITouch *touch in touches){
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector]convertToGL:location];
        CFDictionarySetValue(_startPoints, touch, [NSValue valueWithCGPoint:location]);
        CFDictionarySetValue(_endPoints, touch, [NSValue valueWithCGPoint:location]);

        // 発射ボタンの押下判定
        {
            CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
            CCNode* sprite = [self getChildByTag:kTagButton];
            if(CGRectContainsPoint(sprite.boundingBox, touchLocation) && _fireButtonEnabled){
                // ボタン押下でpushed画像に変更
                CCSprite *button_pushed = [CCSprite spriteWithFile:@"switch1_pushed.png"];
                button_pushed.position = sprite.position;
                [self addChild:button_pushed z:Z_SWITCH tag:kTagButton];
                [self removeChild:sprite cleanup:YES];
                _fireButtonPushing = YES;
                break;
            }
        }
        
        CCNode* node;
        b2MouseJoint *mouseJoint;
        CCARRAY_FOREACH([self children], node){
            if ([node isKindOfClass:[PolygonSprite class]]) {
                //CCLOG(@"startTest:%p",_mouseJoint);
                mouseJoint = [(PolygonSprite*)node testPointWithLocation:b2Vec2(location.x / PTM_RATIO, location.y / PTM_RATIO) 
                                                 groundBody:groundBody 
                                                      world:world];
                CFDictionarySetValue(_mouseJoints, touch, [NSValue valueWithPointer:mouseJoint]);
                if(mouseJoint){
                    break;
                }
                //CCLOG(@"endTest:%p", _mouseJoint);
            }
        }
    }
    
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    b2MouseJoint *mouseJoint;
    CGPoint startPoint;
    CGPoint endPoint;
    for(UITouch *touch in touches){
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector]convertToGL:location];
        //_endPoint = location;
        CFDictionarySetValue(_endPoints, touch, [NSValue valueWithCGPoint:location]);
        
        NSValue *startPointValue = (id)CFDictionaryGetValue(_startPoints, touch);
        startPoint = [startPointValue CGPointValue];
        NSValue *endPointValue = (id)CFDictionaryGetValue(_endPoints, touch);
        endPoint = [endPointValue CGPointValue];
        
        
        NSValue *mouseJointValue = (id)CFDictionaryGetValue(_mouseJoints, touch);
        mouseJoint = (b2MouseJoint *)[mouseJointValue pointerValue];
        if (mouseJoint) {
            mouseJoint->SetTarget(b2Vec2(location.x/PTM_RATIO,location.y/PTM_RATIO));
        }
        
        // movingForce(1フレームで動いた距離) が10000を超えるようならマルチタッチと仮定してRaycastを無視する
        float movingForce = ccpLengthSQ(ccpSub(startPoint, endPoint));
        if (10000 > movingForce && movingForce > 25 && !mouseJoint) {
            //CCLOG(@"RayCast!");
            world->RayCast(_rayCastCallback, 
                           b2Vec2(startPoint.x / PTM_RATIO, startPoint.y / PTM_RATIO),
                           b2Vec2(endPoint.x / PTM_RATIO, endPoint.y / PTM_RATIO));
            world->RayCast(_rayCastCallback, 
                           b2Vec2(endPoint.x / PTM_RATIO, endPoint.y / PTM_RATIO),
                           b2Vec2(startPoint.x / PTM_RATIO, startPoint.y / PTM_RATIO));
            CFDictionarySetValue(_startPoints, touch, [NSValue valueWithCGPoint:endPoint]);
            //startPoint = endPoint;
            
        }
    }
    
}

-(void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    b2MouseJoint *mouseJoint;
    for(UITouch *touch in touches){
        NSValue *touchValue = (id)CFDictionaryGetValue(_mouseJoints, touch);
        mouseJoint = (b2MouseJoint *)[touchValue pointerValue];
        if (mouseJoint) {
            world->DestroyJoint(mouseJoint);
            CFDictionaryRemoveValue(_mouseJoints, touch);
        }
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_canTouch) {
        return;
    }
    b2MouseJoint *mouseJoint;
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];

        // 発射ボタンの判定（リファクタリングしたい）
        {
            CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
            CCNode* sprite = [self getChildByTag:kTagButton];
            if(_fireButtonPushing){
                if(CGRectContainsPoint(sprite.boundingBox, touchLocation)){
                    // ##### 発射処理 #####
                    AudioServicesPlaySystemSound(kachiSoundID);
                    // ボタン押下で普通のボタン画像に変更
                    CCSprite *button = [CCSprite spriteWithFile:@"switch1.png"];
                    button.position = sprite.position;
                    [self addChild:button z:Z_SWITCH+1 tag:kTagButton];
                    [self removeChild:sprite cleanup:YES];
                    [self theWorld];
                    break;
                }else{
                    // ##### ボタン押したけどズラして押さないことにしたい場合 #####
                    _fireButtonPushing = NO;
                    [self blinkingButton:nil];
                }
            }
        }
        // タッチ移動の解除
        NSValue *touchValue = (id)CFDictionaryGetValue(_mouseJoints, touch);
        mouseJoint = (b2MouseJoint *)[touchValue pointerValue];
        if (mouseJoint) {
            world->DestroyJoint(mouseJoint);
            CFDictionaryRemoveValue(_mouseJoints, touch);
        }
	}
        
    [self clearSlices];
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
    
    // step4
    // Box2D has some restrictions with difining shapes, so you have to consider these.
    // You only cut the shape if both shapes pass certain requirements from our function
    BOOL sprite1VerticesAcceptable = [self areVerticesAcceptable:sprite1VerticesSorted count:sprite1VerticesCount];
    BOOL sprite2VerticesAcceptable = [self areVerticesAcceptable:sprite2VerticesSorted count:sprite2VerticesCount];
    
    // step5
    // you destroy the old shape and create the new shapes and sprites
    if (sprite1VerticesAcceptable && sprite2VerticesAcceptable) {
        // 効果音
        AudioServicesPlaySystemSound(cutSoundID);

        // linearImplus to splitted bodys
        b2Vec2 worldEntry = sprite.body->GetWorldPoint(sprite.entryPoint);
        b2Vec2 worldExit = sprite.body->GetWorldPoint(sprite.exitPoint);
        float angle = ccpToAngle(ccpSub(ccp(worldExit.x,worldExit.y), ccp(worldEntry.x,worldEntry.y)));
        CGPoint vector1 = ccpForAngle(angle + 1.570796);
        CGPoint vector2 = ccpForAngle(angle - 1.570796);
        float midX = midpoint(worldEntry.x, worldExit.x);
        float midY = midpoint(worldEntry.y, worldExit.y);
        
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
        [self addChild:newSprite1 z:Z_VEGE_SLICED];
        newSprite1.body->ApplyLinearImpulse(b2Vec2(body1->GetMass()*vector1.x/4,body1->GetMass()*vector1.y/4), b2Vec2(midX,midY));
        newSprite1.tag = sprite.tag;
        [newSprite1 activateCollisions];
        
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
        [self addChild:newSprite2 z:Z_VEGE_SLICED];
        newSprite2.body->ApplyLinearImpulse(b2Vec2(body2->GetMass()*vector2.x/4,body2->GetMass()*vector2.y/4), b2Vec2(midX,midY));
        newSprite2.tag = sprite.tag;
        [newSprite2 activateCollisions];
        
        // you don't need the old shape & sprite anymore so you either destroy it or squirrel it away
        if (sprite.original) {
//            [sprite deactivateCollisions];
//            sprite.position = ccp(-256, -256);
//            sprite.sliceEntered = NO;
//            sprite.sliceExited = NO;
//            sprite.entryPoint.SetZero();
//            sprite.exitPoint.SetZero();
            // オリジナル消したらまずいのか...?
            world->DestroyBody(sprite.body);
            [self removeChild:sprite cleanup:YES];
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
    bodyDef.linearDamping = 2;
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

-(BOOL)areVerticesAcceptable:(b2Vec2*)vertices count:(int)count
{
    //check 1: polygons need to at least have 3 vertices
    if (count < 3)
    {
        return NO;
    }
    
    //check 2: the number of vertices cannot exceed b2_maxPolygonVertices
    if (count > b2_maxPolygonVertices)
    {
        return NO;
    }
    
    //check 3: Box2D needs the distance from each vertex to be greater than b2_epsilon
    int32 i;
    for (i=0; i<count; ++i)
    {
        int32 i1 = i;
        int32 i2 = i + 1 < count ? i + 1 : 0;
        b2Vec2 edge = vertices[i2] - vertices[i1];
        if (edge.LengthSquared() <= b2_epsilon * b2_epsilon)
        {
            return NO;
        }
    }
    
    //check 4: Box2D needs the area of a polygon to be greater than b2_epsilon
    float32 area = 0.0f;
    
    b2Vec2 pRef(0.0f,0.0f);
    
    for (i=0; i<count; ++i)
    {
        b2Vec2 p1 = pRef;
        b2Vec2 p2 = vertices[i];
        b2Vec2 p3 = i + 1 < count ? vertices[i+1] : vertices[0];
        
        b2Vec2 e1 = p2 - p1;
        b2Vec2 e2 = p3 - p1;
        
        float32 D = b2Cross(e1, e2);
        
        float32 triangleArea = 0.5f * D;
        area += triangleArea;
    }
    //CCLOG(@"area:%f",area);
    if (area <= MIN_CUT_AREA)
    {
        return NO;
    }
    
    //check 5: Box2D requires that the shape be Convex.
    float determinant;
    float referenceDeterminant;
    b2Vec2 v1 = vertices[0] - vertices[count-1];
    b2Vec2 v2 = vertices[1] - vertices[0];
    referenceDeterminant = calculate_determinant_2x2(v1.x, v1.y, v2.x, v2.y);
    
    for (i=1; i<count-1; i++)
    {
        v1 = v2;
        v2 = vertices[i+1] - vertices[i];
        determinant = calculate_determinant_2x2(v1.x, v1.y, v2.x, v2.y);
        //you use the determinant to check direction from one point to another. A convex shape's points should only go around in one direction. The sign of the determinant determines that direction. If the sign of the determinant changes mid-way, then you have a concave shape.
        if (referenceDeterminant * determinant < 0.0f)
        {
            //if multiplying two determinants result to a negative value, you know that the sign of both numbers differ, hence it is concave
            return NO;
        }
    }
    v1 = v2;
    v2 = vertices[0]-vertices[count-1];
    determinant = calculate_determinant_2x2(v1.x, v1.y, v2.x, v2.y);
    if (referenceDeterminant * determinant < 0.0f)
    {
        return NO;
    }
    
    return YES;
}

-(void)checkAndSliceObjects
{
    double curTime = CACurrentMediaTime();
    id* userData;
    
    if (!_canSliceObject) {
        return;
    }
    
    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()) {
        if (b->GetUserData() != NULL) {
            userData = (id*)b->GetUserData();
            if ([userData isKindOfClass:[PolygonSprite class]]) {
                PolygonSprite *sprite = (PolygonSprite*)userData;

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
}

-(void)clearSlices
{
    id* userData;
    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()) {
        if (b->GetUserData() != NULL) {
            userData = (id*)b->GetUserData();
            if ([userData isKindOfClass:[PolygonSprite class]]) {
                PolygonSprite *sprite = (PolygonSprite*)userData;
                sprite.sliceEntered = NO;
                sprite.sliceExited = NO;
            }
        }
    }
}

// 時よとまれ
-(void)theWorld
{
    // 野菜のCutを要請
    _canSliceObject = NO;
    CGSize screen = [[CCDirector sharedDirector] winSize];

    // 効果音とか
    
    // 野菜の動きを止める
    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()) {
        if (b->GetUserData() != NULL) {
            b->SetLinearVelocity(b2Vec2(0,0));
            b->SetAngularVelocity(0);
        }
    }
    // 野菜のタッチ抑制
    _canTouch = NO;
    
    // 野菜の生成を止める
    [_createVegeTimer invalidate];
    _createVegeTimer = nil;
    
    // ボディの非表示
    [NSTimer scheduledTimerWithTimeInterval:0.0 // 時間間隔(秒)
                                     target:self //呼び出すオブジェクト
                                   selector:@selector(balseBody:)
                                   userInfo:nil
                                    repeats:NO];
    // 鍋ぶたをセット
    CCSprite *nabebuta = [CCSprite spriteWithFile:@"nabebuta.png"];
    nabebuta.position = ccp((screen.width/2), screen.height);
    [self addChild:nabebuta z:Z_NABEBUTA tag:kTagNabebuta];
    CGPoint nabePosition = [self getChildByTag:kTagNabe].position;
    //CCLOG(@"nabePosion.x:%d y:%d", nabePosition.x, nabePosition.y);
    id anim = [CCMoveTo actionWithDuration:1.0f position:nabePosition];
    id act_func =[CCCallFunc actionWithTarget:self selector:@selector(removeNabeWater)];
    id seqAnim = [CCSequence actions:anim, act_func, nil];
    [nabebuta runAction:seqAnim];
    
    
    // 発射のアニメーションセット
    [NSTimer scheduledTimerWithTimeInterval:1.5 // 時間間隔(秒)
                                     target:self //呼び出すオブジェクト
                                   selector:@selector(fire:)
                                   userInfo:nil
                                    repeats:NO];
    
    
}
-(void)removeNabeWater
{
    [self removeChildByTag:kTagNabeWaterFront cleanup:YES];
    [self removeChildByTag:kTagNabeWaterBack cleanup:YES];
}
-(void)balseBody:(ccTime *)timer
{
    id userData;
    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()) {
        userData = (id)b->GetUserData();
        if ([userData isKindOfClass:[PolygonSprite class]]) {
            world->DestroyBody(b);
            [self removeChild:(CCNode*)userData cleanup:YES];
        }
    }
}
-(void)fire:(ccTime *)timer
{
    // 効果音
    AudioServicesPlaySystemSound(fireSoundID);
    
    CGSize screen = [[CCDirector sharedDirector] winSize];
    CCSprite* nabe = (CCSprite*)[self getChildByTag:kTagNabe];
    CCSprite* nabebuta = (CCSprite*)[self getChildByTag:kTagNabebuta];
    CCSprite* nabeFront = (CCSprite*)[self getChildByTag:kTagNabeFront];
    CCSprite* perfectNabe = [CCSprite spriteWithFile:@"nabe_perfect.png"];
    perfectNabe.position = ccp(nabe.position.x, nabe.contentSize.height * -1);
    [self addChild:perfectNabe z:Z_NABE tag:kTagNabe];
    id anim = [CCMoveTo actionWithDuration:2.0f position:ccp(nabe.position.x, screen.height+nabe.contentSize.height)];
//    id act_func =[CCCallFunc actionWithTarget:self selector:@selector(changeToDekiagaLayer)];
    id seqAnim = [CCSequence actions:anim, nil];
    [perfectNabe runAction:seqAnim];
    [self removeChild:nabe cleanup:YES];
    [self removeChild:nabebuta cleanup:YES];
    [self removeChild:nabeFront cleanup:YES];
    
    [NSTimer scheduledTimerWithTimeInterval:0.2 // 時間間隔(秒)
                                     target:self //呼び出すオブジェクト
                                   selector:@selector(changeToDekiagaLayer)
                                   userInfo:nil
                                    repeats:NO];
    
}

-(void)cleanUpShibuki
{
    [self removeChildByTag:100 cleanup:YES];
}
-(void)changeToDekiagaLayer
{
    CCScene *scene;
    scene = [DekiagaLayer scene];
    //[self addChild:scene];
//    CCTransitionSlideInL* transition = [CCTransitionSlideInL transitionWithDuration:0.5 scene:scene];
//    [[CCDirector sharedDirector] pushScene:transition];
    ccColor3B color = {245,245,245};
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:3.5f scene:scene withColor:color]];

}

-(BOOL)hasMouseJoint:(b2Body*)body
{
    NSArray* valueArray = [(NSDictionary*)_mouseJoints allValues];
    b2MouseJoint* mouseJoint;
    for (NSValue *value in valueArray) {
        mouseJoint = (b2MouseJoint*)[value pointerValue];
        if(mouseJoint && mouseJoint->GetBodyB() == body){
            return YES;
        }
    }
    return NO;
//    if (_mouseJoint && _mouseJoint->GetBodyB() == body) {
//        return YES;
//    }else {
//        return NO;
//    };
}
//-(void)destroyMouseJoint:(b2Body*)body
//{
//    if (_mouseJoint && _mouseJoint->GetBodyB() == body) {
//        world->DestroyJoint(_mouseJoint);
//        _mouseJoint = NULL;
//    }
//}
-(void) soundWaterDrop{
    AudioServicesPlaySystemSound(waterDropSoundID);
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
