//
//  MyTokenField.swift
//  kitchen_script
//
//  Created by Theron Boerner on 11/23/24.
//


// TODO: copy and paste attachment
// TODO: allow inserting in the middle of the text
// TODO: turn string attributes into token list
// TODO: export
// TODO: hook up to SwiftData

import Foundation

#if os(macOS)
import AppKit
import Cocoa
import SwiftUI

struct MyTokenField: NSViewRepresentable {
    @Binding var placeholderData: PlaceholderData
    
    func updateNSView(_ nsView: NSMyTokenField, context: Context) {
        if (nsView.needsRegen) {
            nsView.placeholderData = placeholderData
            nsView.regenerateString()
            nsView.needsRegen = false
        } else {
            nsView.needsRegen = true
        }
        nsView.needsRegen = true
        nsView.setNeedsDisplay(nsView.bounds)
        nsView.typingAttributes = [:]
    }
    
    func makeNSView(context: Context) -> NSMyTokenField {
        let tokenField = NSMyTokenField(frame: .zero, placeholderData: placeholderData)
        tokenField.isEditable = true
        tokenField.isSelectable = true
        tokenField.delegate = context.coordinator
        tokenField.placeholderData = placeholderData
        tokenField.regenerateString()
        tokenField.typingAttributes = [:]
        return tokenField
    }
    
    
    func makeCoordinator() -> TokenFieldCoordinator {
        TokenFieldCoordinator(self)
    }
    
    // Move these functions outside of NSMyTokenField class
    
    func iterateOverAttributedString(attributedString: NSAttributedString) {
        let fullRange = NSRange(location: 0, length: attributedString.length)

        attributedString.enumerateAttributes(in: fullRange, options: []) { (attributes, range, stop) in
                let substring = attributedString.attributedSubstring(from: range).string
//            print("Substring: \(substring)")
//            print("Range: \(range)")
            
            //            dump(attributes)
            let label = attributes[.tokenData] as? String
            
            if label != nil {
//                print("Token type: \(String(describing: label!))")
            }

//            print("------")
        }
    }
}

#endif

#if os(iOS)
import UIKit
import SwiftUI

class MyTokenField: UITextField {

    enum TokenType {
        case token(NSAttributedString)
        case plain(String)
    }

    var tokens: [TokenType] = []
    var tokenBackgroundColor: UIColor = .lightGray
    var tokenTextColor: UIColor = .black
    var validTokens: [String] = ["@user1", "@user2", "@groupA"] // Your list of valid tokens

    func addToken(string: String) {
         let attributedToken = NSAttributedString(string: string, attributes: [.font: font!, .foregroundColor: tokenTextColor])
         tokens.append(.token(attributedToken))
         setNeedsDisplay()
     }

     func removeToken(at index: Int) {
         guard index >= 0 && index < tokens.count else { return }
         tokens.remove(at: index)
         setNeedsDisplay()
     }

     // MARK: - Text Field Overrides

     override func textRect(forBounds bounds: CGRect) -> CGRect {
         var rect = super.textRect(forBounds: bounds)
         rect.origin.x += currentTokenWidth()
         return rect
     }

     override func editingRect(forBounds bounds: CGRect) -> CGRect {
         var rect = super.editingRect(forBounds: bounds)
         rect.origin.x
  += currentTokenWidth()
         return rect
     }

    override func draw(_ rect: CGRect) {
            var currentX: CGFloat = 0
            for token in tokens {
                let tokenSize: CGSize
                let tokenAttributes: [NSAttributedString.Key: Any]

                switch token {
                case .token(let attributedToken):
                    tokenSize = attributedToken.size()
                    tokenAttributes = attributedToken.attributes(at: 0, effectiveRange: nil)

                    let tokenRect = CGRect(x: currentX, y: 0, width: tokenSize.width + 16, height: bounds.height)

                    // Draw token background
                    let path = UIBezierPath(roundedRect: tokenRect, cornerRadius: 5)
                    tokenBackgroundColor.setFill()
                    path.fill()

                    // Draw token text
                    attributedToken.draw(at: CGPoint(x: currentX + 8, y: (bounds.height - tokenSize.height) / 2))

                    currentX += tokenRect.width + 4

                case .plain(let stringToken):
                    tokenSize = stringToken.size(withAttributes: [.font: font!])
                    tokenAttributes = [.font: font!, .foregroundColor: textColor!]

                    stringToken.draw(at: CGPoint(x: currentX, y: (bounds.height - tokenSize.height) / 2), withAttributes: tokenAttributes)

                    currentX += tokenSize.width

                }

            }

            super.draw(rect)
        }

    
    private func currentTokenWidth() -> CGFloat {
        var width: CGFloat = 0
        for token in tokens {
            let tokenSize: CGSize
            switch token {
            case .token(let attributedToken):
                tokenSize = attributedToken.size()
                width += tokenSize.width + 20
            case .plain(let stringToken):
                tokenSize = stringToken.size(withAttributes: [.font: font!])
                width += tokenSize.width
            }
        }
        return width
    }
    
    override func deleteBackward() {
        if text?.isEmpty == true && !tokens.isEmpty {
            removeToken(at: tokens.count - 1)
        } else {
            super.deleteBackward()
        }
    }
    
    override func insertText(_ text: String) {
        if text == "@" {
            // Start a new token
            super.insertText(text)
        } else if let currentText = self.text, currentText.hasPrefix("@") {
            // Append to the current token
            super.insertText(text)

            // Check for space or return to complete the token
            if text == " " || text == "\n" {
                let tokenString = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
                if validTokens.contains(tokenString) {
                    // Valid token
                    addToken(string: tokenString)
                } else {
                    // Invalid token, add as plain text
                    tokens.append(.plain(tokenString))
                }
                self.text = ""
            }
        } else {
            // Regular text input
            if var lastToken = tokens.last, case let .plain(string) = lastToken {
                // Append to the existing plain text
                lastToken = .plain(string + text)
                tokens[tokens.count - 1] = lastToken
            } else {
                // Add new plain text
                tokens.append(.plain(text))
            }
            setNeedsDisplay()
            super.insertText(text)
        }
    }
}
#endif
