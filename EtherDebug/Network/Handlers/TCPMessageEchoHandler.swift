//
// Created by Aaron Ge on 2023/4/20.
//

import Foundation
import NIO

/// A class that implements the TCP protocol.
public final class TCPMessageEchoHandler : ChannelInboundHandler {
    public typealias InboundIn = ByteBuffer
    
    private let manager: NetworkManager
    
    init(manager: NetworkManager) {
        self.manager = manager
    }
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let byteBuffer = self.unwrapInboundIn(data)
        context.write(data, promise: nil)
        DispatchQueue.main.async {
            
            self.manager.lastMessage = byteBuffer.getString(at: byteBuffer.readerIndex, length: byteBuffer.readableBytes) ?? ""
            
            
            
            if self.manager.showHexFormat{
                self.manager.lastMessage = self.manager.lastMessage.unicodeScalars.reduce("", {
                    $0 + String(format: "%02X", $1.value)
                })
            }
            
            if self.manager.showTimeStamp{
                self.manager.lastMessage  = " \(Date.now) -- " + self.manager.lastMessage
            }
            
            self.manager.AllMessages += "\n\(self.manager.lastMessage)"
        }
       
        
        //        print("Received message from server: \(String(describing: message!))")}
    }
    
//    public func channelReadComplete(context: ChannelHandlerContext) {
//        context.flush()
//    }
    
    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("error: \(error)")
        context.close(promise: nil)
    }
}
