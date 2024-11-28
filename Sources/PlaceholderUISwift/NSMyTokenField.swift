//
//  NSMyTokenField.swift
//  kitchen_script
//
//  Created by Theron Boerner on 11/25/24.
//

import Foundation


#if os(macOS)
import Cocoa
import AppKit
import SwiftUI

extension NSAttributedString.Key {
    static let tokenData: NSAttributedString.Key = .init("tokenData")
}

class MyCustomData: NSObject, NSPasteboardWriting, Codable {
    let name: String
    let value: String
    
    init(name: String, value: String) {
        self.name = name
        self.value = value
    }

    static var writableTypes: [NSPasteboard.PasteboardType] {
        return [.string] // Or your custom UTI
    }

    func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return Self.writableTypes
    }

    func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
        print(name, value)
        switch type {
        case .string:
            return "\(name):\(value)" // Encode your data as a string
        default:
            return nil
        }
    }
}

class NSMyTokenField: NSTextView {
    var placeholderData: PlaceholderData?
    
    enum TokenType {
        case token(String)
        case plain(String)
    }
    
    var tokens: [TokenType] = []
    var tokenBackgroundColor: NSColor = .lightGray
    var tokenTextColor: NSColor = .black
   
    var needsRegen = false
    
    // TODO: bind this to a variable
    var validTokens: [String] = ["@user1", "@user2", "@groupA"]
    
    
    override func copy(_ sender: Any?) {
        let pasteboard = NSPasteboard.general
        
        let range = self.selectedRange()
        let sel = attributedString().attributedSubstring(from: range)
        
        pasteboard.declareTypes([.string], owner: nil)
        var myData: [MyCustomData] = []
        
        var outString = ""
        
        sel.enumerateAttributes(in: NSRange(location: 0, length: sel.length), options: []) { (attributes, range, stop) in
          
            
            let ancillaryData = attributes[.tokenData] as? String
            let substring = sel.attributedSubstring(from: range).string
      
//            print(substring)
//            dump(range)

            if ancillaryData != nil {
                myData.append(MyCustomData(name: "token", value: ancillaryData!))
                outString.append(ancillaryData!)
            } else {
                myData.append(MyCustomData(name: "plain", value: substring))
                outString.append(substring)
            }
        }

        let encoder = JSONEncoder()
        let myEncodedData = try? encoder.encode(myData)
        let myDataType = "com.stereowrench.placeholderText" as String
        if myEncodedData != nil {
            pasteboard.setData(myEncodedData, forType: NSPasteboard.PasteboardType(rawValue: myDataType))
        }
//        pasteboard.setData(sel, forType: NSPasteboard.PasteboardType.string)
        // TODO add placeholders to string
        
        pasteboard.setString(outString, forType: .string)

    }

//    func copyToPasteboard() {
//        let pasteboard = NSPasteboard.general
//        pasteboard.clearContents()
//        pasteboard.writeObjects([MyCustomData(name: "Initial Data", value: 123) ])
//    }
    
//    enum ModifyType {
//        case token
//        case plain
//    }
 
    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
        regenerateString()
    }
    
    init(frame frameRect: NSRect, placeholderData: PlaceholderData) {
        self.placeholderData = placeholderData
        super.init(frame: frameRect)
        regenerateString()
//        super.init(frame: NSRect.zero, textContainer: nil) // FIXME: this may be wrong
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var completionWords: [String] = ["apple", "banana", "cherry", "date", "elderberry"] // Your completion suggestions
    var completionWindow: NSWindow?
    
    override func keyDown(with event: NSEvent) {
        if completionWindow?.isVisible == true {
            if event.keyCode ==  126 {
                // TODO: up arrow
                return
            } else if event.keyCode == 125 {
                // TODO: down arrow
                return
            } else if event.keyCode == 53 {
                hideCompletionWindow()
                return
            }
        }
        
        super.keyDown(with: event)
    }
    
    func cursorPositionForCompletion() -> NSPoint? {
        // TODO: delme
        guard let range = selectedRanges.first as? NSRange,
              let layoutManager = layoutManager,
              let textContainer = textContainer else {
            print("didn't make it")
            return nil
        }
        
        print("made it")
        
        dump(range.location)
       
//        let characterIndex = range.location
//
//        let glyphRect = layoutManager.boundingRect(forGlyphRange: NSRange(location: characterIndex, length: 1), in: textContainer)
//
//        let windowRect = self.convert(glyphRect, to: nil)
//
//        let screenOrigin = self.window?.convertToScreen(windowRect).origin ?? .zero
//
//        let adjustedLocation = NSPoint(x: screenOrigin.x, y: screenOrigin.y - glyphRect.height)
//        return adjustedLocation

        let myRange = NSMakeRange(range.location, range.length)

        let glyphRange = layoutManager.glyphRange(forCharacterRange: myRange, actualCharacterRange: nil)
//        layoutManager.bou
        var rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)

        layoutManager.lineFragmentRect(forGlyphAt: glyphRange.location, effectiveRange: nil, withoutAdditionalLayout: true)
        
//         Convert the rect to window coordinates
        rect = self.convert(rect, to: nil)
        
        let location = self.window?.convertToScreen(rect).origin ?? .zero

//         Adjust the vertical position to be below the cursor
        let adjustedLocation = NSPoint(x: location.x, y:(location.y - rect.height))

        return adjustedLocation
    }
    
    func showCompletionWindow() {
        if completionWindow == nil {
            let contentView = CompletionView(words: completionWords)
            completionWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 200, height: 100),
                                       styleMask: [.borderless],
                                       backing: .buffered,
                                       defer: false)
            completionWindow?.contentView = contentView
            completionWindow?.hasShadow = true
        }

        // Calculate position based on cursor location
        let location = cursorPositionForCompletion()
            
        if location != nil && completionWindow != nil {
            let newLocation = NSPoint(x: location!.x, y: location!.y - completionWindow!.frame.height / 2 - ((self.font?.capHeight ?? 0) * 4))
//            let newLocation = location
            completionWindow?.setFrameOrigin(newLocation)
            completionWindow?.makeKeyAndOrderFront(nil)
            needsDisplay = true
        }

    }

    func hideCompletionWindow() {
        completionWindow?.orderOut(nil)
    }
    
    func regenerateData() {
        var newData: PlaceholderData = PlaceholderData()
        
        attributedString().enumerateAttributes(in: NSRange(location: 0, length: attributedString().length), options: []) { (attributes, range, stop) in
            
            let ancillaryData = attributes[.tokenData] as? String
            let substring = attributedString().attributedSubstring(from: range).string
         
            if ancillaryData != nil {
                newData.data.append(PlaceholderEntry(type: .token(ancillaryData!)))
            } else {
                newData.data.append(PlaceholderEntry(type: .plain(substring)))
            }
        }
        
        self.placeholderData = newData
        self.needsRegen = false
    }
   
    func regenerateString() {
        clearTokens()
        for data in placeholderData?.data ?? [] {
            switch(data.type) {
                case .plain(let str):
                    addStringToken(string: str)
                case .token(let str):
                    addToken(string: str)
            }
        }
    }
    
    func getTokenAttributes() -> [NSAttributedString.Key: Any] {
//        let currentText = self.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
//        let myAncillaryDataKey = NSAttributedString.Key("com.stereowrench.tokenData")
        self.attributedString()
        return [
            .foregroundColor: NSColor.blue,
            .backgroundColor: NSColor.lightGray,
//            myAncillaryDataKey: NSRange(location: self.attributedString().length, length: self.attributedString().length + 1) // Store the token range
        ]
    }
    
//    func handleDataChange() {
//        let myAncillaryDataKey = attrKey
//        let attributedString = self.attributedString()
//        let fullRange = NSRange(location: 0, length: attributedString.length)
//        attributedString.enumerateAttributes(in: fullRange, options: []) { (attributes, range, stop) in
//            if let ancillaryData = attributes[myAncillaryDataKey] as? [String: Any] {
//                print("Ancillary data for range \(range): \(ancillaryData)")
//                // Access specific data:
//                let substring = attributedString.attributedSubstring(from: range).string
//                
//                if let tokenType = ancillaryData["tokenType"] as? String {
//                    print("Token type \(tokenType), content: \(substring)")
//                }
//            }
//        }
//    }
    
    func clearTokens() {
        textStorage?.setAttributedString(NSMutableAttributedString())
    }
    
    func addToken(string: String) {
        print("adding token")
        let attributedToken = NSMutableAttributedString()
       
        
        let attachment = PlaceholderAttachment()
//        attachment.label = string
        attachment.setLabel(label: string)
        self.needsDisplay = true
//        attachment.textLayoutManager = textLayoutManager
        let attachmentAttributedString = NSMutableAttributedString(attachment: attachment)

        attachmentAttributedString.addAttribute(.tokenData, value: string, range: NSRange(location: 0, length: attachmentAttributedString.length))
       
        attributedToken.append(self.attributedString())
        
   
        let insertionPoint = selectedRange().location // TODO: do this to addStringToken

        
        attributedToken.insert(attachmentAttributedString, at: insertionPoint)
        textStorage?.setAttributedString(attributedToken)
        setSelectedRange(NSRange(location: insertionPoint + 1, length: 0))
    }
    
    func addStringToken(string: String) {
        let attributedToken = NSMutableAttributedString()
        attributedToken.append(self.attributedString())
        attributedToken.append(NSAttributedString(string: string))
        textStorage?.setAttributedString(attributedToken)
    }
}
#elseif os(iOS)
#endif
