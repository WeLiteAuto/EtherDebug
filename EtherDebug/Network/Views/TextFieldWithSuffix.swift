//
//  TextFieldWithSuffix.swift
//  TRIAL
//
//  Created by Aaron Ge on 2023/5/4.
//

import SwiftUI

struct TextFieldWithSuffix: View {
    @Binding var number: Int
    @Binding var text: String
    @Binding var loopSend: Bool
    
    var body: some View {
        HStack {
            TextField("Loop Send", text: $text)
                .onChange(of: text) { newValue in
                    if let intValue = Int(newValue) {
                        number = intValue
                    } else {
                        number = 0
                    }
                }
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(.roundedBorder)
                .disabled(!loopSend)
            
            Text("ms")
        }
    }
}

struct TextFieldWithSuffix_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldWithSuffix(number: .constant(20), text: .constant("20"), loopSend: .constant(false))
    }
}
