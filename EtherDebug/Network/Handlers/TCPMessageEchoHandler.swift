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

        let value = byteBuffer.getString(at: byteBuffer.readerIndex, length: byteBuffer.capacity) ?? ""
        
        var hexValue = ""
        if self.manager.showHexFormat{
            hexValue = value.unicodeScalars.reduce("", {
                $0 + String(format: "%04X", $1.value)
            })
        }
        else {
            hexValue  = value
        }
        
        DispatchQueue.main.async {
            
           
            
            if self.manager.showTimeStamp{
                self.manager.lastMessage  = " \(Date.now) -- " + hexValue
            }
            else{
                self.manager.lastMessage  = hexValue
            }
            
            self.manager.AllMessages += "\n\(self.manager.lastMessage)"
        }
    }
    
    public func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }
    
    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("error: \(error)")
        context.close(promise: nil)
    }
}
