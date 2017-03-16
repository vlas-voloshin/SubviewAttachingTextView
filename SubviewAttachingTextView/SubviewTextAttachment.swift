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

    public let subview: UIView

    /**
     Initialize the attachment with a view and an explicit size.
     */
    public init(subview: UIView, size: CGSize) {
        self.subview = subview
        super.init(data: nil, ofType: nil)
        self.bounds = CGRect(origin: .zero, size: size)
    }

    /**
     Initialize the attachment with a view and use its current fitting size as the attachment size. If the view does not define a fitting size, its current bounds size is used.
     */
    public convenience init(subview: UIView) {
        self.init(subview: subview, size: subview.attachmentFittingSize)
    }

    // MARK: NSCoding

    public required init?(coder aDecoder: NSCoder) {
        fatalError("SubviewTextAttachment cannot be decoded.")
    }

}

// MARK: - Extensions

private extension UIView {

    @objc(vv_attachmentFittingSize)
    var attachmentFittingSize: CGSize {
        let fittingSize = self.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        if fittingSize.width > 1e-3 && fittingSize.height > 1e-3 {
            return fittingSize
        } else {
            return self.bounds.size
        }
    }
    
}
