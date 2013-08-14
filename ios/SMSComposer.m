//
//  SMSComposer.m
//  SMS Composer plugin for PhoneGap
//
//  Created by Grant Sanders on 12/25/2010.
//

#import "SMSComposer.h"

@implementation SMSComposer

- (CDVPlugin *)initWithWebView:(UIWebView *)theWebView
{
	self = (SMSComposer *)[super initWithWebView:theWebView];
	return self;
}

- (void)showSMSComposer:(CDVInvokedUrlCommand*)command
{
	Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
        
	NSString	*toRecipientsString = [command.arguments objectAtIndex:0];
	NSString	*body = [command.arguments objectAtIndex:1];

	if (messageClass != nil) {
		if (![messageClass canSendText]) {
			UIAlertView *alert = [[UIAlertView alloc]	initWithTitle	:@"Notice" message:@"SMS Text not available."
                                                          delegate		:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			return;
		}
	} else {
		UIAlertView *alert = [[UIAlertView alloc]	initWithTitle	:@"Notice" message:@"SMS Text not available."
                                                      delegate		:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
	}



	MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];

	picker.messageComposeDelegate = self;

	if (body != nil) {
		picker.body = body;
	}

	if (toRecipientsString != nil) {
		[picker setRecipients:[toRecipientsString componentsSeparatedByString:@","]];
	}

	[self.viewController presentModalViewController:picker animated:YES];
	[[UIApplication sharedApplication] setStatusBarHidden:YES];	// /This hides the statusbar when the picker is presented -@RandyMcMillan
}

// Dismisses the composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	// Notifies users about errors associated with the interface
	int webviewResult = 0;

	switch (result) {
		case MessageComposeResultCancelled:
			webviewResult = 0;
			break;

		case MessageComposeResultSent:
			webviewResult = 1;
			break;

		case MessageComposeResultFailed:
			webviewResult = 2;
			break;

		default:
			webviewResult = 3;
			break;
	}

	[self.viewController dismissModalViewControllerAnimated:YES];

	NSString *jsString = [[NSString alloc] initWithFormat:@"window.plugins.smsComposer._didFinishWithResult(%d);", webviewResult];
	[self writeJavascript:jsString];
}

@end
