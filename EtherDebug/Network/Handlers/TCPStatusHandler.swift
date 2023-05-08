//
// Created by Aaron Ge on 2023/4/25.
//

import NIO


class TCPStatusHandler : ChannelInboundHandler {
    public typealias InboundIn = ByteBuffer

    func channelActive(context: ChannelHandlerContext) {
        print("TCP channel is active")
    }

    func channelInactive(context: ChannelHandlerContext) {
        print("TCP channel is inactive")
    }

  
}
