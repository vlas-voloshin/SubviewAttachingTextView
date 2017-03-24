//
//  TextAttachedViewProvider.swift
//  SubviewAttachingTextView
//
//  Created by Vlas Voloshin on 25/3/17.
//  Copyright © 2017 Vlas Voloshin. All rights reserved.
//

import UIKit

/**
 Describes a protocol that provides views inserted as subviews into text views that render a `SubviewTextAttachment`, and customizes their layout.
 - Note: Implementing this protocol is encouraged over providing a single view in a `SubviewTextAttachment`, because it allows attributed strings with subview attachments to be rendered in multiple text views at the same time: each text view would get its own subview that corresponds to the attachment.
 */
@objc(VVTextAttachedViewProvider)
public protocol TextAttachedViewProvider: class {

    /**
     Returns a view that corresponds to the specified attachment.
     - Note: Each `SubviewAttachingTextViewBehavior` caches instantiated views until the attachment leaves the text container.
     */
    @objc(instantiateViewForAttachment:inBehavior:)
    func instantiateView(for attachment: SubviewTextAttachment, in behavior: SubviewAttachingTextViewBehavior) -> UIView

    /**
     Returns the layout bounds of the view that corresponds to the specified attachment.
     - Note: Return `attachment.bounds` for default behavior. See `NSTextAttachmentContainer.attachmentBounds(for:, proposedLineFragment:, glyphPosition:, characterIndex:)` method for more details.
     */
    @objc(boundsForAttachment:textContainer:proposedLineFragment:glyphPosition:)
    func bounds(for attachment: SubviewTextAttachment, textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint) -> CGRect

}
