//
//  TitleLayer.m
//  Robocurry
//
//  Created by 光 渡邊 on 12/07/17.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "TitleLayer.h"
#import "GameLayer.h"
#import "CreatorLayer.h"

@implementation TitleLayer

+(id) scene
{
	CCLOG(@"===========================================");
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	CCScene* scene = [CCScene node];
	TitleLayer* layer = [TitleLayer node];
	[scene addChild:layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
		
        [self initBackground];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"se_te" ofType:@"mp3"];
        NSURL *url = [NSURL fileURLWithPath:path];
        AudioServicesCreateSystemSoundID((CFURLRef)url, &teSoundID);
        
		CGSize size = [[CCDirector sharedDirector] winSize];
        // setup menu
        CCMenuItem *startItem = [CCMenuItemFont itemWithString:@"ハジメル" target:self selector:@selector(onStart:)];
        //CCMenuItem *createrItem = [CCMenuItemFont itemWithString:@"キーハ・ライト・スター" target:self selector:@selector(onCreator:)];
        CCMenu *menu = [CCMenu menuWithItems:startItem, nil];
        menu.position = ccp(size.width / 2, size.height / 10 * 1);
        [menu alignItemsVertically];
        [self addChild:menu];
        
		self.isTouchEnabled = YES;
	}
	return self;
}

-(void)initBackground
{
    CGSize screen = [[CCDirector sharedDirector] winSize];
    CCSprite *background = [CCSprite spriteWithFile:@"kls_start.png"];
    background.position = ccp(screen.width/2 + 1,screen.height/2 + 1);
    [self addChild:background z:-1];
}


-(void) onStart:(id)item
{
    AudioServicesPlaySystemSound(teSoundID);
    CCTransitionSlideInL* transition = [CCTransitionFade transitionWithDuration:0.5 scene:[GameLayer scene]];
    [[CCDirector sharedDirector] pushScene:transition];
}

-(void) onCreator:(id)item
{
    CCTransitionSlideInL* transition = [CCTransitionSlideInR transitionWithDuration:0.5 scene:[CreatorLayer scene]];
    [[CCDirector sharedDirector] pushScene:transition];
}

-(void) dealloc
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	// don't forget to call "super dealloc"
	[super dealloc];
}



@end
