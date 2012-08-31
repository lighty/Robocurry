//
//  Ika.m
//  Robocurry
// 
// 
//  Created by 光 渡邊 on 12/08/31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Ika.h"

@implementation Ika


-(id)initWithWorld:(b2World*)world
{
    int count = 6;
    //  ※512pxを超えると正常に表示されない？
    NSString* file = @"ika.png";
    b2Vec2 vertices[] = {
        b2Vec2(0.0 / PTM_RATIO, (122.0 ) / PTM_RATIO),
        b2Vec2(5.0 / PTM_RATIO, (83.0 ) / PTM_RATIO),
        b2Vec2(104.0 / PTM_RATIO,( 6.0 ) / PTM_RATIO),
        b2Vec2(123.5 / PTM_RATIO, (6.0 ) / PTM_RATIO),
        b2Vec2(125.0 / PTM_RATIO, (19.0 ) / PTM_RATIO),
        b2Vec2(40.0 / PTM_RATIO, (118.0 )/ PTM_RATIO)
    };
    CGSize screen = [[CCDirector sharedDirector] winSize];
    
    b2Body *body = [self createBodyForWorld:world
                                   position:b2Vec2(screen.width/2/PTM_RATIO, screen.height/4/PTM_RATIO) 
                                   rotation:0
                                   vertices:vertices
                                vertexCount:count
                                    density:5.0
                                   friction:0.2
                                restitution:0.2];
    if((self = [super initWithFile:file body:body original:YES]))
    {
        _tag = kTagVegeIka;
    }
    return self;
}

@end
