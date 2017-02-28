//
//  ViewController.swift
//  TextViewExample
//
//  Created by Vlas Voloshin on 28/1/17.
//  Copyright © 2017 Vlas Voloshin. All rights reserved.
//

import UIKit

public extension NSTextAttachment {

    convenience init(image: UIImage, size: CGSize? = nil) {
        self.init(data: nil, ofType: nil)

        self.image = image
        if let size = size {
            self.bounds = CGRect(origin: .zero, size: size)
        }
    }

}

public extension NSAttributedString {

    @objc(vv_insertingAttachment:atIndex:withParagraphStyle:)
    func insertingAttachment(_ attachment: NSTextAttachment, at index: Int, with paragraphStyle: NSParagraphStyle? = nil) -> NSAttributedString {
        let copy = NSMutableAttributedString(attributedString: self)
        copy.insertAttachment(attachment, at: index, with: paragraphStyle)

        return NSAttributedString(attributedString: copy)
    }

    @objc
    func addingAttributes(_ attributes: [NSAttributedStringKey : Any]) -> NSAttributedString {
        let copy = NSMutableAttributedString(attributedString: self)
        copy.addAttributes(attributes)

        return NSAttributedString(attributedString: copy)
    }

}

public extension NSMutableAttributedString {

    @objc
    func insertAttachment(_ attachment: NSTextAttachment, at index: Int, with paragraphStyle: NSParagraphStyle? = nil) {
        let plainAttachmentString = NSAttributedString(attachment: attachment)

        if let paragraphStyle = paragraphStyle {
            let attachmentString = plainAttachmentString
                .addingAttributes([ NSAttributedStringKey.paragraphStyle : paragraphStyle ])
            let separatorString = NSAttributedString(string: .paragraphSeparator)

            // Surround the attachment string with paragraph separators, so that the paragraph style is only applied to it
            let insertion = NSMutableAttributedString()
            insertion.append(separatorString)
            insertion.append(attachmentString)
            insertion.append(separatorString)

            self.insert(insertion, at: index)
        } else {
            self.insert(plainAttachmentString, at: index)
        }
    }

    @objc
    func addAttributes(_ attributes: [NSAttributedStringKey : Any]) {
        self.addAttributes(attributes, range: NSRange(location: 0, length: self.length))
    }

}

public extension String {

    static let paragraphSeparator = "\u{2029}"
    
}
