import SwiftUI
import UIKit

@available(iOS 13.0, *)
struct PhoneNumberTextField: UIViewRepresentable {
    
    var placeholder: String
    @Binding var text: String
    @Binding var isEditing: Bool
    
    var didBeginEditing: () -> Void = { }
    var didChange: () -> Void = { }
    var didEndEditing: () -> Void = { }
    
    private var font: UIFont?
    private var foregroundColor: UIColor?
    private var accentColor: UIColor?
    private var textAlignment: NSTextAlignment?
    private var contentType: UITextContentType?
    
    private var autocorrection: UITextAutocorrectionType = .default
    private var autocapitalization: UITextAutocapitalizationType = .sentences
    private var keyboardType: UIKeyboardType = .phonePad
    private var returnKeyType: UIReturnKeyType = .default
    
    private var isSecure: Bool = false
    private var isUserInteractionEnabled: Bool = true
    private var clearsOnBeginEditing: Bool = false
    
    @Environment(\.layoutDirection) private var layoutDirection: LayoutDirection
    
    init(_ placeholder: String,
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
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        
        textField.delegate = context.coordinator
        
        textField.placeholder = placeholder
        textField.text = text.toPhoneNumber()
        textField.font = font
        textField.textColor = foregroundColor
        if let textAlignment = textAlignment {
            textField.textAlignment = textAlignment
        }
        if let contentType = contentType {
            textField.textContentType = contentType
        }
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
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text.toPhoneNumber()
        if isEditing {
            uiView.becomeFirstResponder()
        } else {
            uiView.resignFirstResponder()
        }
    }
    
    
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text,
                           isEditing: $isEditing,
                           didBeginEditing: didEndEditing,
                           didChange: didChange,
                           didEndEditing: didEndEditing)
    }
    
    final class Coordinator: NSObject, UITextFieldDelegate {
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
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                if !self.isEditing {
                    self.isEditing = true
                }
                self.didEndEditing()
            }
        }
        
        @objc func textFieldDidChange(_ textField: UITextField) {
            text = textField.text?.unformatPhoneNumber() ?? ""
            
            let newPosition = textField.endOfDocument
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            
            didChange()
        }
        
        func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            DispatchQueue.main.async {
                if self.isEditing {
                    self.isEditing = false
                }
                self.didEndEditing()
            }
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            isEditing = false
            return false
        }
    }
}

@available(iOS 13.0, *)
extension PhoneNumberTextField {
    func font(_ font: UIFont?) -> PhoneNumberTextField {
        var view = self
        view.font = font
        return view
    }
    
    @available(iOS 14, *)
    func foregroundColor(_ color: Color?) -> PhoneNumberTextField {
        var view = self
        if let color = color {
            view.foregroundColor = UIColor(color)
        }
        return view
    }
    
    @available(iOS 14, *)
    func accentColor(_ accentColor: Color?) -> PhoneNumberTextField {
        var view = self
        if let accentColor = accentColor {
            view.accentColor = UIColor(accentColor)
        }
        return view
    }
    
    func foregroundColor(_ color: UIColor?) -> PhoneNumberTextField {
        var view = self
        view.foregroundColor = color
        return view
    }
    
    func accentColor(_ accentColor: UIColor?) -> PhoneNumberTextField {
        var view = self
        view.accentColor = accentColor
        return view
    }
    
    func multilineTextAlignment(_ alignment: TextAlignment) -> PhoneNumberTextField {
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
    
    func textContentType(_ textContentType: UITextContentType?) -> PhoneNumberTextField {
        var view = self
        view.contentType = textContentType
        return view
    }
    
    func disableAutocorrection(_ disable: Bool?) -> PhoneNumberTextField {
        var view = self
        if let disable = disable {
            view.autocorrection = disable ? .no : .yes
        } else {
            view.autocorrection = .default
        }
        return view
    }
    
    func autocapitalization(_ style: UITextAutocapitalizationType) -> PhoneNumberTextField {
        var view = self
        view.autocapitalization = style
        return view
    }
    
    func keyboardType(_ type: UIKeyboardType) -> PhoneNumberTextField {
        var view = self
        view.keyboardType = type
        return view
    }
    
    func returnKeyType(_ type: UIReturnKeyType) -> PhoneNumberTextField {
        var view = self
        view.returnKeyType = type
        return view
    }
    
    func isSecure(_ isSecure: Bool) -> PhoneNumberTextField {
        var view = self
        view.isSecure = isSecure
        return view
    }
    
    func clearsOnBeginEditing(_ shouldClear: Bool) -> PhoneNumberTextField {
        var view = self
        view.clearsOnBeginEditing = shouldClear
        return view
    }
    
    func disabled(_ disabled: Bool) -> PhoneNumberTextField {
        var view = self
        view.isUserInteractionEnabled = disabled
        return view
    }
}

extension String {
    func unformatPhoneNumber() -> String {
        let noSpaces = self.replacingOccurrences(of: " ", with: "")
        let noDashes = noSpaces.replacingOccurrences(of: "-", with: "")
        let noLeadingPar = noDashes.replacingOccurrences(of: "(", with: "")
        let noTrailingPar = noLeadingPar.replacingOccurrences(of: ")", with: "")
        
        return noTrailingPar
    }
    
    func toPhoneNumber() -> String {
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
            return String(self.prefix(10)).toPhoneNumber()
        }
    }
}
