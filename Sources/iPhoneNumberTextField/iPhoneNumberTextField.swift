import SwiftUI
import UIKit


@available(iOS 13.0, *)
/// A text field view representable struct that formats the number being
/// inputted for the user, but preserves an unformatted underlying number
/// in code
public struct iPhoneNumberTextField: UIViewRepresentable {
    
    private var placeholder: String
    @Binding private var text: String
    @Binding private var isEditing: Bool
    
    private var didBeginEditing: () -> Void = { }
    private var didChange: () -> Void = { }
    private var didEndEditing: () -> Void = { }
    
    private var font: UIFont?
    private var foregroundColor: UIColor?
    private var accentColor: UIColor?
    private var textAlignment: NSTextAlignment?
    private var contentType: UITextContentType = .telephoneNumber
    
    private var autocorrection: UITextAutocorrectionType = .default
    private var autocapitalization: UITextAutocapitalizationType = .sentences
    private var keyboardType: UIKeyboardType = .phonePad
    private var returnKeyType: UIReturnKeyType = .default
    
    private var isSecure: Bool = false
    private var isUserInteractionEnabled: Bool = true
    private var clearsOnBeginEditing: Bool = false
    
    @Environment(\.layoutDirection) private var layoutDirection: LayoutDirection
    
    /// Initializes a new phone number text field, which formats a phone number in real time while the user is typing. The underlying `String` binding remains unformatted.
    /// - Parameters:
    ///   - placeholder: The formatted text to appear in the text field's placeholder
    ///   - text: A binding to the underlying phone number `String`
    ///   - isEditing: A binding to whether the text field is being edited
    ///   - didBeginEditing: A funciton called when the text field starts being edited
    ///   - didChange: A function called when the text field text changes
    ///   - didEndEditing: A function called when the text field stops being edited
    public init(_ placeholder: String,
                text: Binding<String>,
                isEditing: Binding<Bool>,
                didBeginEditing: @escaping () -> Void = { },
                didChange: @escaping () -> Void = { },
                didEndEditing: @escaping () -> Void = { })
    {
        self.placeholder = placeholder
        self._text = text
        self._isEditing = isEditing
        self.didBeginEditing = didBeginEditing
        self.didChange = didChange
        self.didEndEditing = didEndEditing
    }
    
    public func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        
        textField.delegate = context.coordinator
        
        textField.placeholder = placeholder
        textField.text = text.toPhoneNumber()
        textField.font = font
        textField.textColor = foregroundColor
        if let textAlignment = textAlignment {
            textField.textAlignment = textAlignment
        }
        textField.textContentType = contentType
        if let accentColor = accentColor {
            textField.tintColor = accentColor
        }
        textField.autocorrectionType = autocorrection
        textField.autocapitalizationType = autocapitalization
        textField.keyboardType = keyboardType
        textField.returnKeyType = returnKeyType
        
        textField.clearsOnBeginEditing = clearsOnBeginEditing
        textField.isSecureTextEntry = isSecure
        textField.isUserInteractionEnabled = isUserInteractionEnabled
        if isEditing {
            textField.becomeFirstResponder()
        }
        
        textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange(_:)), for: .editingChanged)
        
        
        return textField
    }
    
    public func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text.toPhoneNumber()
        if isEditing {
            uiView.becomeFirstResponder()
        } else {
            uiView.resignFirstResponder()
        }
    }
    
    
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text,
                           isEditing: $isEditing,
                           didBeginEditing: didEndEditing,
                           didChange: didChange,
                           didEndEditing: didEndEditing)
    }
    
    final public class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        @Binding var isEditing: Bool
        
        var didBeginEditing: () -> Void
        var didChange: () -> Void
        var didEndEditing: () -> Void
        
        init(text: Binding<String>, isEditing: Binding<Bool>, didBeginEditing: @escaping () -> Void, didChange: @escaping () -> Void, didEndEditing: @escaping () -> Void) {
            self._text = text
            self._isEditing = isEditing
            self.didBeginEditing = didBeginEditing
            self.didChange = didChange
            self.didEndEditing = didEndEditing
        }
        
        public func textFieldDidBeginEditing(_ textField: UITextField) {
            DispatchQueue.main.async { [self] in
                if !isEditing {
                    isEditing = true
                }
                if textField.clearsOnBeginEditing {
                    text = ""
                }
                didBeginEditing()
            }
        }
        
        @objc func textFieldDidChange(_ textField: UITextField) {
            text = textField.text?.unformatPhoneNumber() ?? ""
            
            let newPosition = textField.endOfDocument
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            
            didChange()
        }
        
        public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            DispatchQueue.main.async {
                if self.isEditing {
                    self.isEditing = false
                }
                self.didEndEditing()
            }
        }
        
        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            isEditing = false
            return false
        }
    }
}

@available(iOS 13.0, *)
extension iPhoneNumberTextField {
    /// Modies the font of the phone number text field
    /// - Parameter font: The placeholder and text field font
    /// - Returns: A phone number text field with updated font
    /// - Warning: Accepts a `UIFont` object, not a `Font` object
    public func uiFont(_ font: UIFont?) -> iPhoneNumberTextField {
        var view = self
        view.font = font
        return view
    }
    
    /// Modifies the text color of the phone number text field
    /// - Parameter color: The text color
    /// - Returns: A phone number text field with updated text color
    @available(iOS 14, *)
    public func foregroundColor(_ color: Color?) -> iPhoneNumberTextField {
        var view = self
        if let color = color {
            view.foregroundColor = UIColor(color)
        }
        return view
    }
    
    /// Modifies the cursor color of the phone number text field
    /// - Parameter accentColor: The cursor color
    /// - Returns: A phone number text field with updated cursor color
    @available(iOS 14, *)
    public func accentColor(_ accentColor: Color?) -> iPhoneNumberTextField {
        var view = self
        if let accentColor = accentColor {
            view.accentColor = UIColor(accentColor)
        }
        return view
    }
    
    /// Modifies the text alignment of a phone number text field
    /// - Parameter alignment: The desired alignment
    /// - Returns: A phone number text field with updated text alignment
    public func multilineTextAlignment(_ alignment: TextAlignment) -> iPhoneNumberTextField {
        var view = self
        switch alignment {
        case .leading:
            view.textAlignment = layoutDirection ~= .leftToRight ? .left : .right
        case .trailing:
            view.textAlignment = layoutDirection ~= .leftToRight ? .right : .left
        case .center:
            view.textAlignment = .center
        }
        return view
    }
    
    /// Modifies the clear-on-begin-editing setting of a phone number text field
    /// - Parameter shouldClear: Whether the text field should clear on editing beginning
    /// - Returns: A phone number text field with updated clear-on-begin-editing settings
    public func clearsOnBeginEditing(_ shouldClear: Bool) -> iPhoneNumberTextField {
        var view = self
        view.clearsOnBeginEditing = shouldClear
        return view
    }
    
    /// Modifies whether the phone number text field is disabled
    /// - Parameter disabled: Whether the text field is disabled
    /// - Returns: A phone number text field with updated disabled settings
    public func disabled(_ disabled: Bool) -> iPhoneNumberTextField {
        var view = self
        view.isUserInteractionEnabled = !disabled
        return view
    }
}

extension String {
    fileprivate func unformatPhoneNumber() -> String {
        let noSpaces = self.replacingOccurrences(of: " ", with: "")
        let noDashes = noSpaces.replacingOccurrences(of: "-", with: "")
        let noLeadingPar = noDashes.replacingOccurrences(of: "(", with: "")
        let noTrailingPar = noLeadingPar.replacingOccurrences(of: ")", with: "")
        
        return noTrailingPar
    }
    
    fileprivate func toPhoneNumber() -> String {
        if self.count >= 2 && self.prefix(1) == "+" {
            if self.prefix(2) != "+1" {
                return self
            } else {
                let afterCountry = String(self.suffix(self.count - 2))
                let count = afterCountry.count
                if count < 1 {
                    return self
                } else if count < 2 {
                    return "+1 (" + afterCountry + "  )"
                } else if count < 3 {
                    return "+1 (" + afterCountry + " )"
                } else if count < 4 {
                    return "+1 (" + afterCountry + ")"
                } else if count < 7 {
                    return "+1 (" + afterCountry.prefix(3) + ") " + afterCountry.suffix(count - 3)
                } else if count < 11 {
                    let first = afterCountry.prefix(3)
                    let afterArea = String(afterCountry.suffix(count - 3))
                    let second = String(afterArea.prefix(3))
                    let third = String(afterArea.suffix(afterArea.count - 3))
                    return "+1 (" + first + ") " + second + "-" + third
                } else {
                    return "+1 " + afterCountry
                }
            }
        }
        if self.count <= 3 {
            return self
            
        } else if self.count <= 7 {
            let first = self.prefix(3)
            let second = self.suffix(self.count - 3)
            return String(first) + "-" + String(second)
            
        } else if self.count <= 10 {
            let first = self.prefix(3)
            
            let secondStart = self.index(self.startIndex, offsetBy: 3)
            let secondEnd = self.index(self.startIndex, offsetBy: 6)
            let secondRange = secondStart..<secondEnd
            let second = self[secondRange]
            
            let third = self.suffix(self.count - 6)
            
            return "(" + String(first) + ") " + String(second) + "-" + String(third)
        } else {
            return self
            //  return String(self.prefix(10)).toPhoneNumber()
        }
    }
}
