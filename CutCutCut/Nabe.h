//
//  Nabe.h
//  Robocurry
//
//  Created by 光 渡邊 on 12/07/18.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

#define PTM_RATIO 32


@interface Nabe : CCNode {
    CCSprite* _sprite;
    b2Body* _body;
}

@property(nonatomic,assign)b2Body *body;
@property(nonatomic,assign)CCSprite *sprite;

@end
