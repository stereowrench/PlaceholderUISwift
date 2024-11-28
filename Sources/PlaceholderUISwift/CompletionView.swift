//
//  CompletionView.swift
//  kitchen_script
//
//  Created by Theron Boerner on 11/26/24.
//

import Foundation
import AppKit

#if os(macOS)
class CompletionView: NSView {
    let words: [String]

    init(words: [String]) {
        self.words = words
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor.white.setFill()
        dirtyRect.fill()

        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: NSColor.black]
        let wordHeight: CGFloat = 20
        var y: CGFloat = 0
        for word in words {
            let attributedWord = NSAttributedString(string: word, attributes: attributes)
            attributedWord.draw(at: NSPoint(x: 10, y: y))
            y += wordHeight
        }
    }
}
#endif
