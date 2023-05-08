//
//  NetworkManager.swift
//  TRIAL
//
//  Created by Aaron Ge on 2023/4/28.
//

import SwiftUI
import NIOCore
import NIOPosix
import CoreData

enum NetworkType: String, CaseIterable, Identifiable {
    case TCPServer, TCPClient, UDPServer, UDPClient
    var id : Self {self}
    
}

/// NetworkManager is the main class that manages the network connection.
/// It is responsible for creating the server and the client.
///
class NetworkManager: ObservableObject {
    
    @Published var localIP: [String] = ["127", "0", "0", "1"]
    @Published var localPort: Int = 1234
    @Published var type: NetworkType = .TCPServer
    @Published var isServerConnected = false
    @Published var isClientConnected = false
    
    /// The last message received.
    @Published var lastMessage: String = ""
    
    /// All the messages received.
    @Published var AllMessages: String = ""
    
    /// The message to be sent.
    @Published var sendMessage: String = ""
    
    /// The message received showed in hex format.
    @Published var showHexFormat = false
    /// The message received showed with time stamp.
    @Published var showTimeStamp = false
    /// The message to be sent showed in hex format.
    @Published var sendHexFormat = false
    
    @Published var sendLoop = false
    @Published var loopMs: Int = 20
    @Published var loopMsText = "20"
    @Published var remoteIp = "127.0.0.1:1234"
    
    
    private var eventLoopGroup: MultiThreadedEventLoopGroup?
    private var tcpServerChannel: Channel?
    private var tcpClientChannel: Channel?
    private var udpServerChannel: Channel?
    private var udpClientChannel: Channel?
    
    
    ///
    /// Start the TCP server.
    /// - Throws:
    func startTcpServer() async throws {
        
        let ip = localIP.reduce("") {
            $0 + "." + $1
        }
            .dropFirst(1)
        
        
        guard let localhost = try? SocketAddress(ipAddress: String(ip), port: localPort)
        else {
            throw NetworkError.ServerError(reason: "Bad address!")
            
        }
        
        DispatchQueue.global(qos: .background).async {
            let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
            //            self.eventLoopGroup = group
            let bootstrap = ServerBootstrap(group: group)
                .serverChannelOption(ChannelOptions.backlog, value: 256)
                .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
                .childChannelInitializer { channel in
                    channel.pipeline.addHandlers([TCPMessageEchoHandler(manager: self), TCPStatusHandler()])
                }
            do {
                let channel = try bootstrap.bind(to: localhost).wait()
                self.eventLoopGroup = group
                self.tcpServerChannel = channel
                DispatchQueue.main.async {
                    self.isServerConnected = true
                }
                print("Server started and listening on \(channel.localAddress!)")
                
                //        }
            } catch {
                DispatchQueue.main.async {
                    self.isServerConnected = false
                }
                
                group.shutdownGracefully { error in
                    print(error!.localizedDescription)
                }
            }
            
        }
        
        
    }
    
    ///
    /// Stop the TCP server.
    /// - Throws:
    func stopTcpServer() async throws {
        
        DispatchQueue.main.async {
            self.isServerConnected = false
        }
        
        
        try await tcpServerChannel?.close()
        
        eventLoopGroup?.shutdownGracefully(queue: .global(qos: .background)) {
            if let err = $0 {
                print(err.localizedDescription)
            }
            
        }
    }
    
    
    ///
    /// Send a message from the TCP client.
    func sendTcpMessage() async throws {
        
        DispatchQueue.global(qos: .background).async {
            let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
            let bootStrap = ClientBootstrap(group: group)
                .channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
                .channelInitializer { channel in
                    channel.pipeline.addHandlers([TCPMessageEchoHandler(manager: self), TCPStatusHandler()])
                }
            
            self.eventLoopGroup = group
            
            do {
                let serverAddress = try SocketAddress(ipAddress: self.remoteIp.components(separatedBy: ":")[0],
                                                      port: Int(self.remoteIp.components(separatedBy: ":")[1])!)
                
                let channel = try bootStrap.connect(to: serverAddress).wait()
                defer {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.isClientConnected = false
                        channel.close(promise: nil)
                        group.shutdownGracefully {
                            if let error = $0 {
                                print(error.localizedDescription)
                            }
                        }
                    }
                    
                }
                //                self.tcpClientChannel = channel
                DispatchQueue.main.async {
                    self.isClientConnected = true
                    var buffer = channel.allocator.buffer(capacity: self.sendMessage.utf8.count)
                    buffer.writeString(self.sendMessage)
                    do {
                        try channel.writeAndFlush(buffer).wait()
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                    if (self.sendLoop) {
                        //                        channel.close(promise: nil)
                        //                        DispatchQueue.main.async {
                        //                            self.isClientConnected = false
                        //                        }
                        
                        channel.eventLoop.scheduleRepeatedTask(initialDelay: .milliseconds(0), delay: .milliseconds(Int64(self.loopMs))) { task in
                            var buffer = channel.allocator.buffer(capacity: self.sendMessage.utf8.count)
                            buffer.writeString(self.sendMessage)
                            channel.writeAndFlush(buffer, promise: nil)
                            
                        }
                    }
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    ///
    /// Stop the TCP client.
    /// - Throws:
    @MainActor
    func stopTcpSendLoop() async throws {
        
        if tcpClientChannel == nil{
            return
        }
        isClientConnected = false
        try await tcpClientChannel?.close()
        eventLoopGroup?.shutdownGracefully(queue: .global(qos: .background), {
            if let error = $0 {
                print(error.localizedDescription)
            }
        })
    }
    
    ///
    /// Start a UDP server
    /// - Throws:
    func startUDPServer() async throws {
        DispatchQueue.global(qos: .background).async { [self] in
            let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            let boostrap = DatagramBootstrap(group: group)
                .channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
                .channelInitializer { channel in
                    channel.pipeline.addHandler(UDPMessageChannelHandler(manager: self))
                }
            self.eventLoopGroup = group
            do {
                let channel = try boostrap.bind(host: String(self.localIP.reduce("") {
                    $0 + "." + $1
                }
                    .dropFirst()), port: self.localPort)
                    .wait()
                
                
                self.udpServerChannel = channel
                DispatchQueue.main.async {
                    self.isServerConnected = true
                }
            } catch {
                print("Start UDP server failed: \(error.localizedDescription)")
            }
        }
    }
    
    ///
    /// Stop the UDP server.
    /// - Throws:
    @MainActor
    func stopUDPServer() async throws {
        isServerConnected = false
        try await udpServerChannel?.close()
        eventLoopGroup?.shutdownGracefully(queue: .global(qos: .background), {
            if let error = $0 {
                print(error.localizedDescription)
            }
        })
    }
    
    ///
    /// Send a UDP message.
    /// - Throws:
    func sendUdpMessage() async throws {
        DispatchQueue.global(qos: .background).async { [self] in
            let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            let boostrap = DatagramBootstrap(group: group)
                .channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
                .channelInitializer { channel in
                    channel.pipeline.addHandler(UDPMessageChannelHandler(manager: self))
                }
            self.eventLoopGroup = group
            do {
                let channel = try boostrap.bind(host: String(self.localIP.reduce("") {
                    $0 + "." + $1
                }
                    .dropFirst()), port: self.localPort)
                    .wait()
                self.udpClientChannel = channel
                DispatchQueue.main.async { [self] in
                    isClientConnected = true
                }
            } catch {
                print("Send UDP Message failed: \(error.localizedDescription)")
            }
            
            defer {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.isClientConnected = false
                }
                
                udpClientChannel!.close(promise: nil)
                eventLoopGroup!.shutdownGracefully(queue: .global(qos: .background), {
                    if let error = $0 {
                        print("Fail to close eventGroup: \(error.localizedDescription)")
                    }
                })
            }
            
            if sendLoop {
                
                
                guard udpClientChannel != nil else{
                    print ("Nil Channel")
                    return
                    
                }
                udpClientChannel!.eventLoop.scheduleRepeatedTask(initialDelay: .milliseconds(0), delay: .milliseconds(Int64(loopMs))) { [self] task in
                    var buffer = udpClientChannel!.allocator.buffer(capacity: sendMessage.utf8.count)
                    buffer.writeString(sendMessage)
                    udpClientChannel!.writeAndFlush(buffer, promise: nil)
                    
                }
            } else {
                DispatchQueue.main.async { [self] in
                    isClientConnected = true
                }
                var buffer = udpClientChannel!.allocator.buffer(capacity: sendMessage.utf8.count)
                buffer.writeString(sendMessage)
                udpClientChannel!.writeAndFlush(buffer, promise: nil)
            }
        }
    }
    
    @MainActor
    func stopUdpLoop() async throws{
        
        isClientConnected = false
        try await udpClientChannel?.close()
        eventLoopGroup?.shutdownGracefully(queue: .global(qos: .background), {
            if let error = $0 {
                print(error.localizedDescription)
            }
        })
    }
    
    
}
