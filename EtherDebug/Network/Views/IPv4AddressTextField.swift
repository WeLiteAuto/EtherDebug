//
//  IPv4AddressTextField.swift
//  TRIAL
//
//  Created by Aaron Ge on 2023/4/28.
//

import SwiftUI

struct IPv4AddressTextField: View {
    @Binding var ipv4Address: [String]
    var body: some View {
        HStack {
            ForEach(0..<4) { index in
                TextField("2", text: $ipv4Address[index])
                    .onReceive(ipv4Address[index].publisher.collect()) {
                        let filtered = String($0.prefix(3).filter { "0123456789".contains($0) })
                        if filtered != ipv4Address[index] {
                            ipv4Address[index] = filtered
                        }
                    }
                    .frame(width: 40)
                
                if index < 3 {
                    Text(".")
                }
            }
        }
        .textFieldStyle(.roundedBorder)
//        .background(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
    }
}

struct IPv4AddressTextField_Previews: PreviewProvider {
    static var previews: some View {
        IPv4AddressTextField(ipv4Address: .constant(["192", "168", "0","1"]))
    }
}
