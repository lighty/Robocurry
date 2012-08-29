
#import "ContactListener.h"
#import "cocos2d.h"
#import "CCSprite.h"
#import "Nabe.h"
#import "Roo.h"
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
        CCAnimation* animation = [CCAnimation animationWithFile:@"water_drop" frameCount:3 delay:0.2f];
        id anim = [CCAnimate actionWithAnimation:animation];
        float32 rooArea = [[[_node nabeContents] objectForKey:[Roo class]] floatValue];
        id coloring;
        ccColor3B color;
        if(rooArea > ROO_CHANGE_2){
            coloring = [CCTintTo actionWithDuration:0 red:70 green:51 blue:13];
            color = (ccColor3B){70,51,13};
        }else if(rooArea > ROO_CHANGE_1){
            coloring = [CCTintTo actionWithDuration:0 red:103 green:77 blue:32];
            color = (ccColor3B){103,77,32};
        }else if(rooArea > ROO_CHANGE_0){
            coloring = [CCTintTo actionWithDuration:0 red:145 green:122 blue:92];
            color = (ccColor3B){145,122,92};
        }else {
            coloring = NULL;
            color = (ccColor3B){213,239,239};
        }
        
        // 水しぶきの廃棄処理
        id act_func =[CCCallFunc actionWithTarget:_node selector:@selector(cleanUpShibuki)];
        id act;
        if (coloring == NULL) {
            act = [CCSequence actions:anim, act_func, nil];
        }else {
            act = [CCSequence actions:coloring, anim, act_func, nil];
        }
        
        // 衝突位置の割り出し
        b2WorldManifold manifold;
        contact->GetWorldManifold(&manifold);
        b2Vec2 b2ContactPoint = manifold.points[0];
        
        // 水しぶきのスプライト作成
        CCSprite *sprite = [CCSprite spriteWithFile:@"water_drop0.png"];
        sprite.position = ccp(b2ContactPoint.x * PTM_RATIO, b2ContactPoint.y * PTM_RATIO + sprite.texture.contentSize.height/2-5);
        sprite.color = color;
        
        [sprite runAction:act];
        
        // 水しぶきの効果音
        [_node soundWaterDrop];
        
        // ナベのタグをどっかに定義したい
        [(CCNode*)_node addChild:sprite z:Z_SHIBUKI tag:100];
        
        // 底についたあと浮き上がるのを防止するため
        bodyB->ApplyForce(b2Vec2(0,-10000), bodyB->GetPosition());

        
        // ナベの下についたやつは壁以外の衝突を無効にして、以降MouseJointさせない
        //[spriteB deactivateCollisions];
        //((PolygonSprite*)spriteB).canGrab = NO;
        
        
//        CCLOG(@"spriteA class:%@", [spriteA class]);
//        CCLOG(@"spriteB class:%@", [spriteB class]);
    }
    
    b2Fixture* fixtureA = contact->GetFixtureA();
    id fixtureAUserData = (id)fixtureA->GetUserData();
    if(spriteA != NULL && spriteB != NULL && [fixtureAUserData isKindOfClass:[NSString class]] && fixtureAUserData == @"nabe_bottom_fixture" && ![_node hasMouseJoint:bodyB]){
        // ここにいるということはナベに入ったと考えてデータを保存しておく
        // いまのところルーの分しか数えない
        if (((PolygonSprite*)spriteB).tag == kTagRoo) {
            float32 nabeContentsArea = [[[_node nabeContents] objectForKey:[Roo class]] floatValue];
            float32 sum = [spriteB area] + nabeContentsArea;
            [[_node nabeContents] setObject:[NSNumber numberWithFloat:sum] forKey:[Roo class]];
            // ルーの合計の面積が一定数を超えたら画像切り替え
            if(sum > ROO_CHANGE_2){
                id action1 = [CCTintTo actionWithDuration:1 red:70 green:51 blue:13];
                [[_node getChildByTag:kTagNabeWaterFront] runAction: action1];
                id action2 = [CCTintTo actionWithDuration:1 red:70 green:51 blue:13];
                [[_node getChildByTag:kTagNabeWaterBack] runAction: action2];
            }else if(sum > ROO_CHANGE_1){
                id action1 = [CCTintTo actionWithDuration:1 red:103 green:77 blue:32];
                [[_node getChildByTag:kTagNabeWaterFront] runAction: action1];
                id action2 = [CCTintTo actionWithDuration:1 red:103 green:77 blue:32];
                [[_node getChildByTag:kTagNabeWaterBack] runAction: action2];
                
                // ここらへんで発射ボタン押せるようにする
                [NSTimer scheduledTimerWithTimeInterval:random_range(3, 6) // 時間間隔(秒)
                                                 target:_node //呼び出すオブジェクト
                                               selector:@selector(blinkingButton:)
                                               userInfo:nil
                                                repeats:NO];
                
            }else if(sum > ROO_CHANGE_0){
                id action1 = [CCTintTo actionWithDuration:1 red:145 green:122 blue:92];
                [[_node getChildByTag:kTagNabeWaterFront] runAction: action1];
                id action2 = [CCTintTo actionWithDuration:1 red:145 green:122 blue:92];
                [[_node getChildByTag:kTagNabeWaterBack] runAction: action2];
            }
            //CCLOG(@"Roo area:%f",sum);
        }
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
//    b2Fixture* fixtureB = contact->GetFixtureB();
    id fixtureAUserData = (id)fixtureA->GetUserData();
//    id fixtureBUserData = (id)fixtureB->GetUserData();
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