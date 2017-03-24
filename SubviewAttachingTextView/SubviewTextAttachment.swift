//
//  SubviewTextAttachment.swift
//  SubviewAttachingTextView
//
//  Created by Vlas Voloshin on 29/1/17.
//  Copyright © 2017 Vlas Voloshin. All rights reserved.
//

import UIKit

/**
 Describes a protocol that provides views inserted as subviews into text views that render a `SubviewTextAttachment`.
 - Note: Implementing this protocol is encouraged over providing a single view in a `SubviewTextAttachment`, because it allows attributed strings with subview attachments to be rendered in multiple text views at the same time: each text view would get its own subview that corresponds to the attachment.
 */
@objc(VVTextAttachedViewProvider)
public protocol TextAttachedViewProvider: class {
    @objc(instantiateViewForAttachment:inBehavior:)
    func instantiateView(for attachment: SubviewTextAttachment, in behavior: SubviewAttachingTextViewBehavior) -> UIView
}

/**
 Describes a custom text attachment object containing a view. SubviewAttachingTextViewBehavior tracks attachments of this class and automatically manages adding and removing subviews in its text view.
 */
@objc(VVSubviewTextAttachment)
open class SubviewTextAttachment: NSTextAttachment {

    public let viewProvider: TextAttachedViewProvider

    /**
     Initialize the attachment with a view provider and an explicit size.
     */
    public init(viewProvider: TextAttachedViewProvider, size: CGSize) {
        self.viewProvider = viewProvider
        super.init(data: nil, ofType: nil)
        self.bounds = CGRect(origin: .zero, size: size)
    }

    /**
     Initialize the attachment with a view and an explicit size.
     - Warning: If an attributed string that includes the returned attachment is used in more than one text view at a time, the behavior is not defined.
     */
    public convenience init(view: UIView, size: CGSize) {
        let provider = DirectTextAttachedViewProvider(view: view)
        self.init(viewProvider: provider, size: size)
    }

    /**
     Initialize the attachment with a view and use its current fitting size as the attachment size.
     - Note: If the view does not define a fitting size, its current bounds size is used.
     - Warning: If an attributed string that includes the returned attachment is used in more than one text view at a time, the behavior is not defined.
     */
    public convenience init(view: UIView) {
        self.init(view: view, size: view.textAttachmentFittingSize)
    }

    // MARK: NSCoding

    public required init?(coder aDecoder: NSCoder) {
        fatalError("SubviewTextAttachment cannot be decoded.")
    }

}

// MARK: - Internal view provider

final class DirectTextAttachedViewProvider: TextAttachedViewProvider {

    let view: UIView

    init(view: UIView) {
        self.view = view
    }

    func instantiateView(for attachment: SubviewTextAttachment, in behavior: SubviewAttachingTextViewBehavior) -> UIView {
        return self.view
    }

}

// MARK: - Extensions

private extension UIView {

    @objc(vv_attachmentFittingSize)
    var textAttachmentFittingSize: CGSize {
        let fittingSize = self.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        if fittingSize.width > 1e-3 && fittingSize.height > 1e-3 {
            return fittingSize
        } else {
            return self.bounds.size
        }
    }
    
}
