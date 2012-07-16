//
//  Ninjin.m
//  CutCutCut
//
//  Created by 光 渡邊 on 12/07/09.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "Ninjin.h"


@implementation Ninjin

-(id)initWithWorld:(b2World*)world
{
    int count = 7;
    NSString* file = @"ninjin.png";
    b2Vec2 vertices[] = {
        b2Vec2(37.2 / PTM_RATIO, 240.4 / PTM_RATIO),
        b2Vec2(14.0 / PTM_RATIO, 193.0 / PTM_RATIO),
        b2Vec2(14.0 / PTM_RATIO, 169.0 / PTM_RATIO),
        b2Vec2(44.0 / PTM_RATIO, 64.0 / PTM_RATIO),
        b2Vec2(64.0 / PTM_RATIO, 69.0 / PTM_RATIO),
        b2Vec2(89.0 / PTM_RATIO, 183.0 / PTM_RATIO),
        b2Vec2(69.0 / PTM_RATIO, 238.0 / PTM_RATIO)
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
        
    }
    return self;
}

@end
