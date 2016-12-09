//
//  SoundBarView.h
//  RockMyRun
//
//  Created by adan on 10/12/16.
//
//

#import <UIKit/UIKit.h>

@interface SoundBarView : UIView

@property (nonatomic, strong) UIColor *colorBarHighlighted;
@property (nonatomic, strong) UIColor *colorBar;
@property (nonatomic, getter=getProgress, setter=setProgress:) float duration;
@property (nonatomic, assign) float currentPosition;
@property (nonatomic, assign) CGFloat barWidth;
@property (nonatomic, assign) float scrollRate;

-(void) startScrolling;
-(void) stopScrolling;
@end
