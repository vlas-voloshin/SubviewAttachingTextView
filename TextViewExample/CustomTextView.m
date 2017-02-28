//
//  CustomTextView.m
//  TextViewExample
//
//  Created by Vlas Voloshin on 29/1/17.
//  Copyright © 2017 Vlas Voloshin. All rights reserved.
//

#import "CustomTextView.h"
#import <SubviewAttachingTextView/SubviewAttachingTextView.h>

@interface CustomTextView ()

@property (nonatomic, readonly, strong) VVSubviewAttachingTextViewBehavior *attachingBehavior;

@end

@implementation CustomTextView

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        [self commonInit];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }

    return self;
}

- (void)commonInit
{
    _attachingBehavior = [[VVSubviewAttachingTextViewBehavior alloc] init];
    _attachingBehavior.textView = self;
    self.layoutManager.delegate = _attachingBehavior;
    self.textStorage.delegate = _attachingBehavior;
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset
{
    [super setTextContainerInset:textContainerInset];

    [self.attachingBehavior layoutAttachedSubviews];
}

@end
