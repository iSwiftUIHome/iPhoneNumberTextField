//
//  Examples.swift
//  
//
//  Created by Benjamin Sage on 10/8/20.
//

import SwiftUI

struct StyleExample: View {
    @State var text = ""
    @State var isEditing = false
    
    @Environment(\.colorScheme) var colorScheme
    var darkMode: Bool { colorScheme == .dark }
    
    var backgroundGray: Double { darkMode ? 0.25 : 0.95 }
    var backgroundColor: Color { .init(white: backgroundGray) }
    
    var shadowOpacity: Double { isEditing ? 0.5 : 0 }
    var shadowGray: Double { darkMode ? 0.8 : 0.5 }
    var shadowColor: Color { Color(white: shadowGray).opacity(shadowOpacity) }
    
    var borderColor: Color {
        isEditing && darkMode ? .init(white: 0.6) : .clear
    }
    
    var font: UIFont {
        let fontSize: CGFloat = 20
        let systemFont = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            return  UIFont(descriptor: descriptor, size: fontSize)
        } else {
            return systemFont
        }
    }
    
    var body: some View {
        ZStack {
            iPhoneNumberTextField("Phone", text: $text, isEditing: $isEditing)
                .accentColor(Color(red: 0.3, green: 0.76, blue: 0.85))
                .fontFromUIFont(font)
                .padding(.horizontal, 25)
        }
        .frame(height: 58)
        .background(backgroundColor)
        .cornerRadius(6.0)
        .overlay(RoundedRectangle(cornerRadius: 6.0).stroke(borderColor))
        .padding(.horizontal, 25)
        .shadow(color: shadowColor, radius: 5, x: 0, y: 4)
    }
}

