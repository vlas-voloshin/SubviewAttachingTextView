//
//  SubviewTextAttachment.swift
//  SubviewAttachingTextView
//
//  Created by Vlas Voloshin on 29/1/17.
//  Copyright © 2017 Vlas Voloshin. All rights reserved.
//

import UIKit

/**
 Describes a custom text attachment object containing a view. SubviewAttachingTextViewBehavior tracks attachments of this class and automatically manages adding and removing subviews in its text view.
 */
@objc(VVSubviewTextAttachment)
open class SubviewTextAttachment: NSTextAttachment {

    @objc
    public let viewProvider: TextAttachedViewProvider

    /**
     Initialize the attachment with a view provider.
     */
    @objc
    public init(viewProvider: TextAttachedViewProvider) {
        self.viewProvider = viewProvider
        super.init(data: nil, ofType: nil)
    }

    /**
     Initialize the attachment with a view and an explicit size.
     - Warning: If an attributed string that includes the returned attachment is used in more than one text view at a time, the behavior is not defined.
     */
    @objc
    public convenience init(view: UIView, size: CGSize) {
        let provider = DirectTextAttachedViewProvider(view: view)
        self.init(viewProvider: provider)
        self.bounds = CGRect(origin: .zero, size: size)
    }

    /**
     Initialize the attachment with a view and use its current fitting size as the attachment size.
     - Note: If the view does not define a fitting size, its current bounds size is used.
     - Warning: If an attributed string that includes the returned attachment is used in more than one text view at a time, the behavior is not defined.
     */
    @objc
    public convenience init(view: UIView) {
        self.init(view: view, size: view.textAttachmentFittingSize)
    }

    // MARK: - NSTextAttachmentContainer

    open override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        return self.viewProvider.bounds(for: self, textContainer: textContainer, proposedLineFragment: lineFrag, glyphPosition: position)
    }

    // MARK: NSCoding

    public required init?(coder aDecoder: NSCoder) {
        fatalError("SubviewTextAttachment cannot be decoded.")
    }

}

// MARK: - Internal view provider

final internal class DirectTextAttachedViewProvider: TextAttachedViewProvider {

    let view: UIView

    init(view: UIView) {
        self.view = view
    }

    func instantiateView(for attachment: SubviewTextAttachment, in behavior: SubviewAttachingTextViewBehavior) -> UIView {
        return self.view
    }

    func bounds(for attachment: SubviewTextAttachment, textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint) -> CGRect {
        return attachment.bounds
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
