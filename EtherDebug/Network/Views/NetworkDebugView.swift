//
//  NetworkDebugView.swift
//  TRIAL
//
//  Created by Aaron Ge on 2023/4/28.
//

import SwiftUI
import NIOCore
import CoreData



struct NetworkDebugView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var manager = NetworkManager()
    
    @FetchRequest(entity: SocketAddressEntity.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \SocketAddressEntity.lastUsedAt, ascending: false)])
    var usedIps: FetchedResults<SocketAddressEntity>
    
    //    @FetchRequest(entity: Ipv4Address.entity(), sortDescriptors: [])
    //    private var usedIp:
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 10) {
            
            VStack(alignment: .leading){
                //                    Spacer()
                
                Section("Network Config"){
                    VStack {
                        NetworkCofigView(manager: manager)
                           
                        
                        HStack(alignment: .center) {
                            Button(action: {
                                
                                manager.AllMessages = ""
                                if (manager.type.rawValue.hasSuffix("Client"))
                                {
                                    
                                    var ip  = manager.localIP.reduce("") {
                                        $0 + "." + $1
                                    }.dropFirst()
                                    ip += ":\(manager.localPort)"
                                    
                                    addSocketAddressEntity(address: String(ip))
                                    manager.remoteIp = String(ip)
                                }
                            })
                            {
                                if (manager.type.rawValue.hasSuffix("Server"))
                                {
                                    Text("Fresh")
                                        .font(.subheadline)
                                    //                            .frame(minWidth: 100)
                                        .cornerRadius(10)
                                }
                                
                                else{
                                    Text("Add")
                                        .font(.subheadline)
                                    //                            .frame(minWidth: 100)
                                        .cornerRadius(10)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            
                            
                            Button(action: {
                                if(manager.isServerConnected)
                                {
                                    Task{
                                        do{
                                            if manager.type.rawValue.hasPrefix("UDP"){
                                                try await manager.stopUDPServer()
                                            }
                                            else{
                                                try await manager.stopTcpServer()
                                            }
                                        }
                                        catch{
                                            print(error.localizedDescription)
                                        }
                                    }
                                }
                                
                                else{
                                    Task{
                                        do{
                                            if manager.type.rawValue.hasPrefix("UDP"){
                                                try await manager.startUDPServer()
                                            }
                                            else{
                                                try await manager.startTcpServer()
                                            }
                                        }
                                        catch
                                        {
                                            print("Fail to start server : \(error.localizedDescription)")
                                        }
                                    }
                                    
                                    
                                }
                                
                            }) {
                                Text(manager.isServerConnected ? "End" : "Start")
                                    .font(.subheadline)
                                //                        .frame(minWidth: 100)
                                    .buttonStyle(.bordered)
                                    .cornerRadius(10)
                                
                            }
                            .disabled(manager.type.rawValue.hasSuffix("Client"))
                            .buttonStyle(.borderedProminent)
                            //                .frame(minWidth: 200)
                        }
                    }
                }
                
                .padding()
                
                Spacer()
                
                Section("Receive Config") {
                    ExtraInfoView(manager: manager)
//                  
                        
                }
                .padding()
                //                        .border(.brown)
                
                
                
                Spacer()
                
                
                
                Section("Send Config"){
                    SendMessageView(manager: manager, usedIps: usedIps.compactMap{$0.address})
                        .environmentObject(manager)
                        .environment(\.managedObjectContext, viewContext)
                        .task {
                            if let address = usedIps.first?.address{
                                manager.remoteIp = address
                            }
                        }
                }
                .padding()
            }
            
            
            
            VStack(alignment: .leading) {
                
                Section("Received messages"){
                    TextEditor(text: $manager.AllMessages)
                    //                        .border(.bar)
                    //                        .textFieldStyle(.roundedBorder)
                        .background(.foreground)
                        .border(.bar)
                        .cornerRadius(10)
                    
                    
                    
                    //                        .background()
                    //                        .border(.brown)
                }
                
                
                Spacer()
                Section("Message to send"){
                    
                    TextField("", text: $manager.sendMessage)
                        .textFieldStyle(.roundedBorder)
                        .frame(height: 80)
                    
                    //                    (text: $manage.sendMessage)
                    //                        .border(.bar)
                        .background(.clear)
                    
                    //                        .border(.brown)
                }
                
                
                
            }
            
            .background(Color.clear)
        }
        
        
        
    }

}


extension NetworkDebugView{
    private func addSocketAddressEntity(address: String){
        let fetchRequest = SocketAddressEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "address == %@", address)
        
        do{
            let existed = try viewContext.fetch(fetchRequest)
            if existed.isEmpty{
                let ip = SocketAddressEntity(context: viewContext)
                ip.address = address
                ip.lastUsedAt = Date.now
                try viewContext.save()
            }
        }
        catch{
            print("Fail to add used Address: \(error.localizedDescription)")
            viewContext.rollback()
        }
    }
}

struct NetworkDebugView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkDebugView()
    }
}
