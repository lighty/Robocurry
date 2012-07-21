
#import "ContactListener.h"
#import "cocos2d.h"
#import "CCSprite.h"
#import "Nabe.h"
#import "CCAnimationHelper.h"
#import "GameLayer.h"

void ContactListener::SetNode(id node)
{
    _node = node;
}

void ContactListener::BeginContact(b2Contact* contact)
{
    b2Body* bodyA = contact->GetFixtureA()->GetBody();
    b2Body* bodyB = contact->GetFixtureB()->GetBody();
    id spriteA = (id)bodyA->GetUserData();
    id spriteB = (id)bodyB->GetUserData();
    
    if(spriteA != NULL && spriteB != NULL && [spriteA isKindOfClass:[NSString class]] && spriteA == @"nabe_top"){
        // 水しぶき
        CCAnimation* animation = [CCAnimation animationWithFile:@"shibuk" frameCount:3 delay:0.2f];
        id anim = [CCAnimate actionWithAnimation:animation];
        
        // 水しぶきの廃棄処理
        id act_func =[CCCallFunc actionWithTarget:_node selector:@selector(cleanUpShibuki)];
        id act = [CCSequence actions:anim, act_func, nil];
        
        // 衝突位置の割り出し
        b2WorldManifold manifold;
        contact->GetWorldManifold(&manifold);
        b2Vec2 b2ContactPoint = manifold.points[0];
        
        // 水しぶきのスプライト作成
        CCSprite *sprite = [CCSprite spriteWithFile:@"shibuk0.png"];
        sprite.position = ccp(b2ContactPoint.x * PTM_RATIO, b2ContactPoint.y * PTM_RATIO + sprite.texture.contentSize.height/2-5);
        [sprite runAction:act];
        // ナベのタグをどっかに定義したい
        [(CCNode*)_node addChild:sprite z:Z_SHIBUKI tag:100];
        
        // ナベの下についたやつは壁以外の衝突を無効にして、以降MouseJointさせない
        //[spriteB deactivateCollisions];
        //((PolygonSprite*)spriteB).canGrab = NO;
        
        
//        CCLOG(@"spriteA class:%@", [spriteA class]);
//        CCLOG(@"spriteB class:%@", [spriteB class]);
    }
    

}

void ContactListener::EndContact(b2Contact* contact)
{
    b2Body* bodyA = contact->GetFixtureA()->GetBody();
    b2Body* bodyB = contact->GetFixtureB()->GetBody();
    id spriteA = (id)bodyA->GetUserData();
    id spriteB = (id)bodyB->GetUserData();
    
    if( spriteA != NULL && spriteB != NULL){
    }
}

void ContactListener::PreSolve(b2Contact* contact, 
                                 const b2Manifold* oldManifold) {
    b2Body* bodyA = contact->GetFixtureA()->GetBody();
    b2Body* bodyB = contact->GetFixtureB()->GetBody();
    id spriteA = (id)bodyA->GetUserData();
    id spriteB = (id)bodyB->GetUserData();

    if(spriteA != NULL && spriteB != NULL && [spriteA isKindOfClass:[NSString class]] && spriteA == @"nabe_top"){
         contact->SetEnabled(false);
    }
   
    // ナベが底に付いたら動きとめて衝突&タッチをできないようにする。マウスジョイントしている場合は除く
    b2Fixture* fixtureA = contact->GetFixtureA();
    b2Fixture* fixtureB = contact->GetFixtureB();
    id fixtureAUserData = (id)fixtureA->GetUserData();
    id fixtureBUserData = (id)fixtureB->GetUserData();
    if(spriteA != NULL && spriteB != NULL && [fixtureAUserData isKindOfClass:[NSString class]] && fixtureAUserData == @"nabe_bottom_fixture" && ![_node hasMouseJoint:bodyB]){
        
        
        
        bodyA->SetLinearVelocity(b2Vec2(0,0));
        bodyA->SetAngularVelocity(0);
        [spriteB deactivateCollisions];
        ((PolygonSprite*)spriteB).canGrab = NO;
        contact->SetEnabled(false);        
        // マウスジョイントしてたら外す
//        [_node destroyMouseJoint:bodyB];
        
        //        CCLOG(@"spriteA class:%@", [spriteA class]);
        //        CCLOG(@"spriteB class:%@", [spriteB class]);
    }    


}

void ContactListener::PostSolve(b2Contact* contact, 
                                  const b2ContactImpulse* impulse) {
    contact->SetEnabled(true);
}