//
//  TCPInterReceiveHandler.swift
//  EtherDebug
//
//  Created by Aaron Ge on 2023/5/10.
//

import Foundation
import NIO

class TCPADCReceiveHandler: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer

    private let manager: NetworkManager

    init(manager: NetworkManager) {
        self.manager = manager
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let byteBuffer = self.unwrapInboundIn(data)
        context.write(data, promise: nil)
        
        let value = byteBuffer.getInteger(at: byteBuffer.readerIndex) ?? 0
        let floatValue = Float(value) * 3.3 / 4096.0
        
        var hexValue = ""
        if self.manager.showHexFormat{
            hexValue = String(format: "%04X", floatValue)
        
        }
        else {
            hexValue = "\(floatValue)"
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

    func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("error: \(error)")
        context.close(promise: nil)
    }
}
