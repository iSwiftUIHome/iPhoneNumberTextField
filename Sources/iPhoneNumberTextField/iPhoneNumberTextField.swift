import SwiftUI
import iColors
import UIKit


@available(iOS 13.0, *)
/// A text field view representable struct that formats the number being
/// inputted for the user, but preserves an unformatted underlying number
/// in code
public struct iPhoneNumberTextField: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
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
                isEditing: Binding<Bool>)
    {
        self.placeholder = placeholder
        self._text = text
        self._isEditing = isEditing
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
            DispatchQueue.main.async { [self] in
                if isEditing {
                    isEditing = false
                }
                didEndEditing()
            }
        }
        
        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            isEditing = false
            return false
        }
    }
}


@available(iOS 13.0, *)
public extension iPhoneNumberTextField {
    /// Easily add & change default styles.
    /// - Returns: some View
    func style(height: CGFloat = 58, backgroundColor: Color? = nil, accentColor: Color = Colors.DarkOceanBlue, font inputFont: UIFont? = nil, paddingLeading: CGFloat = 25, cornerRadius: CGFloat = 6, hasShadow: Bool = true) -> some View {
        var darkMode: Bool { colorScheme == .dark }
        
        let cursorColor: Color = accentColor
        let height: CGFloat = height
        let leadingPadding: CGFloat = paddingLeading
        
        var backgroundGray: Double { darkMode ? 0.25 : 0.95 }
        var backgroundColor: Color {
            if backgroundColor != nil {
                return backgroundColor!
            } else {
                return .init(white: backgroundGray)
            }
        }
        
        var shadowOpacity: Double { (isEditing && hasShadow) ? 0.5 : 0 }
        var shadowGray: Double { darkMode ? 0.8 : 0.5 }
        var shadowColor: Color { Color(white: shadowGray).opacity(shadowOpacity) }
        
        var borderColor: Color {
            isEditing && darkMode ? .init(white: 0.6) : .clear
        }
        
        var font: UIFont {
            if inputFont != nil {
                return inputFont!
            } else {
                let fontSize: CGFloat = 20
                let systemFont = UIFont.systemFont(ofSize: fontSize, weight: .regular)
                if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
                    return  UIFont(descriptor: descriptor, size: fontSize)
                } else {
                    return systemFont
                }
            }
            
        }
        
        return ZStack {
            self
                .accentColor(cursorColor)
                .fontFromUIFont(font)
                .padding(.horizontal, leadingPadding)
        }
        .frame(height: height)
        .background(backgroundColor)
        .cornerRadius(cornerRadius)
        .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(borderColor))
        .padding(.horizontal, leadingPadding)
        .shadow(color: shadowColor, radius: 5, x: 0, y: 4)
    }
}

@available(iOS 13.0, *)
extension iPhoneNumberTextField {
    /// Modifies the text field’s font from a `UIFont` object.
    /// - Parameter font: The desired font
    /// - Returns: An updated text field using the desired font
    /// - Warning: Accepts a `UIFont` object rather than SwiftUI `Font`
    /// - SeeAlso: [`UIFont`](https://developer.apple.com/documentation/uikit/uifont)
    public func fontFromUIFont(_ font: UIFont?) -> iPhoneNumberTextField {
        var view = self
        view.font = font
        return view
    }

    /// Modifies the text color of the phone number text field
    /// - Parameter color: The text color
    /// - Returns: A phone number text field with updated text color
    @available(iOS 13, *)
    public func foregroundColor(_ color: Color?) -> iPhoneNumberTextField {
        var view = self
        if let color = color {
            view.foregroundColor = UIColor.from(color: color)
        }
        return view
    }
    
    /// Modifies the cursor color of the phone number text field
    /// - Parameter accentColor: The cursor color
    /// - Returns: A phone number text field with updated cursor color
    @available(iOS 13, *)
    public func accentColor(_ accentColor: Color?) -> iPhoneNumberTextField {
        var view = self
        if let accentColor = accentColor {
            view.accentColor = UIColor.from(color: accentColor)
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
    
    /// Modifies the function called when text editing begins
    /// - Parameter action: The function called when text editing begins
    /// - Returns: An updated text field using the desired function called when text editing begins
    public func onEditingBegan(_ action: @escaping () -> Void) -> iPhoneNumberTextField {
        var view = self
        view.didBeginEditing = action
        return view
        
    }
    
    /// Modifies the function called when the user makes any changes to the text in the text field
    /// - Parameter action: The function called when the user makes any changes to the text in the text field
    /// - Returns: An updated text field using the desired function called when the user makes any changes to the text in the text field
    public func onEdit(_ action: @escaping () -> Void) -> iPhoneNumberTextField {
        var view = self
        view.didChange = action
        return view
        
    }
    
    /// Modifies the function called when text editing ends
    /// - Parameter action: The function called when text editing ends
    /// - Returns: An updated text field using the desired function called when text editing ends
    public func onEditingEnded(_ action: @escaping () -> Void) -> iPhoneNumberTextField {
        var view = self
        view.didEndEditing = action
        return view
    }
    
    /// Since Apple has not given us a way yet to parse a `Font` 🔠🔡  object, this function must be deprecated 😔. Please use `.fontFromUIFont(_:)` instead 🙂.
    /// - Parameter font:
    /// - Returns:
    @available(*, deprecated, renamed: "fontFromUIFont", message: "At this time, Apple will not let us parse a `Font` object❗️ Please use `.fontFromUIFont(_:)` instead.")
    public func font(_ font: Font?) -> some View { return EmptyView() }
    
    @available(*, deprecated, message: "If you would like to change they keyboard ⌨️ please email 📧 me (benjaminlsage@gmail.com). I didn't think anyone would need to 🙂.")
    public func keyboardType(_ type: UIKeyboardType) -> some View { return EmptyView() }
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

@available(iOS 13, *)
fileprivate extension UIColor {
    class func from(color: Color) -> UIColor {
        if #available(iOS 14, *) {
            return UIColor(color)
        } else {
            let scanner = Scanner(string: color.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
            var hexNumber: UInt64 = 0
            var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
            
            let result = scanner.scanHexInt64(&hexNumber)
            if result {
                r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                a = CGFloat(hexNumber & 0x000000ff) / 255
            }
            
            return UIColor(red: r, green: g, blue: b, alpha: a)
        }
    }
}
