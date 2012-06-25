//
//  ITSplitViewController.m
//  ITSplitViewController
//
//  Created by Michael Boselowitz on 11/7/11.
//  Copyright (c) 2011 University of Pittsburgh. All rights reserved.
//

#import "ITSplitViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation ITSplitViewController
@synthesize delegate;
@synthesize primaryMasterView;
@synthesize secondaryMasterView;
@synthesize detailView;
@synthesize currentSide;
@synthesize defaultStateToDisplay;
@synthesize currentState;
@synthesize containerView;
@synthesize masterContainerView;
@synthesize detailContainerView;


#pragma mark - Initialization

- (id)init
{
    return [self initWithPrimaryMasterView:nil
                       secondaryMasterView:nil];
}

- (id)initWithPrimaryMasterView:(UIView *)primaryMaster 
            secondaryMasterView:(UIView *)secondaryMaster
{
    self = [super init];
    if(self)
    {
        currentSide = ITSplitViewControllerSidePrimary;
        currentState = ITSplitViewControllerMaster;
        defaultStateToDisplay = ITSPLITVIEWCONTROLLER_DEFAULT_STATE_TO_DISPLAY;
        primaryMasterView = primaryMaster;
        secondaryMasterView = secondaryMaster;
    }
    return self;
}

#pragma mark - Rotation, Flip, and Navigation

- (void)setSide:(ITSplitViewControllerSide)side
{
    //Jump out if we are already displaying that side, also do not allow a flip when we are looking at the detail.
    if(currentSide == side || currentState == ITSplitViewControllerDetail)
    {
        return;
    }
    //Inform delegate that we are flipping to side
    if(delegate)
    {
        [delegate splitViewController:self 
                       willFlipToSide:side];
    }
    //Do animation to correct side and flip current side to reflect change.
    if(currentSide == ITSplitViewControllerSidePrimary)
    {
        secondaryMasterView.frame = primaryMasterView.frame;
        [UIView transitionFromView:primaryMasterView 
                            toView:secondaryMasterView 
                          duration:ITSPLITVIEWCONTROLLER_LENGTH_OF_ANIMATION_FLIP 
                           options:UIViewAnimationOptionTransitionFlipFromRight 
                        completion:^(BOOL finished){ currentSide = ITSplitViewControllerSideSecondary; }];
    }
    else
    {
        primaryMasterView.frame = secondaryMasterView.frame;
        [UIView transitionFromView:secondaryMasterView 
                            toView:primaryMasterView 
                          duration:ITSPLITVIEWCONTROLLER_LENGTH_OF_ANIMATION_FLIP 
                           options:UIViewAnimationOptionTransitionFlipFromLeft 
                        completion:^(BOOL finished){ currentSide = ITSplitViewControllerSidePrimary; }];
    }
}

- (void)pushDetailView:(UIView *)detail
{
    if(!detail)
    {
        [NSException raise:@"Invalid Detail View" 
                    format:@"Detail is nil, when pushing a detail it must not be nil"];
    }
    //Round corners if it is iPad only
    if(ITSPLITVIEWCONTROLLER_ISIPAD)
    {
        detail.layer.masksToBounds = YES;
        [detail.layer setCornerRadius:ITSPLITVIEWCONTROLLER_CORNER_RADIUS];
    }
    //Make sure resizing masks are set for new detail
    detail.autoresizingMask = ITSPLITVIEWCONTROLLER_CONTAINER_AUTORESIZE_MASK;
    detail.autoresizesSubviews = YES;
    
    //If not iPad in landscape do this
    if(ITSPLITVIEWCONTROLLER_ISIPHONE || 
       (ITSPLITVIEWCONTROLLER_ISIPAD && (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))))
    {
        //Change state to reflect correctly
        currentState = ITSplitViewControllerDetail;
        //Change the detail and detail container frame to correct size
        detailContainerView.frame = CGRectMake(masterContainerView.frame.size.width, 0, masterContainerView.frame.size.width,masterContainerView.frame.size.height);
        detail.frame = CGRectMake(0, 0, masterContainerView.frame.size.width, masterContainerView.frame.size.height);
        //Remove old detail view from superview and add current detail to detail container and add detail container.
        [detailView removeFromSuperview];
        [detailContainerView addSubview:detail];
        [containerView addSubview:detailContainerView];
        //Animate between master container and detail container, makes sure to remove master at end and set it's frame back.
        [UIView animateWithDuration:ITSPLITVIEWCONTROLLER_LENGTH_OF_ANIMATION_NAVIGATION 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveLinear 
                         animations:^(void)
                                    {
                                        detailContainerView.frame = masterContainerView.frame;
                                        masterContainerView.frame = CGRectMake(-masterContainerView.frame.size.width, 0, masterContainerView.frame.size.width, masterContainerView.frame.size.height);
                                    }
                         completion:^(BOOL finished)
                                    {
                                        [masterContainerView removeFromSuperview];
                                        masterContainerView.frame = detailContainerView.frame;
                                    }];
        
    }
    //Else iPad in landscape, fade from current displayView to new detail
    else
    {
        currentState = ITSplitViewControllerSplit;
        detail.frame = detailView.frame;
        //Animate from current detailView to detail
        [UIView transitionWithView:detailContainerView 
                          duration:ITSPLITVIEWCONTROLLER_LENGTH_OF_ANIMATION_NAVIGATION 
                           options:UIViewAnimationOptionTransitionCrossDissolve 
                        animations:^(void)
                                    {
                                        [detailView removeFromSuperview];
                                        [detailContainerView addSubview:detail];
                                    }
                        completion:nil];
    }
    //Remember to change detailView to reflect current pushed detail
    detailView = detail;
 }

- (void)popToMasterViewSide:(ITSplitViewControllerSide)side
{
    //Jump out if it is iPad in landscape, can't pop the detail when in landscape
    if(ITSPLITVIEWCONTROLLER_ISIPAD && UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    {
        return;
    }
    //Change state to master
    currentState = ITSplitViewControllerMaster;
    //Set up frames to correct positions to animate from detail to master
    masterContainerView.frame = CGRectMake(-detailContainerView.frame.size.width, 0, detailContainerView.frame.size.width,detailContainerView.frame.size.height);
    primaryMasterView.frame = CGRectMake(0, 0, detailContainerView.frame.size.width, detailContainerView.frame.size.height);
    secondaryMasterView.frame = CGRectMake(0, 0, detailContainerView.frame.size.width, detailContainerView.frame.size.height);
    [containerView addSubview:masterContainerView];
    //Animate between detail and master, remove detailView from container, re-adjust detail container, and set side
    [UIView animateWithDuration:ITSPLITVIEWCONTROLLER_LENGTH_OF_ANIMATION_NAVIGATION 
                          delay:0.0 
                        options:UIViewAnimationOptionCurveLinear 
                     animations:^(void)
                                {
                                    masterContainerView.frame = detailContainerView.frame;
                                    detailContainerView.frame = CGRectMake(detailContainerView.frame.size.width, 0, detailContainerView.frame.size.width,detailContainerView.frame.size.height);
                                }
                     completion:^(BOOL finished)
                                {
                                    [detailView removeFromSuperview];
                                    [detailContainerView removeFromSuperview];
                                    detailContainerView.frame = CGRectMake(0, 0, detailContainerView.frame.size.width, detailContainerView.frame.size.height);
                                    [self setSide:side];
                                }];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    //If delegate says yes return yes, else return no
    if([delegate splitViewController:self 
           shouldRotateToOrientation:toInterfaceOrientation])
    {
        //If iPad landscape, set up landscape
        if(ITSPLITVIEWCONTROLLER_ISIPAD && UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            if(!detailView)
            {
                [NSException raise:@"Invalid Detail View" 
                            format:@"detailView is currently equal to nil, a value must be set before rotating to landscape on iPad"];
            }
            //Properly round the corners on detailView
            detailView.layer.masksToBounds = YES;
            [detailView.layer setCornerRadius:ITSPLITVIEWCONTROLLER_CORNER_RADIUS];
            
            //Turn autoresizing off, since this will mess with the settings for the landscape set up
            masterContainerView.autoresizingMask = UIViewAutoresizingNone;
            detailContainerView.autoresizingMask = UIViewAutoresizingNone;
            primaryMasterView.autoresizingMask = UIViewAutoresizingNone;
            secondaryMasterView.autoresizingMask = UIViewAutoresizingNone;
            detailView.autoresizingMask = UIViewAutoresizingNone;
            
            masterContainerView.frame = CGRectMake(0, 0, ITSPLITVIEWCONTROLLER_MASTERVIEW_IN_LANDSCAPE_WIDTH, ITSPLITVIEWCONTROLLER_LANDSCAPE_HEIGHT);
            detailContainerView.frame = CGRectMake(masterContainerView.frame.size.width + 1, 0, ITSPLITVIEWCONTROLLER_DETAILVIEW_IN_LANDSCAPE_WIDTH, ITSPLITVIEWCONTROLLER_LANDSCAPE_HEIGHT);
            primaryMasterView.frame = CGRectMake(0, 0, masterContainerView.frame.size.width, masterContainerView.frame.size.height);
            secondaryMasterView.frame = CGRectMake(0, 0, masterContainerView.frame.size.width, masterContainerView.frame.size.height);
            detailView.frame = CGRectMake(0, 0, detailContainerView.frame.size.width, detailContainerView.frame.size.height);
            
            //If we were coming from master we need to add the detail view, else add master view
            if(currentState == ITSplitViewControllerMaster)
            {
                [detailContainerView addSubview:detailView];
                [containerView addSubview:detailContainerView];
            }
            else
            {
                [containerView addSubview:masterContainerView];
            }
            //Change state to reflect being in split
            currentState = ITSplitViewControllerSplit;
        }
        return YES;
    }
    else
    {
        return NO;
    }
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                duration:(NSTimeInterval)duration
{
    //Inform delegate of rotation
    if(delegate)
    {
        [delegate splitViewController:self 
              willRotateToOrientation:toInterfaceOrientation];
    }
    //If it is ipad going to portrait set up the views correctly
    if(ITSPLITVIEWCONTROLLER_ISIPAD && UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        //Turn all resizing masks back on
        masterContainerView.autoresizingMask = ITSPLITVIEWCONTROLLER_CONTAINER_AUTORESIZE_MASK;
        detailContainerView.autoresizingMask = ITSPLITVIEWCONTROLLER_CONTAINER_AUTORESIZE_MASK;
        primaryMasterView.autoresizingMask = ITSPLITVIEWCONTROLLER_CONTAINER_AUTORESIZE_MASK;
        secondaryMasterView.autoresizingMask = ITSPLITVIEWCONTROLLER_CONTAINER_AUTORESIZE_MASK;
        detailView.autoresizingMask = ITSPLITVIEWCONTROLLER_CONTAINER_AUTORESIZE_MASK;
        detailView.autoresizingMask = ITSPLITVIEWCONTROLLER_CONTAINER_AUTORESIZE_MASK;
        detailView.autoresizesSubviews = YES;
        masterContainerView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
        detailContainerView.frame = CGRectMake(masterContainerView.frame.size.width, 0, containerView.frame.size.width, containerView.frame.size.height);
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //If we are now in portrait, we must remove detail or master depending on default state to display
    if(ITSPLITVIEWCONTROLLER_ISIPAD && UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {
        //Remove correct view and set current state accordingly
        if(defaultStateToDisplay == ITSplitViewControllerMaster)
        {
            currentState = ITSplitViewControllerMaster;
            [detailView removeFromSuperview];
            [detailContainerView removeFromSuperview];
        }
        else
        {
            currentState = ITSplitViewControllerDetail;
            [masterContainerView removeFromSuperview];
        }
    }
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    //Create all views with proper frames
    [self setView:[[UIView alloc]initWithFrame:[[UIScreen mainScreen] applicationFrame]]];
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    masterContainerView = [[UIView alloc] initWithFrame:containerView.frame];
    detailContainerView = [[UIView alloc] initWithFrame:containerView.frame];
    primaryMasterView.frame = containerView.frame;
    secondaryMasterView.frame = containerView.frame;
    
    //Set all resizing masks
    self.view.autoresizingMask = ITSPLITVIEWCONTROLLER_CONTAINER_AUTORESIZE_MASK;
    masterContainerView.autoresizingMask = ITSPLITVIEWCONTROLLER_CONTAINER_AUTORESIZE_MASK;
    detailContainerView.autoresizingMask = ITSPLITVIEWCONTROLLER_CONTAINER_AUTORESIZE_MASK;
    containerView.autoresizingMask = ITSPLITVIEWCONTROLLER_CONTAINER_AUTORESIZE_MASK;
    primaryMasterView.autoresizingMask = ITSPLITVIEWCONTROLLER_CONTAINER_AUTORESIZE_MASK;
    secondaryMasterView.autoresizingMask = ITSPLITVIEWCONTROLLER_CONTAINER_AUTORESIZE_MASK;
    
    //Set auto resize for all subviews
    self.view.autoresizesSubviews = YES;
    masterContainerView.autoresizesSubviews = YES;
    detailContainerView.autoresizesSubviews = YES;
    containerView.autoresizesSubviews = YES;
    primaryMasterView.autoresizesSubviews = YES;
    secondaryMasterView.autoresizesSubviews = YES;
    
    //If it is an iPad round all the corners
    if(ITSPLITVIEWCONTROLLER_ISIPAD)
    {
        primaryMasterView.layer.masksToBounds = YES;
        [primaryMasterView.layer setCornerRadius:ITSPLITVIEWCONTROLLER_CORNER_RADIUS];
        
        secondaryMasterView.layer.masksToBounds = YES;
        [secondaryMasterView.layer setCornerRadius:ITSPLITVIEWCONTROLLER_CORNER_RADIUS];
    }
    
    //Add all subviews, assuming primaryMaster is the start
    [masterContainerView addSubview:primaryMasterView];
    [containerView addSubview:masterContainerView];
    [[self view] addSubview:containerView];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    primaryMasterView = nil;
    secondaryMasterView = nil;
    detailView = nil;
    masterContainerView = nil;
    detailContainerView = nil;
    containerView = nil;
    self.view = nil;
}

@end
