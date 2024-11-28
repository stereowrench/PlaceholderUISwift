//
//  PlaceholderAttachment.swift
//  kitchen_script
//
//  Created by Theron Boerner on 11/25/24.
//

import Foundation
import AppKit

//class PlaceholderAttachmentView: NSView {
//    var str: PlaceholderAttachment? = nil
// 
//    private var isMouseDown: Bool = false
//    
//    override var intrinsicContentSize: NSSize {
////        var result: NSSize = .init(width: labelText.size().width, height: labelText.size().height)
////        result.width += xPadding * 2
////        result.height += yPadding * 2
////        return result
//    }
//    
//    var xPadding: CGFloat { return 3 }
//    var yPadding: CGFloat { return 1 }
//    var cornerRadius: CGFloat { return 3 }
//
//    var fillColor: NSColor {
//        return isMouseDown ? .selectedControlColor : .systemBlue
//    }
////
////    var labelText: NSAttributedString {
//////        let string = (str?.hiddenContent != nil) ? "Show more" : "Show less"
////        let string = str!.label
////        var labelFont = NSFont.preferredFont(forTextStyle: .caption2, options: [:])
////        let labelFontDescriptor = labelFont.fontDescriptor.withSymbolicTraits(.bold)
////        labelFont = NSFont(descriptor: labelFontDescriptor, size: labelFont.pointSize)!
////        let attributes: [NSAttributedString.Key: Any] = [
////            .font: labelFont,
////            .foregroundColor: NSColor.white
////        ]
////        return NSAttributedString(string: string, attributes: attributes)
////    }
//    
//    
//}

//class PlaceholderAttachmentViewProvider: NSTextAttachmentViewProvider {
//    override func loadView() {
//        let attachmentView = PlaceholderAttachmentView()
//        attachmentView.str = textAttachment as? PlaceholderAttachment
//        view = attachmentView
//    }
//}

class MyImageAttachmentCell: NSTextAttachmentCell {
    var label: String? = ""
    let backgroundColor: NSColor = NSColor.blue
    let textColor: NSColor = NSColor.textColor
    let padding: CGFloat = 2

    func setLabel(lab: String) {
        label = lab
    }
   
    override func cellFrame(for textContainer: NSTextContainer, proposedLineFragment lineFrag: NSRect, glyphPosition position: NSPoint, characterIndex charIndex: Int) -> NSRect {
        let (width, height) = getDims()
        return NSRect(x: position.x, y: position.y, width: width, height: height)
    }
  
    func getDims() -> (CGFloat, CGFloat) {
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12) // Use the same font as in draw(withFrame:in:)
        ]
        let labelAttributedString = NSAttributedString(string: label!, attributes: labelAttributes)
        let labelSize = labelAttributedString.size()

        // Calculate the cell size based on the label size and desired padding
        let width = labelSize.width + padding * 2
        let height = 0 as CGFloat
        return (width, height)
    }
    
    override func cellSize(forBounds rect: NSRect) -> NSSize {
        guard label != nil else {
            return NSSize(width: 0, height: 0)
        }
        let (width, height) = getDims()
        return NSSize(width: width, height: height)
    }
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView?)
 {
     if label != nil {
         //         let labelSize = label!.size()
         //
         //         NSColor.clear.set()
         //         let newBounds = bounds.offsetBy(dx: 0, dy: -(bounds.height - labelSize.height))
         //         newBounds.fill()
         //         fillColor.set()
         //         NSBezierPath(roundedRect: newBounds, xRadius: cornerRadius, yRadius: cornerRadius).fill()
         //
         //         let yOffset = -(bounds.height - labelSize.height) / 2
         //
         //         labelText.draw(at: NSPoint(
         //             x: bounds.origin.x + (bounds.size.width - labelSize.width) / 2.0,
         //             y: bounds.origin.y + yOffset // Use yOffset here
         //         ))
         
         // 1. Draw the rounded rectangle
         NSColor.black.setStroke()
         
//         let path = NSBezierPath(roundedRect: cellFrame, xRadius: 5, yRadius: 5) // Adjust corner radius as needed
//         backgroundColor.setFill()
//         path.fill()
//         path.stroke()
         
         // 2. Draw the label
         let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12),
            .foregroundColor: textColor
         ]
        
         let labelAttributedString = NSAttributedString(string: label!, attributes: labelAttributes)
         let labelSize = labelAttributedString.size()

         if let font = labelAttributedString.attribute(.font, at: 0, effectiveRange: nil) as? NSFont {
             let baselineHeight = font.ascender// - font.descender
//             print("Baseline height: \(baselineHeight)")
        
             
             //         // 3. Create an NSBezierPath
//             let path2 = NSBezierPath(roundedRect: NSRect(x: cellFrame.maxX, y: cellFrame.maxY - labelSize.height + (labelSize.height - baselineHeight), width: labelSize.width, height: labelSize.height), xRadius: 5, yRadius: 5) // Adjust frame as needed
             let path2 = NSBezierPath(roundedRect: NSRect(x: cellFrame.minX, y: cellFrame.maxY, width: labelSize.width, height: labelSize.height), xRadius: 5, yRadius: 5) // Adjust frame as needed
             //
             //         // 4. Set the fill color (optional)
             NSColor.systemBlue.setFill()
             path2.fill()
             //
             //         // 5. Set the stroke color
             NSColor.blue.setStroke()
             path2.stroke()

             
             let labelRect = NSRect(x: cellFrame.minX, y: cellFrame.maxY, width: labelSize.width, height: labelSize.height)
             labelAttributedString.draw(in: labelRect)
             
         }
     }
     
    }

}

class PlaceholderAttachment: NSTextAttachment {
    var label: String? = ""
//    weak var textLayoutManager: NSTextLayoutManager? = nil
//    var hiddenContent: NSAttributedString? = nil
  
   
    func setLabel(label: String) {
        self.label = label
        let cell = MyImageAttachmentCell()
        cell.setLabel(lab: label)
        attachmentCell = cell
    }
    
//
//    override func viewProvider(for parentView: NSView?, location: NSTextLocation, textContainer: NSTextContainer?) -> NSTextAttachmentViewProvider? {
//        let viewProvider = PlaceholderAttachmentViewProvider(textAttachment: self, parentView: parentView, textLayoutManager: textContainer?.textLayoutManager, location: location)
//        viewProvider.tracksTextAttachmentViewBounds = true
//
//        return viewProvider
//    }
}


