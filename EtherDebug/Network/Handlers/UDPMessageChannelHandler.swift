//
//  UDPChannelHandler.swift
//  TRIAL
//
//  Created by Aaron Ge on 2023/5/6.
//

import Foundation
import NIOCore

class UDPMessageChannelHandler: ChannelInboundHandler {
    typealias InboundIn =  AddressedEnvelope<ByteBuffer>

    private let manager: NetworkManager

    init(manager: NetworkManager) {
        self.manager = manager
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let envelope = self.unwrapInboundIn(data)
        let byteBuffer = envelope.data
        if let message = byteBuffer.getString(at:0, length: byteBuffer.readableBytes){
            DispatchQueue.main.async {
                self.manager.lastMessage = message
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
        }
    }
    
}


