//
//  ExtraInfoView.swift
//  TRIAL
//
//  Created by Aaron Ge on 2023/5/2.
//

import SwiftUI

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            configuration.isOn
                ? Image(systemName: "checkmark.square")
                : Image(systemName: "square")
        }
//        .foregroundColor(.blue)
        .onTapGesture { configuration.isOn.toggle() }
    }
}


struct ExtraInfoView: View {
    @ObservedObject var manager: NetworkManager
    var body: some View {
        GeometryReader{ geometry in
            VStack (alignment: .leading) {
                Toggle(isOn: $manager.showHexFormat) {
                    Text("Hex Format")
                }
                //                    .toggleStyle(CheckboxToggleStyle())
                
                
                Toggle(isOn: $manager.showTimeStamp) {
                    Text("Time Stamp")
                }
                //                    .toggleStyle(CheckboxToggleStyle())
                
            }
            
            .padding()
            .frame(width: geometry.size.width,
                   height: geometry.size.height)
           
        }
    }


    
}

struct ExtraInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ExtraInfoView(manager: NetworkManager())
          
            
    }
}
