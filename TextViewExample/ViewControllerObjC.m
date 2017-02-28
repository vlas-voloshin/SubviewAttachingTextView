//
//  ViewController.m
//  TextViewExample
//
//  Created by Vlas Voloshin on 29/1/17.
//  Copyright © 2017 Vlas Voloshin. All rights reserved.
//

#import "ViewControllerObjC.h"
#import "TextViewExample-Swift.h"
#import <SubviewAttachingTextView/SubviewAttachingTextView.h>

@interface ViewControllerObjC ()

@property (nonatomic, weak) IBOutlet UITextView *textView;

@end

@implementation ViewControllerObjC

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSURL *url = [[NSBundle mainBundle] URLForResource:@"lorem-ipsum" withExtension:@"txt"];
    NSString *loremImpsum = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:loremImpsum attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:14] }];

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.color = [UIColor blackColor];
    [spinner startAnimating];

    VVSubviewTextAttachment *attachment = [[VVSubviewTextAttachment alloc] initWithView:spinner];
    self.textView.attributedText = [text vv_insertingAttachment:attachment atIndex:100 withParagraphStyle:nil];
}

@end
