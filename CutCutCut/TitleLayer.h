//
//  TitleLayer.h
//  Robocurry
//
//  Created by 光 渡邊 on 12/07/17.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>
#import "cocos2d.h"

@interface TitleLayer : CCLayer {
    SystemSoundID teSoundID;
}

+(id) scene;

@end
