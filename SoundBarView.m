//
//  SoundBarView.m
//
//  Created by adan on 10/12/16.
//
//

#import "SoundBarView.h"

@implementation SoundBarView
{
    NSMutableArray *lineQueue;
    NSTimer *updateTimer;
}

@synthesize barWidth, colorBar, colorBarHighlighted, duration, currentPosition;

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if( self ){
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:.05f target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
        _scrollRate = .5f;
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [[UIColor whiteColor] setFill];
    UIRectFill(rect);
    
    CGFloat height = rect.size.height;
    
    if( !lineQueue )
    {
        lineQueue = [NSMutableArray array];
        [self populateLineQueue];
    }
    
    UIBezierPath *coloredPath = [UIBezierPath bezierPath];
    coloredPath.lineWidth = barWidth;
    [colorBarHighlighted setStroke];
    
    //Width is going to be 320, so divide that by the ( barWidth + spacing ) and that is our step
    for( int i = 0; i < (int) lineQueue.count / 2; i++ )
    {
        [coloredPath moveToPoint:CGPointMake([self calculateXPosition:i], height)];
        [coloredPath addLineToPoint:CGPointMake([self calculateXPosition:i], [self calculateYPosition:i])];
    }
    
    [coloredPath stroke];
    
    UIBezierPath *barPath = [UIBezierPath bezierPath];
    barPath.lineWidth = barWidth;
    [colorBar setStroke];
    
    for( int i = (int) lineQueue.count / 2; i < (int) lineQueue.count; i++ ){
        [barPath moveToPoint:CGPointMake([self calculateXPosition:i], height)];
        [barPath addLineToPoint:CGPointMake([self calculateXPosition:i], [self calculateYPosition:i])];
    }
    
    [barPath stroke];
    
}

-(float) getProgress
{
    return duration * 100.0f;
}

/**
 Sets the percentage of the bars that will be highlighted
 Takes in a float in the range [0-100]
 */
-(void) setProgress:(float)progress
{
    if( progress > 100 ){
        progress = (int) progress % 100;
    }
    
    float oldDuration = duration;
    duration = progress / 100;
    [self scrollBarsLeft:( (duration - oldDuration) * 100 )];
    [self setNeedsDisplay];
}

-(float) calculateXPosition:(int) lineNumber
{
    NSMutableDictionary *line = [lineQueue objectAtIndex:lineNumber];
    if( line )
    {
        return [[line objectForKey:@"position"] floatValue];
    }
    
    return lineNumber;
}

-(float) calculateYPosition:(int) lineNumber
{
    
    NSMutableDictionary *line = [lineQueue objectAtIndex:lineNumber];
    if( line )
    {
        return [[line objectForKey:@"height"] floatValue];
    }
    return 0;
}


-(void) populateLineQueue
{
    float maxHeight = self.bounds.origin.y;
    float minHeight = self.bounds.size.height;
    float maxWidth = self.bounds.size.width + 1.5f;
    
    float startPoint = 1.5f;
    while( startPoint < maxWidth )
    {
        NSMutableDictionary *newLine = [NSMutableDictionary dictionary];
        [newLine setObject:[NSNumber numberWithFloat:startPoint] forKey:@"position"];
        float calculatedHeight = [self calculateBarHeightWithMax:maxHeight andMin:minHeight];
        [newLine setObject:[NSNumber numberWithFloat:calculatedHeight] forKey:@"height"];
        [lineQueue addObject:newLine];
        
        startPoint += barWidth + 1.5f;
    }
}

-(void) scrollBarsLeft:(float) delta
{
    delta = MIN( ABS( delta ), .25f );
    NSMutableDictionary *firstLine = [lineQueue objectAtIndex:0];
    if( firstLine )
    {
        float leftMostPoint = [[firstLine objectForKey:@"position"] floatValue];
        if( ( leftMostPoint - delta ) < 0 )
        {
            //Time to dequeue
            [self dequeue];
        }
        
        //Move all of the lines in the queue down by the delta in x
        for( NSMutableDictionary *line in lineQueue )
        {
            float xPosition = [[line objectForKey:@"position"] floatValue];
            xPosition -= delta;
            [line setObject:[NSNumber numberWithFloat:xPosition] forKey:@"position"];
        }
    }
}

-(float) calculateBarHeightWithMax:(float) maxHeight andMin :(float) minHeight
{
    return MIN( minHeight - 4.0f, ABS( ((arc4random()% RAND_MAX ) / ( RAND_MAX * 1.0) ) * ( maxHeight - minHeight ) + minHeight ) );
}

-(void) dequeue
{
    [lineQueue removeObjectAtIndex:0];
    float maxHeight = self.bounds.origin.y;
    float minHeight = self.bounds.size.height;
    float maxWidth = self.bounds.size.width;
    NSMutableDictionary *newBar = [NSMutableDictionary dictionary];
    float calculatedHeight = [self calculateBarHeightWithMax:maxHeight andMin:minHeight];
    [newBar setObject:[NSNumber numberWithFloat:calculatedHeight] forKey:@"height"];
    
    NSMutableDictionary *lastBar = [lineQueue objectAtIndex:lineQueue.count - 1];
    float xPosition = [[lastBar objectForKey:@"position"] floatValue];
    xPosition += barWidth + 1.5f;
    xPosition = MAX(xPosition, maxWidth);
    [newBar setObject:[NSNumber numberWithFloat:xPosition] forKey:@"position"];
    
    [lineQueue addObject:newBar];
}


-(void) updateProgress
{
    [self scrollBarsLeft:( 1.5f * 100 )];
    [self setNeedsDisplay];
}

-(void)startScrolling{
    if( !updateTimer ){
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:(1.5f - _scrollRate) target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    }
}

-(void)stopScrolling{
    [updateTimer invalidate];
    updateTimer = nil;
}

@end
