//
//  SendMessageView.swift
//  TRIAL
//
//  Created by Aaron Ge on 2023/5/4.
//

import SwiftUI

struct SendMessageView: View {
    @EnvironmentObject var manager: NetworkManager
    var usedIps: [String]
    
    
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Toggle("Send with Hex", isOn: $manager.sendHexFormat)
                    
                    Spacer()
                    
                    
                    Toggle("Loop sending", isOn: $manager.sendLoop)
                    
                    
                    TextFieldWithSuffix(number: $manager.loopMs,
                                        text: $manager.loopMsText,
                                        loopSend: $manager.sendLoop)
                    
                    
                    Spacer()
                    Picker("To remote host", selection: $manager.remoteIp) {
                        ForEach(usedIps){ip in
                            Text(ip)
                                .font(.subheadline)
                                .tag(ip)
                            
                            
                        }
                    }
//                    .border(.bar)
                    
                    .pickerStyle(.menu)
                    .bold()
                    
                }
                
                Button(manager.isClientConnected ? "Stop" : "Send") {
                    if (manager.isClientConnected){
                        Task
                        {
                            if (manager.type.rawValue.hasPrefix("TCP"))
                            {
                                try await manager.stopTcpSendLoop()
                            }
                            else{
                                try await manager.stopUdpLoop()
                            }
                        }
                    }
                    
                    else{
                        Task{
                            if (manager.type.rawValue.hasPrefix("TCP"))
                            {
                                try await manager.sendTcpMessage()
                            }
                            else{
                                try await manager.sendUdpMessage()
                            }
                            
                        }
                    }
                    
                }
                .buttonStyle(.borderedProminent)
                .disabled(manager.type.rawValue.hasSuffix("Server") || manager.sendMessage.count == 0)
            }
            .padding()
            .edgesIgnoringSafeArea(.all)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        
        
        
    }
}


struct SendMessageView_Previews: PreviewProvider {
    static var previews: some View {
        SendMessageView(usedIps:[])
    }
}



