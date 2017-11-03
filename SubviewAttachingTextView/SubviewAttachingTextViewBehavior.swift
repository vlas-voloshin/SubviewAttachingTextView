//
//  SubviewAttachingTextViewBehavior.swift
//  SubviewAttachingTextView
//
//  Created by Vlas Voloshin on 29/1/17.
//  Copyright © 2017 Vlas Voloshin. All rights reserved.
//

import UIKit

/**
 Component class managing a text view behaviour that tracks all text attachments of SubviewTextAttachment class, automatically inserts/removes their views as text view subviews, and updates their layout according to the text view's layout manager.
 - Note: Follow the implementation of `SubviewAttachingTextView` for an example of adopting this behavior in your custom text view subclass.
 */
@objc(VVSubviewAttachingTextViewBehavior)
open class SubviewAttachingTextViewBehavior: NSObject, NSLayoutManagerDelegate, NSTextStorageDelegate {

    @objc
    open weak var textView: UITextView? {
        willSet {
            // Remove all managed subviews from the text view being disconnected
            self.removeAttachedSubviews()
        }
        didSet {
            // Synchronize managed subviews to the new text view
            self.updateAttachedSubviews()
            self.layoutAttachedSubviews()
        }
    }

    // MARK: Subview tracking

    private let attachedViews = NSMapTable<TextAttachedViewProvider, UIView>.strongToStrongObjects()
    private var attachedProviders: Array<TextAttachedViewProvider> {
        return Array(self.attachedViews.keyEnumerator()) as! Array<TextAttachedViewProvider>
    }

    /**
     Adds attached views as subviews and removes subviews that are no longer attached. This method is called automatically when text view's text attributes change. Calling this method does not automatically perform a layout of attached subviews.
     */
    @objc
    open func updateAttachedSubviews() {
        guard let textView = self.textView else {
            return
        }

        // Collect all SubviewTextAttachment attachments
        let subviewAttachments = textView.textStorage.subviewAttachmentRanges.map { $0.attachment }

        // Remove views whose providers are no longer attached
        for provider in self.attachedProviders {
            if (subviewAttachments.contains { $0.viewProvider === provider } == false) {
                self.attachedViews.object(forKey: provider)?.removeFromSuperview()
                self.attachedViews.removeObject(forKey: provider)
            }
        }

        // Insert views that became attached
        let attachmentsToAdd = subviewAttachments.filter {
            self.attachedViews.object(forKey: $0.viewProvider) == nil
        }
        for attachment in attachmentsToAdd {
            let provider = attachment.viewProvider
            let view = provider.instantiateView(for: attachment, in: self)
            view.translatesAutoresizingMaskIntoConstraints = true
            view.autoresizingMask = [ ]

            textView.addSubview(view)
            self.attachedViews.setObject(view, forKey: provider)
        }
    }

    private func removeAttachedSubviews() {
        for provider in self.attachedProviders {
            self.attachedViews.object(forKey: provider)?.removeFromSuperview()
        }
        self.attachedViews.removeAllObjects()
    }

    // MARK: Layout

    /**
     Lays out all attached subviews according to the layout manager. This method is called automatically when layout manager finishes updating its layout.
     */
    @objc
    open func layoutAttachedSubviews() {
        guard let textView = self.textView else {
            return
        }

        let layoutManager = textView.layoutManager
        let scaleFactor = textView.window?.screen.scale ?? UIScreen.main.scale

        // For each attached subview, find its associated attachment and position it according to its text layout
        let attachmentRanges = textView.textStorage.subviewAttachmentRanges
        for (attachment, range) in attachmentRanges {
            guard let view = self.attachedViews.object(forKey: attachment.viewProvider) else {
                // A view for this provider is not attached yet??
                continue
            }
            guard view.superview === textView else {
                // Skip views which are not inside the text view for some reason
                continue
            }
            guard let attachmentRect = SubviewAttachingTextViewBehavior.boundingRect(forAttachmentCharacterAt: range.location, layoutManager: layoutManager) else {
                // Can't determine the rectangle for the attachment: just hide it
                view.isHidden = true
                continue
            }

            let convertedRect = textView.convertRectFromTextContainer(attachmentRect)
            let integralRect = CGRect(origin: convertedRect.origin.integral(withScaleFactor: scaleFactor),
                                      size: convertedRect.size)

            UIView.performWithoutAnimation {
                view.frame = integralRect
                view.isHidden = false
            }
        }
    }

    private static func boundingRect(forAttachmentCharacterAt characterIndex: Int, layoutManager: NSLayoutManager) -> CGRect? {
        let glyphRange = layoutManager.glyphRange(forCharacterRange: NSMakeRange(characterIndex, 1), actualCharacterRange: nil)
        let glyphIndex = glyphRange.location
        guard glyphIndex != NSNotFound && glyphRange.length == 1 else {
            return nil
        }

        let attachmentSize = layoutManager.attachmentSize(forGlyphAt: glyphIndex)
        guard attachmentSize.width > 0.0 && attachmentSize.height > 0.0 else {
            return nil
        }

        let lineFragmentRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: nil)
        let glyphLocation = layoutManager.location(forGlyphAt: glyphIndex)
        guard lineFragmentRect.width > 0.0 && lineFragmentRect.height > 0.0 else {
            return nil
        }

        return CGRect(origin: CGPoint(x: lineFragmentRect.minX + glyphLocation.x,
                                      y: lineFragmentRect.minY + glyphLocation.y - attachmentSize.height),
                      size: attachmentSize)
    }

    // MARK: NSLayoutManagerDelegate

    public func layoutManager(_ layoutManager: NSLayoutManager, didCompleteLayoutFor textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        if layoutFinishedFlag {
            self.layoutAttachedSubviews()
        }
    }

    // MARK: NSTextStorageDelegate

    public func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        if editedMask.contains(.editedAttributes) {
            self.updateAttachedSubviews()
        }
    }

}

// MARK: - Extensions

public extension UITextView {

    @objc(vv_convertPointToTextContainer:)
    func convertPointToTextContainer(_ point: CGPoint) -> CGPoint {
        let insets = self.textContainerInset
        return CGPoint(x: point.x - insets.left, y: point.y - insets.top)
    }

    @objc(vv_convertPointFromTextContainer:)
    func convertPointFromTextContainer(_ point: CGPoint) -> CGPoint {
        let insets = self.textContainerInset
        return CGPoint(x: point.x + insets.left, y: point.y + insets.top)
    }

    @objc(vv_convertRectToTextContainer:)
    func convertRectToTextContainer(_ rect: CGRect) -> CGRect {
        let insets = self.textContainerInset
        return rect.offsetBy(dx: -insets.left, dy: -insets.top)
    }

    @objc(vv_convertRectFromTextContainer:)
    func convertRectFromTextContainer(_ rect: CGRect) -> CGRect {
        let insets = self.textContainerInset
        return rect.offsetBy(dx: insets.left, dy: insets.top)
    }
    
}

private extension CGPoint {

    func integral(withScaleFactor scaleFactor: CGFloat) -> CGPoint {
        guard scaleFactor > 0.0 else {
            return self
        }

        return CGPoint(x: round(self.x * scaleFactor) / scaleFactor,
                       y: round(self.y * scaleFactor) / scaleFactor)
    }

}

private extension NSAttributedString {

    var subviewAttachmentRanges: [(attachment: SubviewTextAttachment, range: NSRange)] {
        var ranges = [(SubviewTextAttachment, NSRange)]()

        let fullRange = NSRange(location: 0, length: self.length)
        self.enumerateAttribute(NSAttributedStringKey.attachment, in: fullRange) { value, range, _ in
            if let attachment = value as? SubviewTextAttachment {
                ranges.append((attachment, range))
            }
        }

        return ranges
    }
    
}
