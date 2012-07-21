//
//  DekiagaLayer.m
//  Robocurry
//
//  Created by 光 渡邊 on 12/07/22.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "DekiagaLayer.h"
#import "TitleLayer.h"
#import "CreatorLayer.h"

@implementation DekiagaLayer

+(id) scene
{
	CCLOG(@"===========================================");
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	CCScene* scene = [CCScene node];
	DekiagaLayer* layer = [DekiagaLayer node];
	[scene addChild:layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
		
        [self initBackground];
        
		CGSize size = [[CCDirector sharedDirector] winSize];
        // setup menu
        CCMenuItem *modoruItem = [CCMenuItemFont itemWithString:@"モドル" target:self selector:@selector(onModoru:)];
        CCMenu *menu = [CCMenu menuWithItems:modoruItem, nil];
        menu.position = ccp(size.width / 8, size.height / 10 * 1);
        [self addChild:menu];
        
		self.isTouchEnabled = YES;
	}
	return self;
}

-(void)initBackground
{
    CGSize screen = [[CCDirector sharedDirector] winSize];
    CCSprite *background = [CCSprite spriteWithFile:@"dekiagari.png"];
    background.position = ccp(screen.width/2 + 1,screen.height/2 + 1);
    [self addChild:background z:-1];
}


-(void) onModoru:(id)item
{
    CCTransitionSlideInL* transition = [CCTransitionSlideInR transitionWithDuration:0.5 scene:[TitleLayer scene]];
    [[CCDirector sharedDirector] replaceScene:transition];
}
-(void) dealloc
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	// don't forget to call "super dealloc"
	[super dealloc];
}



@end
