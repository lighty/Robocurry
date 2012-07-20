
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
   
}

void ContactListener::PostSolve(b2Contact* contact, 
                                  const b2ContactImpulse* impulse) {
    contact->SetEnabled(true);
}