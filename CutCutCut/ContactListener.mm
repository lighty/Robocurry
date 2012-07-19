
#import "ContactListener.h"
#import "cocos2d.h"
#import "CCSprite.h"
#import "Nabe.h"

void ContactListener::BeginContact(b2Contact* contact)
{
    b2Body* bodyA = contact->GetFixtureA()->GetBody();
    b2Body* bodyB = contact->GetFixtureB()->GetBody();
    id spriteA = (id)bodyA->GetUserData();
    id spriteB = (id)bodyB->GetUserData();
    
    // どっちがどっちでも対応できるようにしておかないと..
    if([spriteB isKindOfClass:[CCSprite class]]){

        id nabe = (Nabe*)spriteB;
        
        CCLOG(@"spriteA class:%@", [spriteA class]);
        CCLOG(@"spriteB class:%@", [spriteB class]);
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