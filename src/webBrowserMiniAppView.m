//
//  webBrowserMiniAppView.m
//  Paductivity
//
//  Created by William Alexander on 20/10/2010.
//  Copyright 2010 Framestore-CFC. All rights reserved.
//

#import "webBrowserMiniAppView.h"

#import <QuartzCore/CALayer.h>


@implementation UITextField_subclass

- (BOOL)becomeFirstResponder
{
	[self.superview urlEntryViewDidBecomeFirstResponder];
	return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
	[self.superview urlEntryViewDidResignFirstResponder];
	return [super resignFirstResponder];
}


@end



@implementation webBrowserMiniAppView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		
		/*no need for multi-touch*/
		[self setMultipleTouchEnabled: NO];
		
		/*background is bluish grey:*/
		self.backgroundColor = [UIColor colorWithRed: 0.7 green: 0.7 blue: 0.7 alpha: 1.0];
		
		/*create webview subview to fill this view:*/
		webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 51, frame.size.width, frame.size.height - 51)];
		[webView setScalesPageToFit: YES];
		[webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: [NSString stringWithUTF8String:"http://www.google.com"]]]];
	
		[webView setDelegate:self];
		[self addSubview: webView];
		
		
		/*create a simple layer , the 'proxy', displaying a carbon copy of the web view's page content, that will replace the real web view when scaling this view:*/
		webViewProxy = [CALayer layer];
		[webViewProxy setFrame: CGRectMake(0, 51, frame.size.width, frame.size.height - 51)];
		[webViewProxy removeAllAnimations];
		
		[webViewProxy setHidden: YES];
		
		[[self layer] addSublayer: webViewProxy];
		
		webViewProxyAnim_pos = [CABasicAnimation animationWithKeyPath: @"position"];
		[webViewProxyAnim_pos setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[webViewProxyAnim_pos retain];
		webViewProxyAnim_bounds = [CABasicAnimation animationWithKeyPath: @"bounds"];
		[webViewProxyAnim_bounds setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[webViewProxyAnim_bounds retain];
		
		[webViewProxy setHidden: YES];
		
		
		/*create a subtle translucent layer to cover the web view when it's loading a page (so that the user realises this):*/
		webLoadingCover = [CALayer layer];
		[webLoadingCover setBackgroundColor: [[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha: 0.0] CGColor]];
		[webLoadingCover setFrame: CGRectMake(0, 51, frame.size.width, frame.size.height - 51)];
		[webLoadingCover setHidden: YES];
		[[self layer] addSublayer: webLoadingCover];
		
		webLoadingCoverAnim_pos = [CABasicAnimation animationWithKeyPath: @"position"];
		[webLoadingCoverAnim_pos setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[webLoadingCoverAnim_pos retain];
		webLoadingCoverAnim_bounds = [CABasicAnimation animationWithKeyPath: @"bounds"];
		[webLoadingCoverAnim_bounds setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[webLoadingCoverAnim_bounds retain];
		
		
		/*create a rotating indicator view to help indicate to the viewer when a web page is loading:*/
		webLoadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(300, 300, 20, 20) ];
		[webLoadingIndicator setPosition: CGPointMake((int)(0.5 * frame.size.width), 51 + (int)(0.5 * (frame.size.height - 51)))];
		[webLoadingIndicator startAnimating];
		[self addSubview: webLoadingIndicator];
		
		/*create the URL entry field:*/
		URLEntryView = [[UITextField_subclass alloc] initWithFrame: CGRectMake(71, 12, frame.size.width - 144, 28)];
		
		[URLEntryView setBorderStyle: UITextBorderStyleRoundedRect];
		[URLEntryView setKeyboardType:UIKeyboardTypeURL];
		[URLEntryView setAutocapitalizationType: UITextAutocapitalizationTypeNone];
		[URLEntryView setAutocorrectionType: UITextAutocorrectionTypeNo];
		[URLEntryView setReturnKeyType: UIReturnKeyGo];
		[URLEntryView setText: [NSString stringWithUTF8String: "http://www.google.com"]];
		
		[URLEntryView setDelegate:self];
		[self addSubview: URLEntryView];
		
		
		/*create the back, forward and reload buttons as CALayers and create animation objects to amimate them:*/
		[self createButtonGraphics];
		
		backButton = [CALayer layer];
		[backButton setFrame: CGRectMake(5, 12, 28, 28)];
		[backButton setCornerRadius: 5];
		[backButton setMasksToBounds: YES];
		[backButton setContents: (id)buttonGraphics_back_off];
		
		forwardButton = [CALayer layer];
		[forwardButton setFrame: CGRectMake(38, 12, 28, 28)];
		[forwardButton setCornerRadius: 5];
		[forwardButton setMasksToBounds: YES];
		[forwardButton setContents: (id)buttonGraphics_forward_off];
		
		stopButton = [CALayer layer];
		[stopButton setFrame: CGRectMake(frame.size.width - 68, 12, 28, 28)];
		[stopButton setCornerRadius: 5];
		[stopButton setMasksToBounds: YES];
		[stopButton setContents: (id)buttonGraphics_stop_off];
		
		reloadButton = [CALayer layer];
		[reloadButton setFrame: CGRectMake(frame.size.width - 35, 12, 28, 28)];
		[reloadButton setCornerRadius: 5];
		[reloadButton setMasksToBounds: YES];
		[reloadButton setContents: (id)buttonGraphics_reload_off];
	
		
		[[self layer] addSublayer: backButton];
		[[self layer] addSublayer: forwardButton];
		[[self layer] addSublayer: stopButton];
		[[self layer] addSublayer: reloadButton];
		
		backButtonAnim_pos = [CABasicAnimation animationWithKeyPath: @"position"];
		[backButtonAnim_pos setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[backButtonAnim_pos retain];
		backButtonAnim_bounds = [CABasicAnimation animationWithKeyPath: @"bounds"];
		[backButtonAnim_bounds setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[backButtonAnim_bounds retain];
		
		forwardButtonAnim_pos = [CABasicAnimation animationWithKeyPath: @"position"];
		[forwardButtonAnim_pos setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[forwardButtonAnim_pos retain];
		forwardButtonAnim_bounds = [CABasicAnimation animationWithKeyPath: @"bounds"];
		[forwardButtonAnim_bounds setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[forwardButtonAnim_bounds retain];
		
		stopButtonAnim_pos = [CABasicAnimation animationWithKeyPath: @"position"];
		[stopButtonAnim_pos setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[stopButtonAnim_pos retain];
		stopButtonAnim_bounds = [CABasicAnimation animationWithKeyPath: @"bounds"];
		[stopButtonAnim_bounds setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[stopButtonAnim_bounds retain];
		
		reloadButtonAnim_pos = [CABasicAnimation animationWithKeyPath: @"position"];
		[reloadButtonAnim_pos setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[reloadButtonAnim_pos retain];
		reloadButtonAnim_bounds = [CABasicAnimation animationWithKeyPath: @"bounds"];
		[reloadButtonAnim_bounds setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[reloadButtonAnim_bounds retain];
	
		
		
		/*create the background image for the view.*/
		[self generateBackgroundContent];
		
		
		/*set some initial values:*/
		buttonDown = -1;
		shiftEventInProgress = 0;
		webLoadingInProgress = 0;
		
		disableManualLayout = 0;
		
		
		/*to give the view nice rounded corners, access underlying CALayer, and set it to have rounded corners:*/
		[[self layer] setCornerRadius: 5.0];
		[[self layer] setMasksToBounds: YES];
    }
    return self;
}


/*************************************************************************************************************
 
	VARIOUS CUSTOM METHODS FOR CREATING AND UPDATING GRAPHICS:
 
 *************************************************************************************************************/

/*
 generateBackgroundContent - this will called only once, right at the beginning when the mini app is created. Once the background has been genereated, it can be scaled and translated without needing to be redrawn:
 */
- (void)generateBackgroundContent
{
	/*create a bitmap the same size as the view bounds:*/
	CGContextRef backgroundBitmapContext = CGBitmapContextCreate(NULL, self.bounds.size.width, self.bounds.size.height, 8, self.bounds.size.width*4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
	
	/*draw nice gradient for toolbar:*/
	CGGradientRef controlBarGradient;
	CGFloat controlBarGradLocs[] = {0.0, 1.0};
	CGFloat controlBarGradComps[] = {0.8, 0.8, 0.8, 1.0, 0.6, 0.6, 0.6, 1.0};
	
	controlBarGradient = CGGradientCreateWithColorComponents(CGColorSpaceCreateDeviceRGB(), controlBarGradComps, controlBarGradLocs, 2);
	CGContextDrawLinearGradient(backgroundBitmapContext, controlBarGradient, CGPointMake(0.0, self.bounds.size.height), CGPointMake(0.0, self.bounds.size.height - 50.0), kCGGradientDrawsAfterEndLocation);
	
	/*draw a dark grey line to divide the control bar from the content area:*/
	CGContextSetRGBFillColor(backgroundBitmapContext, 0.5, 0.5, 0.5, 1.0);
	CGContextFillRect(backgroundBitmapContext, CGRectMake(0, self.bounds.size.height - 51.0, self.bounds.size.width, 1));
	
	
	CGImageRef backgroundBitmapImage = CGBitmapContextCreateImage(backgroundBitmapContext);
	[[self layer] setContents: (id)(backgroundBitmapImage)];
	
	
	/*to ensure that the top tool bar graphic area stays the same size whatever the view bounds, set the layer to scale everything else down except the toolbar area:*/
	[[self layer] setContentsCenter: CGRectMake(0.0, (60.0 / self.bounds.size.height), self.bounds.size.width, 1.0 - (60.0 / self.bounds.size.height))];
	
	/*release bitmap context and image:*/
	CGGradientRelease(controlBarGradient);
	CGContextRelease(backgroundBitmapContext);
	CGImageRelease(backgroundBitmapImage);
}


/*
 createButtonGraphics - loads up the resource images for buttons, and saves them into member variables:
 */
- (void)createButtonGraphics
{
	buttonGraphics_back_off = [utilities openCGResourceImage: @"backButton_off" ofType: @"png"];
	buttonGraphics_back_on = [utilities openCGResourceImage: @"backButton_on" ofType: @"png"];
	buttonGraphics_forward_off = [utilities openCGResourceImage: @"forwardButton_off" ofType: @"png"];
	buttonGraphics_forward_on = [utilities openCGResourceImage: @"forwardButton_on" ofType: @"png"];
	buttonGraphics_stop_off = [utilities openCGResourceImage: @"stopButton_off" ofType: @"png"];
	buttonGraphics_stop_on = [utilities openCGResourceImage: @"stopButton_on" ofType: @"png"];
	buttonGraphics_reload_off = [utilities openCGResourceImage: @"reloadButton_off" ofType: @"png"];
	buttonGraphics_reload_on = [utilities openCGResourceImage: @"reloadButton_on" ofType: @"png"];
}


/*
	a simple procedure for defining a very particular gradient function for the 'web loading gradient'
 */
static void myCalculateShadingValues(void *info, const float *in, float *out)
{
	float v;
	size_t k, components;
	static const float c_1[] = {0, 0, 0, 1};
	static const float c_2[] = {0, 0, 0, 0};
	
	components = (size_t)info;
	
	v = *in;
	
	v = sqrt(sqrt(v));
	v = 0.1 + 0.7 * v;
	
	for(k = 0; k < components; k++)
		*out++ = (1.0 - v) * c_1[k] + v * c_2[k];
}


/*
	drawWebLoadingCoverGradient - uses func above to create the radial gradient graphic to be displayed when the web view is loading a page:
 */
- (void)drawWebLoadingCoverGradient
{
	CGContextRef bitmapContext = CGBitmapContextCreate(NULL, [webView frame].size.width, [webView frame].size.height, 8, 4 * [webView frame].size.width, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
	
	CGPoint startPoint, endPoint;
	CGAffineTransform myTransform;
	
	float width = [webView frame].size.width;
	float height = [webView frame].size.height;
	
	startPoint = CGPointMake(0.5, 0.5);
	endPoint = CGPointMake(0.5, 0.5);
	
	CGColorSpaceRef myColorSpace = CGColorSpaceCreateDeviceRGB();
	
	size_t components;
	static const float input_value_range[2] = {0.0, 1.0};
	static const float output_value_ranges[8] = {0, 1, 0, 1, 0, 1, 0, 1};
	static const CGFunctionCallbacks callbacks = {0, &myCalculateShadingValues, NULL};
	
	components = 1 + CGColorSpaceGetNumberOfComponents(myColorSpace);
	
	CGFunctionRef myShadingFunction = CGFunctionCreate((void *)components, 1, input_value_range, components, output_value_ranges, &callbacks);
	
	
	CGShadingRef shading = CGShadingCreateRadial(myColorSpace, startPoint, 0.707, endPoint, 0.0, myShadingFunction, true, true);
	
	myTransform = CGAffineTransformMakeScale(width, height);
	CGContextConcatCTM(bitmapContext, myTransform);
	CGContextSaveGState(bitmapContext);
	
	CGContextClipToRect(bitmapContext, CGRectMake(0, 0, 1, 1));
	
	CGContextDrawShading(bitmapContext, shading);
	CGColorSpaceRelease(myColorSpace);
	
	CGContextRestoreGState(bitmapContext);
	
	CGImageRef myImage = CGBitmapContextCreateImage(bitmapContext);
	[webLoadingCover setContents: (id)myImage];
	
	/*release the allocated graphics:*/
	CGContextRelease(bitmapContext);
	CGImageRelease(myImage);
	CGShadingRelease(shading);
	CGFunctionRelease(myShadingFunction);
}


/*
	carbonCopyWebViewContents - takes the current web view content and copies it out as a bitmap to the 'webViewProxy' layer:
 */
- (void)carbonCopyWebViewContents
{
	CGContextRef bitmapContext = CGBitmapContextCreate(NULL, [webView frame].size.width, [webView frame].size.height, 8, 4 * [webView frame].size.width, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
	
	CGContextScaleCTM(bitmapContext, 1.0, -1.0);
	CGContextTranslateCTM(bitmapContext, 0.0, -1.0 * [webView frame].size.height);
	
	[[webView layer] renderInContext: bitmapContext];
	
	CGImageRef bitmapContextImage = CGBitmapContextCreateImage(bitmapContext);
	[webViewProxy setContents: (id)bitmapContextImage];
	
	/*gargage collection:*/
	CGContextRelease(bitmapContext);
	CGImageRelease(bitmapContextImage);
}


/*
	setButtonStates - simply uses the current state of the web view to determine which of the back, forward, stop and reload buttons should be enabled:
 */
- (void)setButtonStates
{
	/*back button is only active if the web view is able to go backward:*/
	if([webView canGoBack] == YES) [backButton setOpacity: 1.0];
	else [backButton setOpacity: 0.5];
	[backButton removeAllAnimations];
	
	/*forward button is only active if the web view is able to go forward:*/
	if([webView canGoForward] == YES) [forwardButton setOpacity: 1.0];
	else [forwardButton setOpacity: 0.5];
	[forwardButton removeAllAnimations];
}


-(void)layoutSubviews
{
	if(disableManualLayout == 1) return;
	
	[super layoutSubviews];
	
	/*If this is a new, settled, shape for the view after an event, then redraw everything:*/
	if(shiftEventInProgress == 0)
	{	
		[webView setFrame: CGRectMake(0, 51, self.bounds.size.width, self.bounds.size.height - 51)];
		[webLoadingCover setFrame: CGRectMake(0, 51, self.bounds.size.width, self.bounds.size.height - 51)];
		[self drawWebLoadingCoverGradient];
		[webLoadingIndicator setPosition: CGPointMake((int)(0.5 * self.bounds.size.width), 51 + (int)(0.5 * (self.bounds.size.height - 51)))];
		
		/*web view proxy simply fills the space available for the web view:*/
		[webViewProxy setFrame: CGRectMake(0, 51, self.bounds.size.width, self.bounds.size.height - 51)];
		[webViewProxy removeAllAnimations];
		
		/*now we're done with all this heavy drawing, notify the main parent view:*/
		[rootPanelView miniAppViewDidFinishRedrawingInSettledFrame: self];
	}
	
	/*however, if there's a shift event in progress then update the position and scale of the web cover layer and the loading indicator:*/
	if(shiftEventInProgress == 1)
	{
		/*if the new bounds the user has moved the view to is smaller than when the shift event started, then keep the web view proxy a static size and position it in the centre of the space available:*/
		if((self.bounds.size.width < webViewSizeAtStartOfShiftEvent.width)||(self.bounds.size.height < webViewSizeAtStartOfShiftEvent.height))
		{
			[webViewProxy setPosition: CGPointMake((int)(0.5 * [webViewProxy bounds].size.width), (int)(51 + 0.5 * ([webViewProxy bounds].size.height)))];
			[webViewProxy removeAllAnimations];
		}
		
		/*if its larger, then fix the proxy view in the top left hand corner:*/
		else 
		{
			[webViewProxy setPosition: CGPointMake((int)(0.5 * self.bounds.size.width), (int)(51 + 0.5 * (self.bounds.size.height - 51)))];
			[webViewProxy removeAllAnimations];
		}
			
		/*if the web view was loading a page then update the web loading cover/info graphics as well:*/
		if(webLoadingInProgress == 1)
		{
			[webLoadingCover setFrame: CGRectMake(0, 51, self.bounds.size.width, self.bounds.size.height - 51)];
			[webLoadingCover removeAllAnimations];
			
			[webLoadingIndicator setPosition: CGPointMake((int)(0.5 * self.bounds.size.width), 51 + (int)(0.5 * (self.bounds.size.height - 51)))];
		}
	}


	/*update url entry field:*/
	[URLEntryView setFrame: CGRectMake(71, 12, self.bounds.size.width - 144, 28)];
	
	/*position buttons:*/
	[backButton setFrame: CGRectMake(5, 12, 28, 28)];
	[forwardButton setFrame: CGRectMake(38, 12, 28, 28)];
	[stopButton setFrame: CGRectMake(self.bounds.size.width - 68, 12, 28, 28)];
	[reloadButton setFrame: CGRectMake(self.bounds.size.width - 35, 12, 28, 28)];
	[stopButton removeAllAnimations];
	[reloadButton removeAllAnimations];
	
	[self setButtonStates];

	/*in general, if the height of the view dips below 60px, make sure that the main layer stays fixed at 60 to avoid scaling its graphics:*/
	if(self.bounds.size.height < 60.0)
	{
		CGRect layerFrame = [[self layer] frame];
		[[self layer] setFrame: CGRectMake(layerFrame.origin.x, layerFrame.origin.y, layerFrame.size.width, 60.0)];
	}
}



/*
	the hitTestOverride method returns 1 if the point given is in one of those few areas that are so important (e.g back/forward/reload buttons) that they must override any border controls and for the event to be handled here in this view rather than in the parent view
 */
- (int)hitTestOverride:(CGPoint)point
{
	/*point inside the back button?*/
	if((point.x >= backButton.frame.origin.x)&&(point.x <= (backButton.frame.origin.x + backButton.frame.size.width))&&(point.y >= backButton.frame.origin.y)&&(point.y <= (backButton.frame.origin.y + backButton.frame.size.height)))
		return 1;
	
	/*point inside the forward button?*/
	if((point.x >= forwardButton.frame.origin.x)&&(point.x <= (forwardButton.frame.origin.x + forwardButton.frame.size.width))&&(point.y >= forwardButton.frame.origin.y)&&(point.y <= (forwardButton.frame.origin.y + forwardButton.frame.size.height)))
		return 1;
	
	/*point inside the stop button?*/
	if((point.x >= stopButton.frame.origin.x)&&(point.x <= (stopButton.frame.origin.x + stopButton.frame.size.width))&&(point.y >= stopButton.frame.origin.y)&&(point.y <= (stopButton.frame.origin.y + stopButton.frame.size.height)))
		return 1;
	
	/*point inside the reload button?*/
	if((point.x >= reloadButton.frame.origin.x)&&(point.x <= (reloadButton.frame.origin.x + reloadButton.frame.size.width))&&(point.y >= reloadButton.frame.origin.y)&&(point.y <= (reloadButton.frame.origin.y + reloadButton.frame.size.height)))
		return 1;
	
	return 0;
}


/*
 These are the methods for handling touch events:
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint touchPos = [[touches anyObject] locationInView: self];
	
	/*did the user touch down any of the buttons? if so record it, and change the button to the 'on' state:*/
	if((touchPos.x >= backButton.frame.origin.x)&&(touchPos.x <= (backButton.frame.origin.x + backButton.frame.size.width))&&(touchPos.y >= backButton.frame.origin.y)&&(touchPos.y <= (backButton.frame.origin.y + backButton.frame.size.height)))
	{
		[backButton setContents: (id)buttonGraphics_back_on];
		[backButton removeAllAnimations];
		
		buttonDown = 0;
	}
	
	if((touchPos.x >= forwardButton.frame.origin.x)&&(touchPos.x <= (forwardButton.frame.origin.x + forwardButton.frame.size.width))&&(touchPos.y >= forwardButton.frame.origin.y)&&(touchPos.y <= (forwardButton.frame.origin.y + forwardButton.frame.size.height)))
	{
		[forwardButton setContents: (id)buttonGraphics_forward_on];
		[forwardButton removeAllAnimations];
		
		buttonDown = 1;
	}
	
	if((touchPos.x >= stopButton.frame.origin.x)&&(touchPos.x <= (stopButton.frame.origin.x + stopButton.frame.size.width))&&(touchPos.y >= stopButton.frame.origin.y)&&(touchPos.y <= (stopButton.frame.origin.y + stopButton.frame.size.height)))
	{
		[stopButton setContents: (id)buttonGraphics_stop_on];
		[stopButton removeAllAnimations];
		
		buttonDown = 2;
	}
	
	if((touchPos.x >= reloadButton.frame.origin.x)&&(touchPos.x <= (reloadButton.frame.origin.x + reloadButton.frame.size.width))&&(touchPos.y >= reloadButton.frame.origin.y)&&(touchPos.y <= (reloadButton.frame.origin.y + reloadButton.frame.size.height)))
	{
		[reloadButton setContents: (id)buttonGraphics_reload_on];
		[reloadButton removeAllAnimations];
		
		buttonDown = 3;
	}
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint touchPos = [[touches anyObject] locationInView:self];
	
	/*if the user has tapped the URL entry bar, then enable typing into it:*/
	if((touchPos.x >= 70)&&(touchPos.x <= (self.frame.size.width - 105))&&(touchPos.y >= 12)&&(touchPos.y <= 28))
	{
		[URLEntryView becomeFirstResponder];
	}
	
	/*if the user has lifted a finger that was on a button, then carry out that button's function (if the button is active) and return it to its 'off' state:*/
	if(buttonDown == 0)
	{
		[backButton setContents: (id)buttonGraphics_back_off];
		[backButton removeAllAnimations];
	
		[webView goBack];
	}
	if(buttonDown == 1)
	{
		[forwardButton setContents: (id)buttonGraphics_forward_off];
		[forwardButton removeAllAnimations];
		
		[webView goForward];
	}
	if(buttonDown == 2)
	{
		[stopButton setContents: (id)buttonGraphics_stop_off];
		[stopButton removeAllAnimations];
		
		[webView stopLoading];
		
		
		[self webViewDidFinishLoad: nil];
	}
	if(buttonDown == 3)
	{
		[reloadButton setContents: (id)buttonGraphics_reload_off];
		[reloadButton removeAllAnimations];
		
		[webView reload];
	}
	buttonDown = -1;
}




/*******************************************************************************************************************
 
 METHODS RELATING TO EXEMPTION
 
 ********************************************************************************************************************/

/*
	this method will be called by the url entry view when it becomes the first responder
 */
- (void)urlEntryViewDidBecomeFirstResponder
{
	/*If the text view has just become first responder here, and therefore the keyboard has appeared, then check to see whether we need to move this view and exempt it. If we're already in text entry mode and this call is spurious, then do nothing:*/
	if(viewIsCurrentlyExempted == 0)
	{
		/*Find out from the parent panel view what orientation the app is currently in:*/
		int currentAppOrientation = [self.superview getCurrentAppOrientation];
		
		CGPoint newCenter = [self determineWhetherViewNeedsToBeExemptedInHypotheticalSituation: [self.superview getCurrentAppOrientation] center: self.center bounds: self.bounds];
		
		if(newCenter.x != -1)
		{
			/*call the parent panel view to request that this view be given a special position (after 0.3 seconds to allow the keyboard to appear first):*/
			NSMutableArray *paramArray = [[NSMutableArray alloc] initWithCapacity: 2];
			[paramArray addObject: self];
			[paramArray addObject: [NSNumber numberWithFloat: newCenter.x]];
			[paramArray addObject: [NSNumber numberWithFloat: newCenter.y]];
			
			[NSTimer scheduledTimerWithTimeInterval: 0.3 target: rootPanelView selector: @selector(requestMiniAppViewExemption:) userInfo: paramArray repeats: NO];
		}
	}
}


/*
 if this view is about to be reoriented, it is possible that, if currently the first responder, it might still need to be exempted in the new orientation:
 */
- (BOOL)shouldViewBeExemptedInHypotheticalOrientation: (int)hypoOrientation center: (CGPoint)hypoCenter bounds: (CGRect)hypoBounds withNewCenter: (CGPoint *)newCenter_out
{
	if([URLEntryView isFirstResponder])
	{
		*newCenter_out = [self determineWhetherViewNeedsToBeExemptedInHypotheticalSituation: hypoOrientation center: hypoCenter bounds: hypoBounds];
		
		if(newCenter_out->x != -1) return YES;
	}
	
	return NO;
}


/*
	determineWhetherViewNeedsToBeExemptedInHypotheticalSituation - asks the question: if the device had a given orientation, and this view had a given size and shape, would it need to be exempted?
 */
- (CGPoint)determineWhetherViewNeedsToBeExemptedInHypotheticalSituation: (int)hypoOrientation center: (CGPoint)hypoCenter bounds: (CGRect)hypoBounds
{	
	
	CGSize appRect, keyboardRect, freeSpaceRect;
	CGPoint viewCenter;
	
	/*given the hypothetical orientation, we can know what the app's total screen space is, the space the keyboard takes up and the space left over:*/
	if((hypoOrientation == 0)||(hypoOrientation == 2))
	{
		appRect = CGSizeMake(768, 1004);
		keyboardRect = CGSizeMake(768, 264);
		freeSpaceRect = CGSizeMake(768, 760);
		
		if(hypoOrientation == 0) viewCenter = hypoCenter;
		else viewCenter = CGPointMake(768 - hypoCenter.x, 1024 - hypoCenter.y);
	}
	
	else
	{
		appRect = CGSizeMake(1024, 748);
		keyboardRect = CGSizeMake(1024, 352);
		freeSpaceRect = CGSizeMake(1024, 416);
		
		if(hypoOrientation == 1) viewCenter = CGPointMake(hypoCenter.y, 768 - hypoCenter.x);
		else viewCenter = CGPointMake(1024 - hypoCenter.y, hypoCenter.x);
	}
	
	/*how far does the app stick out above the keyboard?*/
	float pixelDistOfViewAboveKeyboard = freeSpaceRect.height - (viewCenter.y - 0.5 * hypoBounds.size.height);
	
	/*If less than 50px is exposed above the keyboard, the url entry field is not entirely visible, so we will shift this view upwards to allow this*/
	if(pixelDistOfViewAboveKeyboard < 50)
	{
		float amountToShiftBy = 50.0 - pixelDistOfViewAboveKeyboard;
			
		CGPoint newCenter;
		if(hypoOrientation == 0) newCenter = CGPointMake(hypoCenter.x, hypoCenter.y - amountToShiftBy);
		if(hypoOrientation == 1) newCenter = CGPointMake(hypoCenter.x + amountToShiftBy, hypoCenter.y);
		if(hypoOrientation == 2) newCenter = CGPointMake(hypoCenter.x, hypoCenter.y + amountToShiftBy);
		if(hypoOrientation == 3) newCenter = CGPointMake(hypoCenter.x - amountToShiftBy, hypoCenter.y);
		
		return newCenter;
	}
	
	return CGPointMake(-1, -1);
}	


/*
 keyboard callback for when keyboard is dismissed
 */
- (void)urlEntryViewDidResignFirstResponder
{
	[rootPanelView endMiniAppViewExemption];
}


/*
 miniAppViewExemptionWillStart - at this point, we'll shift the text view so that it only fills the visible area above the keyboard:
 */
//- (void)miniAppViewExemptionWillStart
//{
//	viewIsCurrentlyExempted = 1;
//}

/*
 miniAppViewExemptionWillEnd - at this point, we'll return the text view so that it fills the whole area of the view:
 */
//- (void)miniAppViewExemptionWillEnd
//{
//	viewIsCurrentlyExempted = 0;
//	[textView setFrame: CGRectMake([textView frame].origin.x, [textView frame].origin.y, [textView frame].size.width, [self bounds].size.height)];
//}




/*******************************************************************************************************************
 
 VARIOUS MINI APP - SPECIFIC IMPLEMENTATIONS OF STANDARD TRANSFORMATION METHODS PLUS EXTRA RELATED METHODS
 
 ********************************************************************************************************************/

/*
	if a shift event is about to begin, this method will be called.
	Replace the active web view with a simple layer that displays the web view's latest content. This will *dramatically* speed up any resizing:
 */
- (void)shiftEventBegins
{
	/*if the web view is currently in the process of loading a page, then stop it.*/
	if(webLoadingInProgress == 1) [webView stopLoading];
	
	/*to make scaling of this mini app nice and light, make a proxy flat copy of the loaded web view to have as a layer:*/
	[self carbonCopyWebViewContents];
	
	/*keep a record of the size of the web view just before the shifting starts:*/
	webViewSizeAtStartOfShiftEvent = [self bounds].size;
	
	[webView setHidden: YES];
	
	[webViewProxy setHidden: NO];
	[webViewProxy removeAllAnimations];
	
	
	shiftEventInProgress = 1;
}


- (void)shiftEventEnded
{
	/*hide the static proxy view and show the true web view again:*/
	[webView setHidden: NO];
	
	[webViewProxy setHidden: YES];
	[webViewProxy removeAllAnimations];
	
	shiftEventInProgress = 0;
	[self setNeedsLayout];
	
	/*if the web view was loading a page, then tell it to start again:*/
	if(webLoadingInProgress == 1) [webView reload];
}


- (void)animateChangeOfBoundsAndCenter: (float)duration toBounds: (CGRect)newBounds andCenter: (CGPoint)newCenter;
{
	/*switch off all layout during animations, starting now:*/
	disableManualLayout = 1;
	
	/*set off the buttons that need to move and address bar to animate to their positions in the new bounds:*/
	CGPoint stopButtonPos_old = [stopButton position];
	CGPoint stopButtonPos_new = CGPointMake(newBounds.size.width - 54, 26);
	CGPoint reloadButtonPos_old = [reloadButton position];
	CGPoint reloadButtonPos_new = CGPointMake(newBounds.size.width - 21, 26);
	
	[stopButtonAnim_pos setDuration: duration];
	[stopButtonAnim_pos setFromValue: [NSValue value: &stopButtonPos_old withObjCType: @encode(CGPoint)]];
	[stopButtonAnim_pos setToValue: [NSValue value: &stopButtonPos_new withObjCType: @encode(CGPoint)]];
	[reloadButtonAnim_pos setDuration: duration];
	[reloadButtonAnim_pos setFromValue: [NSValue value: &reloadButtonPos_old withObjCType: @encode(CGPoint)]];
	[reloadButtonAnim_pos setToValue: [NSValue value: &reloadButtonPos_new withObjCType: @encode(CGPoint)]];
	
	[stopButton setPosition: stopButtonPos_new];
	[stopButton addAnimation: stopButtonAnim_pos forKey: @"position"];
	[reloadButton setPosition: reloadButtonPos_new];
	[reloadButton addAnimation: reloadButtonAnim_pos forKey: @"position"];
	
	[UIView animateWithDuration: duration animations: ^{ [URLEntryView setFrame: CGRectMake(71, 12, newBounds.size.width - 144, 28)]; }];
	
	
	/*As with a shift event, use the web view proxy:*/
	if(webLoadingInProgress == 1)
	{
		/*if web loading is in progress, then stop it. but also set up the loading cover elements to animate correctly into their new positions:*/
		[webView stopLoading];
		
		CGPoint webLoadingCoverPos_old = [webLoadingCover position];
		CGRect webLoadingCoverBounds_old = [webLoadingCover bounds];
		CGPoint webLoadingCoverPos_new = CGPointMake((int)(0.5 * newBounds.size.width), (int)(51 + 0.5 * (newBounds.size.height - 51)));
		CGRect webLoadingCoverBounds_new = CGRectMake(0, 0, newBounds.size.width, newBounds.size.height - 50);
		
		[webLoadingCoverAnim_pos setDuration: duration];
		[webLoadingCoverAnim_pos setFromValue: [NSValue value: &webLoadingCoverPos_old withObjCType: @encode(CGPoint)]];
		[webLoadingCoverAnim_pos setToValue: [NSValue value: &webLoadingCoverPos_new withObjCType: @encode(CGPoint)]];
		[webLoadingCoverAnim_bounds setDuration: duration];
		[webLoadingCoverAnim_bounds setFromValue: [NSValue value: &webLoadingCoverBounds_old withObjCType: @encode(CGRect)]];
		[webLoadingCoverAnim_bounds setToValue: [NSValue value: &webLoadingCoverBounds_new withObjCType: @encode(CGRect)]];
		
		[webLoadingCover setPosition: webLoadingCoverPos_new];
		[webLoadingCover setBounds: webLoadingCoverBounds_new];
		[webLoadingCover addAnimation: webLoadingCoverAnim_pos forKey: @"position"];
		[webLoadingCover addAnimation: webLoadingCoverAnim_bounds forKey: @"bounds"];
				
		[UIView animateWithDuration: duration animations: ^{ [webLoadingIndicator setPosition: webLoadingCoverPos_new]; } ];
	}
		
	
	[self carbonCopyWebViewContents];
	[webViewProxy setHidden: NO];
	[webViewProxy removeAllAnimations];
	[webView setHidden: YES];
	

	
	/*If the new bounds are smaller than the present ones, then don't animate the web view proxy - just keep it pinned to the top left corner. If the new bounds are larger, then animate it to a nice central position in the new bounds:*/
	CGPoint webViewProxyPos_old;
	CGPoint webViewProxyPos_new;
	
	if((newBounds.size.width > self.bounds.size.width)||(newBounds.size.height > self.bounds.size.height))
	{
		/*if this is a straight expansion horizontally or vertically, then just center the web view proxy as it moves across:*/
		if(((newBounds.size.width > self.bounds.size.width)&&(newBounds.size.height == self.bounds.size.height))||((newBounds.size.width == self.bounds.size.width)&&(newBounds.size.height > self.bounds.size.height)))
		{
			webViewProxyPos_old = [webViewProxy position];
			webViewProxyPos_new = CGPointMake((int)(0.5 * newBounds.size.width), (int)(51 + 0.5 * (newBounds.size.height - 51)));
		}
		
		/*if instead one dimension is getting larger while the other gets smaller (only possible in an orientation change), then center the web view content at the top of its available area:*/
		else
		{
			webViewProxyPos_old = [webViewProxy position];
			webViewProxyPos_new = CGPointMake((int)(0.5 * newBounds.size.width), (int)(51 + 0.5 * ([webViewProxy bounds].size.height)));
		}
		
		[webViewProxyAnim_pos setDuration: duration];
		[webViewProxyAnim_pos setFromValue: [NSValue value: &webViewProxyPos_old withObjCType: @encode(CGPoint)]];
		[webViewProxyAnim_pos setToValue: [NSValue value: &webViewProxyPos_new withObjCType: @encode(CGPoint)]];
		[webViewProxy setPosition: webViewProxyPos_new];
		[webViewProxy addAnimation: webViewProxyAnim_pos forKey: @"position"];
	}
	
	
	/*animate the actual view:*/
	[UIView animateWithDuration: duration animations: ^{ [self setBounds: newBounds]; [self setCenter: newCenter]; } completion: ^(BOOL finished) { if(webLoadingInProgress == 1) [webView reload]; [webView setHidden: NO]; [webViewProxy setHidden: YES]; [webViewProxy removeAllAnimations]; disableManualLayout = 0; [self setNeedsLayout]; } ];
}


/*
	For this mini app, all elements of the view will be kept structurally and will be animated into contraction:
*/
- (void)contract: (float)duration
{
	/*won't need manual layout anymore!*/
	disableManualLayout = 1;
	
	/*buttons:*/
	CGPoint backButtonPos_old = [backButton position];
	CGRect backButtonBounds_old = [backButton bounds];
	CGPoint forwardButtonPos_old = [forwardButton position];
	CGRect forwardButtonBounds_old = [forwardButton bounds];
	CGPoint stopButtonPos_old = [stopButton position];
	CGRect stopButtonBounds_old = [stopButton bounds];
	CGPoint reloadButtonPos_old = [reloadButton position];
	CGRect reloadButtonBounds_old = [reloadButton bounds];
	CGPoint zeroPoint = CGPointMake(0, 0);
	CGRect zeroBounds = CGRectMake(0, 0, 0, 0);
	
	[backButtonAnim_pos setDuration: duration];
	[backButtonAnim_bounds setDuration: duration];
	[forwardButtonAnim_pos setDuration: duration];
	[forwardButtonAnim_bounds setDuration: duration];
	[stopButtonAnim_pos setDuration: duration];
	[stopButtonAnim_bounds setDuration: duration];
	[reloadButtonAnim_pos setDuration: duration];
	[reloadButtonAnim_bounds setDuration: duration];
	[backButtonAnim_pos setFromValue: [NSValue value: &backButtonPos_old withObjCType: @encode(CGPoint)]];
	[backButtonAnim_pos setToValue: [NSValue value: &zeroPoint withObjCType: @encode(CGPoint)]];
	[backButtonAnim_bounds setFromValue: [NSValue value: &backButtonBounds_old withObjCType: @encode(CGRect)]];
	[backButtonAnim_bounds setToValue: [NSValue value: &zeroBounds withObjCType: @encode(CGRect)]];
	[forwardButtonAnim_pos setFromValue: [NSValue value: &forwardButtonPos_old withObjCType: @encode(CGPoint)]];
	[forwardButtonAnim_pos setToValue: [NSValue value: &zeroPoint withObjCType: @encode(CGPoint)]];
	[forwardButtonAnim_bounds setFromValue: [NSValue value: &forwardButtonBounds_old withObjCType: @encode(CGRect)]];
	[forwardButtonAnim_bounds setToValue: [NSValue value: &zeroBounds withObjCType: @encode(CGRect)]];
	[stopButtonAnim_pos setFromValue: [NSValue value: &stopButtonPos_old withObjCType: @encode(CGPoint)]];
	[stopButtonAnim_pos setToValue: [NSValue value: &zeroPoint withObjCType: @encode(CGPoint)]];
	[stopButtonAnim_bounds setFromValue: [NSValue value: &stopButtonBounds_old withObjCType: @encode(CGRect)]];
	[stopButtonAnim_bounds setToValue: [NSValue value: &zeroBounds withObjCType: @encode(CGRect)]];
	[reloadButtonAnim_pos setFromValue: [NSValue value: &reloadButtonPos_old withObjCType: @encode(CGPoint)]];
	[reloadButtonAnim_pos setToValue: [NSValue value: &zeroPoint withObjCType: @encode(CGPoint)]];
	[reloadButtonAnim_bounds setFromValue: [NSValue value: &reloadButtonBounds_old withObjCType: @encode(CGRect)]];
	[reloadButtonAnim_bounds setToValue: [NSValue value: &zeroBounds withObjCType: @encode(CGRect)]];
	
	[backButton setPosition: zeroPoint];
	[backButton addAnimation: backButtonAnim_pos forKey: @"position"];
	[backButton setBounds: zeroBounds];
	[backButton addAnimation: backButtonAnim_bounds forKey: @"bounds"];
	[forwardButton setPosition: zeroPoint];
	[forwardButton addAnimation: forwardButtonAnim_pos forKey: @"position"];
	[forwardButton setBounds: zeroBounds];
	[forwardButton addAnimation: forwardButtonAnim_bounds forKey: @"bounds"];
	[stopButton setPosition: zeroPoint];
	[stopButton addAnimation: stopButtonAnim_pos forKey: @"position"];
	[stopButton setBounds: zeroBounds];
	[stopButton addAnimation: stopButtonAnim_bounds forKey: @"bounds"];
	[reloadButton setPosition: zeroPoint];
	[reloadButton addAnimation: reloadButtonAnim_pos forKey: @"position"];
	[reloadButton setBounds: zeroBounds];
	[reloadButton addAnimation: reloadButtonAnim_bounds forKey: @"bounds"];
	
	
	/*URL bar:*/
	[UIView animateWithDuration: duration animations: ^{ [URLEntryView setFrame: CGRectMake(0, 0, 0, 0)]; }];
	
	
	/*web view:*/
	if(webLoadingInProgress == 1) [webView stopLoading];
	
	[self carbonCopyWebViewContents];
	
	[webView setHidden: YES];
	[webViewProxy setHidden: NO];
	[webViewProxy removeAllAnimations];
	
	CGPoint webViewProxyPos_old = [webViewProxy position];
	CGRect webViewProxyBounds_old = [webViewProxy bounds];
	
	[webViewProxyAnim_pos setDuration: duration];
	[webViewProxyAnim_bounds setDuration: duration];
	[webViewProxyAnim_pos setFromValue: [NSValue value: &webViewProxyPos_old withObjCType: @encode(CGPoint)]];
	[webViewProxyAnim_pos setToValue: [NSValue value: &zeroPoint withObjCType: @encode(CGPoint)]];
	[webViewProxyAnim_bounds setFromValue: [NSValue value: &webViewProxyBounds_old withObjCType: @encode(CGRect)]];
	[webViewProxyAnim_bounds setToValue: [NSValue value: &zeroBounds withObjCType: @encode(CGRect)]];
	[webViewProxy setPosition: zeroPoint];
	[webViewProxy addAnimation: webViewProxyAnim_pos forKey: @"position"];
	[webViewProxy setBounds: zeroBounds];
	[webViewProxy addAnimation: webViewProxyAnim_bounds forKey: @"bounds"];
	
	/*if we're in web loading mode then animate the loading graphics as well:*/
	if(webLoadingInProgress == 1)
	{
		[webLoadingCover setPosition: zeroPoint];
		[webLoadingCover addAnimation: webViewProxyAnim_pos forKey: @"position"];
		[webLoadingCover setBounds: zeroBounds];
		[webLoadingCover addAnimation: webViewProxyAnim_bounds forKey: @"bounds"];
		
		[UIView animateWithDuration: duration animations: ^{ [webLoadingIndicator setFrame: CGRectMake(0, 0, 0, 0)]; }];
	}
	
	/*if contracting while disabled, the darken top layer will look fine automatically when scaled down. But hide it if this view is not disabled, otherwise it might appear suddenly:*/
	if(miniAppIsDisabled == 0) [darkenTopLayer setHidden: YES];

	
	/*now scale down the view as a whole:*/
	[UIView animateWithDuration: duration animations: ^{[self setFrame: CGRectMake(self.frame.origin.x + (int)(0.5 * self.frame.size.width), self.frame.origin.y + (int)(0.5 * self.frame.size.height), 0, 0)]; } ];
}


/**************************************************************************************************************
	
	DELEGATE CALL-BACK METHODS:
 
************************************************************************************************************ */

/*
	this object is the delegate for the text field, so implement the following method for when the user hits the 'go' button:
*/
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	/*first of all, leave editing mode:*/
	[URLEntryView resignFirstResponder];
	
	/*now laod the user's requested web page:*/
	NSString *requestedURL = [URLEntryView text];
	
	/*if the user has left the 'http://' off the beginning but has put the 'www', then add this automatically:*/
	if(([requestedURL characterAtIndex: 0] == 'w')&&([requestedURL characterAtIndex: 1] == 'w')&&([requestedURL characterAtIndex: 2] == 'w'))
	{
		NSMutableString *prependedString = [NSMutableString stringWithUTF8String:"http://"];
		[prependedString appendString: requestedURL];
		
		[URLEntryView setText: prependedString];
	
	}
	
	[webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: [URLEntryView text]]]];

	
	return NO;
}


/*
	This is also the delegate for the webView, so implement the following functions to keep track of when a page is being loaded:
 */
-(void)webViewDidStartLoad:(UIWebView *)webViewCaller
{
	webLoadingInProgress = 1;
	
	/*while the web page is loading, cover it to indicate to the user that its loading:*/
	[webLoadingCover setHidden: NO];
	[webLoadingCover removeAllAnimations];
	[webLoadingIndicator setHidden: NO];
}

-(void)webViewDidFinishLoad:(UIWebView *)webViewCaller
{
	webLoadingInProgress = 0;
	
	/*now that the web page has finished loading, remove the cover and update our button states:*/
	[webLoadingCover setHidden:YES];
	[webLoadingCover removeAllAnimations];
	[webLoadingIndicator setHidden: YES];
	
	[self setButtonStates];
}


- (void)dealloc {
    
	/*release the various animation objects:*/
	[webViewProxyAnim_pos release];
	[webViewProxyAnim_bounds release];
	
	[webLoadingCoverAnim_pos release];
	[webLoadingCoverAnim_bounds release];
	
	[backButtonAnim_pos release];
	[backButtonAnim_bounds release];
	[forwardButtonAnim_pos release];
	[forwardButtonAnim_bounds release];
	[stopButtonAnim_pos release];
	[stopButtonAnim_bounds release];
	[reloadButtonAnim_pos release];
	[reloadButtonAnim_bounds release];
	
	
	/*release graphics images:*/
	CGImageRelease(buttonGraphics_back_off);
	CGImageRelease(buttonGraphics_back_on);
	CGImageRelease(buttonGraphics_forward_off);
	CGImageRelease(buttonGraphics_forward_on);
	CGImageRelease(buttonGraphics_stop_off);
	CGImageRelease(buttonGraphics_stop_on);
	CGImageRelease(buttonGraphics_reload_off);
	CGImageRelease(buttonGraphics_reload_on);
	
	
	/*release various subviews:*/
	[webView release];
	[webLoadingIndicator release];
	[URLEntryView release];
	
	
	[super dealloc];
}


@end
