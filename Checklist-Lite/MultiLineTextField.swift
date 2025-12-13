//
//  MultiLineTextField.swift
//  Checklist-Lite
//
//  Created by Tesfaldet Haileab on 12/12/25.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

struct MultiLineTextField: View {
    @Binding var text: String
    var placeholder: String
    var onPaste: (([String]) -> Void)?
    var onTextChange: ((String) -> Void)?
    var isFocused: Binding<Bool>
    var onSubmit: (() -> Void)? = nil
    
    var body: some View {
        #if os(iOS) || os(visionOS)
        iOSMultiLineTextField(
            text: $text,
            placeholder: placeholder,
            onPaste: onPaste,
            onTextChange: onTextChange,
            isFocused: isFocused,
            onSubmit: onSubmit
        )
        #elseif os(macOS)
        macOSMultiLineTextField(
            text: $text,
            placeholder: placeholder,
            onPaste: onPaste,
            onTextChange: onTextChange,
            isFocused: isFocused,
            onSubmit: onSubmit
        )
        #else
        TextField(placeholder, text: $text)
        #endif
    }
    
    private func handlePaste(_ pastedText: String) {
        let lines = pastedText.components(separatedBy: .newlines)
        var cleanedLines: [String] = []
        
        for line in lines {
            var cleaned = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Skip empty lines
            if cleaned.isEmpty {
                continue
            }
            
            // Remove bullets, dashes, checkboxes, and numbering
            cleaned = cleaned.replacingOccurrences(of: "^[\\s]*[-•▪▫◦‣⁃]\\s*", with: "", options: .regularExpression)
            cleaned = cleaned.replacingOccurrences(of: "^[\\s]*[⬜☐☑✅✓]\\s*", with: "", options: .regularExpression)
            cleaned = cleaned.replacingOccurrences(of: "^[\\s]*\\d+[.)]\\s*", with: "", options: .regularExpression)
            cleaned = cleaned.trimmingCharacters(in: .whitespaces)
            
            // Skip if empty after cleaning
            if !cleaned.isEmpty {
                cleanedLines.append(cleaned)
            }
        }
        
        if cleanedLines.count > 1 {
            // Multiple items detected
            onPaste?(cleanedLines)
            text = "" // Clear the field
        } else if cleanedLines.count == 1 {
            // Single item, just update text
            text = cleanedLines[0]
            onTextChange?(cleanedLines[0])
        }
    }
}

#if os(iOS) || os(visionOS)
struct iOSMultiLineTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var onPaste: (([String]) -> Void)?
    var onTextChange: ((String) -> Void)?
    var isFocused: Binding<Bool>
    var onSubmit: (() -> Void)? = nil
    
    func makeUIView(context: Context) -> UITextField {
        let textField = PasteableTextField()
        textField.placeholder = placeholder
        textField.delegate = context.coordinator
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.onPaste = { pastedText in
            handlePaste(pastedText)
        }
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        
        // Update focus
        if isFocused.wrappedValue && !uiView.isFirstResponder {
            DispatchQueue.main.async {
                uiView.becomeFirstResponder()
            }
        } else if !isFocused.wrappedValue && uiView.isFirstResponder {
            DispatchQueue.main.async {
                uiView.resignFirstResponder()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func handlePaste(_ pastedText: String) {
        let lines = pastedText.components(separatedBy: .newlines)
        var cleanedLines: [String] = []
        
        for line in lines {
            var cleaned = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Skip empty lines
            if cleaned.isEmpty {
                continue
            }
            
            // Remove bullets, dashes, checkboxes, and numbering
            cleaned = cleaned.replacingOccurrences(of: "^[\\s]*[-•▪▫◦‣⁃]\\s*", with: "", options: .regularExpression)
            cleaned = cleaned.replacingOccurrences(of: "^[\\s]*[⬜☐☑✅✓]\\s*", with: "", options: .regularExpression)
            cleaned = cleaned.replacingOccurrences(of: "^[\\s]*\\d+[.)]\\s*", with: "", options: .regularExpression)
            cleaned = cleaned.trimmingCharacters(in: .whitespaces)
            
            // Skip if empty after cleaning
            if !cleaned.isEmpty {
                cleanedLines.append(cleaned)
            }
        }
        
        if cleanedLines.count > 1 {
            // Multiple items detected
            onPaste?(cleanedLines)
            text = "" // Clear the field
        } else if cleanedLines.count == 1 {
            // Single item, just update text
            text = cleanedLines[0]
            onTextChange?(cleanedLines[0])
        }
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: iOSMultiLineTextField
        
        init(_ parent: iOSMultiLineTextField) {
            self.parent = parent
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
            parent.onTextChange?(textField.text ?? "")
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            // Call onSubmit if provided, otherwise just dismiss keyboard
            if let onSubmit = parent.onSubmit {
                onSubmit()
            } else {
                textField.resignFirstResponder()
            }
            return true
        }
    }
}

class PasteableTextField: UITextField {
    var onPaste: ((String) -> Void)?
    
    override func paste(_ sender: Any?) {
        if let pastedString = UIPasteboard.general.string {
            onPaste?(pastedString)
        } else {
            super.paste(sender)
        }
    }
}
#endif

#if os(macOS)
import AppKit

struct macOSMultiLineTextField: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var onPaste: (([String]) -> Void)?
    var onTextChange: ((String) -> Void)?
    var isFocused: Binding<Bool>
    var onSubmit: (() -> Void)? = nil
    
    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        textField.placeholderString = placeholder
        textField.delegate = context.coordinator
        textField.isBordered = false
        textField.backgroundColor = .clear
        textField.focusRingType = .none
        return textField
    }
    
    func updateNSView(_ nsView: NSTextField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
        
        // Update focus
        if isFocused.wrappedValue && nsView.window?.firstResponder != nsView {
            DispatchQueue.main.async {
                nsView.window?.makeFirstResponder(nsView)
            }
        } else if !isFocused.wrappedValue && nsView.window?.firstResponder == nsView {
            DispatchQueue.main.async {
                nsView.window?.makeFirstResponder(nil)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func handlePaste(_ pastedText: String) {
        let lines = pastedText.components(separatedBy: .newlines)
        var cleanedLines: [String] = []
        
        for line in lines {
            var cleaned = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Skip empty lines
            if cleaned.isEmpty {
                continue
            }
            
            // Remove bullets, dashes, checkboxes, and numbering
            cleaned = cleaned.replacingOccurrences(of: "^[\\s]*[-•▪▫◦‣⁃]\\s*", with: "", options: .regularExpression)
            cleaned = cleaned.replacingOccurrences(of: "^[\\s]*[⬜☐☑✅✓]\\s*", with: "", options: .regularExpression)
            cleaned = cleaned.replacingOccurrences(of: "^[\\s]*\\d+[.)]\\s*", with: "", options: .regularExpression)
            cleaned = cleaned.trimmingCharacters(in: .whitespaces)
            
            // Skip if empty after cleaning
            if !cleaned.isEmpty {
                cleanedLines.append(cleaned)
            }
        }
        
        if cleanedLines.count > 1 {
            // Multiple items detected
            onPaste?(cleanedLines)
            text = "" // Clear the field
        } else if cleanedLines.count == 1 {
            // Single item, just update text
            text = cleanedLines[0]
            onTextChange?(cleanedLines[0])
        }
    }
    
    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: macOSMultiLineTextField
        private var lastText: String = ""
        
        init(_ parent: macOSMultiLineTextField) {
            self.parent = parent
        }
        
        func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            let newText = textField.stringValue
            
            // Check if this looks like a paste operation (large text change)
            let textChange = abs(newText.count - lastText.count)
            if textChange > 1, let pastedString = NSPasteboard.general.string(forType: .string),
               newText.contains(pastedString) {
                // This is likely a paste - handle it
                parent.handlePaste(pastedString)
                lastText = newText
                return
            }
            
            parent.text = newText
            parent.onTextChange?(newText)
            lastText = newText
        }
        
        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                // Check if Command+Return (submit) or just Return (new line)
                let event = NSApp.currentEvent
                if event?.modifierFlags.contains(.command) == true {
                    // Command+Return: submit
                    if let onSubmit = parent.onSubmit {
                        onSubmit()
                    }
                    return true
                } else {
                    // Just Return: dismiss keyboard
                    control.window?.makeFirstResponder(nil)
                    return true
                }
            }
            return false
        }
    }
}
#endif

