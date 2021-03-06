//
//  Nabe.m
//  Robocurry
//
//  Created by 光 渡邊 on 12/07/18.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "Nabe.h"


@implementation Nabe

@synthesize body = _body;
@synthesize sprite = _sprite;


-(id)initWithWorld:(b2World*)world parentNode:(CCNode*)parentNode
{
    if((self = [super init]))
    {

        _sprite = [CCSprite spriteWithFile:@"nabe.png"];
        [parentNode addChild:_sprite];
   
        // Create _sprite body
        b2BodyDef _spriteBodyDef;
        _spriteBodyDef.type = b2_staticBody;
        _spriteBodyDef.userData = _sprite;
        _body = world->CreateBody(&_spriteBodyDef);
    
        // Create _sprite shape
        b2PolygonShape _spriteShape;
        int count = 6;
        b2Vec2 vertices[] = {
            b2Vec2(32.0 / PTM_RATIO, 28.0 / PTM_RATIO),
            b2Vec2(90.0 / PTM_RATIO, 12.0 / PTM_RATIO),
            b2Vec2(165.0 / PTM_RATIO, 12.0 / PTM_RATIO),
            b2Vec2(221.0 / PTM_RATIO, 27.0 / PTM_RATIO),
            b2Vec2(225.0 / PTM_RATIO, 100.0 / PTM_RATIO),
            b2Vec2(30.0 / PTM_RATIO, 100.0 / PTM_RATIO)
        };
    
        _spriteShape.Set(vertices, count);  
    
        b2FixtureDef _spriteShapeDef;
        _spriteShapeDef.shape = &_spriteShape;
        _spriteShapeDef.density = 10.0f;
        _spriteShapeDef.friction = 0.4f;
        _spriteShapeDef.restitution = 0.1f;
        _body->CreateFixture(&_spriteShapeDef);
        
        [self scheduleUpdate];
    }
    return self;

}

-(void)update:(ccTime)delta
{
    _sprite.position = ccp(_body->GetPosition().x*PTM_RATIO + _sprite.texture.contentSize.width/2 , _body->GetPosition().y*PTM_RATIO + _sprite.texture.contentSize.height/2);
    _sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(_body->GetAngle());
//    CCLOG(@"update sprite x:%f y:%f", _sprite.position.x, _sprite.position.y);
//    CCLOG(@"update body x:%f y:%f", _body->GetPosition().x, _body->GetPosition().y);
    //CCLOG(@"update boundingbox x:%f y:%f", _sprite.texture.contentSize.width, _sprite.texture.contentSize.height);
}

-(void)setPosition:(CGPoint)position
{
    _sprite.position = position;
    _body->SetTransform(b2Vec2((position.x - _sprite.boundingBox.size.width/2) /PTM_RATIO, (position.y - _sprite.boundingBox.size.height/2) /PTM_RATIO), _body->GetAngle());
//    CCLOG(@"setPosition body x:%f y:%f", _body->GetPosition().x, _body->GetPosition().y);
//    CCLOG(@"setPosition sprite x:%f y:%f", _sprite.position.x, _sprite.position.y);
}
@end
