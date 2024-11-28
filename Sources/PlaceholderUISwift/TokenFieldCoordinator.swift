//
//  TokenFieldCoordinator.swift
//  kitchen_script
//
//  Created by Theron Boerner on 11/25/24.
//

import Foundation
import AppKit

class TokenFieldCoordinator: NSObject, NSTextViewDelegate, NSControlTextEditingDelegate {
    var parent: MyTokenField
    
    init(_ parent: MyTokenField) {
        self.parent = parent
        
    }
   
//    func updateData(_ obj: NSMyTokenField) {
//    }
    
    //        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
    //                if commandSelector == #selector(NSResponder.insertNewline(_:))
    //     {
    //                    parent.handleTokenCompletion(from:
    //     control as! NSMyTokenField)
    //                    return true
    //                } else if commandSelector == #selector(NSResponder.deleteBackward(_:)) {
    //                    parent.handleDeleteBackward(from: control as! NSMyTokenField)
    //                    return true
    //                }
    //                return false
   
//        textView

    
    func textDidChange(_ obj: Notification) {
//            print("control text")
        guard let textField = obj.object as? NSMyTokenField else { return }
     
        textField.typingAttributes = [:]
        textField.regenerateData()
        textField.regenerateString()
       
        self.parent.placeholderData = textField.placeholderData ?? PlaceholderData()
        
//            parent.handleTokenCompletion(from: textField)
        
//        print("made it here")
//            guard let fieldEditor = textField.window?.fieldEditor(false, for: textField) else { return }
//            print("and here")
//            print()
//            guard let fieldEditor = textField.currentEditor() else { return }
        // 1. Get the current cursor position
        let cursorPosition = textField.selectedRange().location
//            let cursorPosition = fieldEditor.selectedRange.location

        // 2. Get the attributed string before the cursor
        let attributedTextBeforeCursor = textField.attributedString().attributedSubstring(from: NSRange(location: 0, length: cursorPosition))
        
        print(attributedTextBeforeCursor.string)
        
        parent.iterateOverAttributedString(attributedString: textField.attributedString())

        // 3. Get the last character before the cursor
        if let lastCharacter = attributedTextBeforeCursor.string.last {
            
//            if lastCharacter == " " {
//                textField.textStorage?.insert(NSAttributedString("wat"), at: cursorPosition)
//            }
//            var range = NSRange(location: cursorPosition - 1, length: 1)
//            
//            textField.textStorage?.attributes(at: cursorPosition, effectiveRange: &range)
//            textField.textStorage?.setAttributes([:], range: <#T##NSRange#>)
            
//            if lastCharacter == "@" {
//                textField.showCompletionWindow()
//                // 4. (Optional) Show a suggestion list or autocomplete here
//                print("Show suggestions for tokens")
            if lastCharacter == " " || lastCharacter == "\n" {
                textField.hideCompletionWindow()
            } else {
                let str = attributedTextBeforeCursor.string
                let separators = CharacterSet(charactersIn: "\n ￼")

                let lastStr = str.components(separatedBy: separators).last?.first
                
                if lastStr == "@" {
                    textField.showCompletionWindow()
                }
                // 5. (Optional) Hide the suggestion list if it was shown
                print("Hide suggestions")
            }
        }
    }
    
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        print("foo")
        if commandSelector == #selector(NSResponder.insertNewline(_:))
        {
            // Handle Enter key
//            parent.handleTokenCompletion(from: control as! NSMyTokenField)
            return true
        } else if commandSelector == #selector(NSResponder.deleteBackward(_:)) {
            // Handle Backspace key
//                    parent.handleDeleteBackward(from: control as! NSMyTokenField)
            return true
        } else if commandSelector == #selector(NSResponder.moveLeft(_:)) {
            // Handle Left arrow key
            print("Left arrow key pressed")
            // Add your custom logic here for handling the left arrow key
            return true // Return true if you handled the event, false otherwise
        }
        // Add more else if blocks for other keys you want to handle
        
        return false // Default: Don't handle the event
    }
}
