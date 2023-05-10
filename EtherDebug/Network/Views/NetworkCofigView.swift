//
//  NetworkCofigView.swift
//  TRIAL
//
//  Created by Aaron Ge on 2023/4/28.
//

import SwiftUI


//let freshString = NSLocalizedString("Fresh", comment: "Fresh messages")

struct NetworkCofigView: View {
    @ObservedObject var manager: NetworkManager
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    var body: some View {
        
//        GeometryReader {geometry in
            VStack(alignment: .leading) {
                Picker("Network type", selection: $manager.type) {
                    ForEach(NetworkType.allCases) {
                        Text($0.rawValue)
                            .font(.subheadline)
                            .tag($0)
                    }
                }
                .pickerStyle(.segmented)
//                .padding()
                .onSubmit {
                    Task{
                        try await manager.stopTcpServer()
                        try await manager.stopTcpSendLoop()
                        try await manager.stopUDPServer()
                    }
                }
//                .edgesIgnoringSafeArea(.all)
                .padding(.bottom)
                
               
                
                HStack(alignment: .center) {
                    Text("IP Address")
                        .font(.subheadline)
                    
                    IPv4AddressTextField(ipv4Address: $manager.localIP)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.subheadline)
//                        .padding(.horizontal)
                }
                .padding(.bottom)
//                .alignmentGuide(.leading, computeValue: 0)
                
                
                HStack(alignment: .center){
                    Text("Port")
                        .font(.subheadline)
                    
                    TextField("Port", value: $manager.localPort, formatter: NumberFormatter())
    //                    .frame(width: 100, height: 30, alignment: .center)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.subheadline)
                    //                        .multilineTextAlignment(.center)
//                        .padding(.horizontal)
                }
                .padding(.bottom)
                
       
                
                
//            }
//            .padding()
//            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        
    }
}



struct NetworkCofigView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkCofigView(manager: NetworkManager())
           
    }
}


