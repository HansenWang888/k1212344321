//
//  PresentedDelegaet.m
//  wdk12IPhone
//
//  Created by 老船长 on 15/9/24.
//  Copyright © 2015年 伟东云教育. All rights reserved.
//

#import "PresentedDelegate.h"
#import "PresentatiobController.h"
@interface PresentedDelegate () 

@property (nonatomic, assign) BOOL isPresentation;
@property (nonatomic, strong) PresentatiobController *presentControl;

@end

@implementation PresentedDelegate

//负责展现
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.isPresentation = YES;
    return  self;
}


- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.isPresentation = NO;
    return  self;
}

//负责转场的控制器
- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {

    self.presentControl = [[PresentatiobController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    self.presentControl.rect = self.rect;
    return self.presentControl;
}


# pragma mark UIViewControllerAnimatedTransitioning 
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {

    if (self.isPresentation) {
        UIView *view =  [transitionContext viewForKey:UITransitionContextToViewKey];
        [transitionContext.containerView addSubview:view];
        
        view.layer.anchorPoint = CGPointMake(0.5, 0);
        view.transform = CGAffineTransformMakeScale(1.0, 0);
        [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            view.transform = CGAffineTransformIdentity;

        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    else {
        
        UIView *view = [transitionContext viewForKey:UITransitionContextFromViewKey];
        //删除动画
        [UIView animateWithDuration:ANIMATION_TIME animations:^{
            //如果设置一个很小的数就能够实现缩进动画
            view.transform =
            CGAffineTransformMakeScale(1.0, 0.0001);

        } completion:^(BOOL finished) {
            [view removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    }
}

- (void)dismissDuumyView {
    [self.presentControl dismissDuumyView];
}
@end
