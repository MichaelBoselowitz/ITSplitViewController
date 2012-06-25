//
//  ITSplitViewController.h
//  ITSplitViewController
//
//  Created by Michael Boselowitz on 11/8/11.
//  Copyright (c) 2011 University of Pittsburgh. All rights reserved. 
//

//Pixel width of iPad landscape master pane, currently set to 1/3 of screen width
#define ITSPLITVIEWCONTROLLER_MASTERVIEW_IN_LANDSCAPE_WIDTH 341
//Pixel width of iPad landscape detail pane, currently set to 2/3 of screen width with 1 pixel left for a gap between panes
#define ITSPLITVIEWCONTROLLER_DETAILVIEW_IN_LANDSCAPE_WIDTH 682
//Pixel height of iPad landscape
#define ITSPLITVIEWCONTROLLER_LANDSCAPE_HEIGHT 748
//Duration of animation for flipping between primary master and secondary master, currently set to 1 second
#define ITSPLITVIEWCONTROLLER_LENGTH_OF_ANIMATION_FLIP 1.0f
//Duration of animation when pushing or popping detail view, currently set to 1/4 of a second
#define ITSPLITVIEWCONTROLLER_LENGTH_OF_ANIMATION_NAVIGATION .25f
//Amount to round corners of all views if it is an iPad, currently set to 5 pixels
#define ITSPLITVIEWCONTROLLER_CORNER_RADIUS 5.0f
//This defines the default resizing mask for all views, currently set to autoresize in all directions
#define ITSPLITVIEWCONTROLLER_CONTAINER_AUTORESIZE_MASK UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
//Defines how to tell if it is an iPad or iPhone
#define ITSPLITVIEWCONTROLLER_ISIPAD ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
#define ITSPLITVIEWCONTROLLER_ISIPHONE ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
//Defines which state to display when flipping from iPad landscape, currently set to display master, other choice is detail
#define ITSPLITVIEWCONTROLLER_DEFAULT_STATE_TO_DISPLAY ITSplitViewControllerMaster

#import <UIKit/UIKit.h>

@class ITSplitViewController;

typedef enum
{
    ITSplitViewControllerSidePrimary, ITSplitViewControllerSideSecondary
} ITSplitViewControllerSide;

typedef enum
{
    ITSplitViewControllerMaster, ITSplitViewControllerDetail, ITSplitViewControllerSplit
} ITSplitViewControllerState;

@protocol ITSplitViewControllerDelegate <NSObject>

- (void)splitViewController:    (ITSplitViewController *)splitViewController 
    willRotateToOrientation:    (UIInterfaceOrientation)orientation;
- (void)splitViewController:    (ITSplitViewController *)splitViewController 
             willFlipToSide:    (ITSplitViewControllerSide)side;
- (BOOL)splitViewController:    (ITSplitViewController *)splitViewController 
  shouldRotateToOrientation:    (UIInterfaceOrientation)orientation;

@end

@interface ITSplitViewController : UIViewController
{
    UIView *primaryMasterView, *secondaryMasterView, *detailView;
    
    UIView *containerView, *masterContainerView, *detailContainerView;
    
    ITSplitViewControllerSide   currentSide;
    ITSplitViewControllerState  defaultStateToDisplay;
    ITSplitViewControllerState  currentState;
}

- (id)init;
- (id)initWithPrimaryMasterView:                (UIView *)primaryMaster
            secondaryMasterView:                (UIView *)secondaryMaster;
- (void)setSide:                         (ITSplitViewControllerSide)side;
- (void)pushDetailView:                         (UIView *)detail;
- (void)popToMasterViewSide:                    (ITSplitViewControllerSide)side;

@property (nonatomic, strong)           id<ITSplitViewControllerDelegate>delegate;
@property (nonatomic, strong, readonly) UIView *primaryMasterView;
@property (nonatomic, strong, readonly) UIView *secondaryMasterView;
@property (nonatomic, strong)           UIView *detailView;
@property (nonatomic, strong, readonly) UIView *containerView;
@property (nonatomic, strong, readonly) UIView *masterContainerView;
@property (nonatomic, strong, readonly) UIView *detailContainerView;
@property (nonatomic, readonly) ITSplitViewControllerSide   currentSide;
@property (nonatomic)           ITSplitViewControllerState  defaultStateToDisplay;
@property (nonatomic, readonly) ITSplitViewControllerState  currentState;

@end

