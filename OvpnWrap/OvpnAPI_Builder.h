//
//  OvpnAPI_Builder.h
//  ovpn-wrap
//
//  Created by admin on 7/25/17.
//  Copyright © 2017 Yt-L. All rights reserved.
//

#import "OvpnAPI.h"
#import "Profile.h"

@interface OvpnAPI ()

// @statement the tun config
@property (nonatomic, strong, readonly) Profile *profile;

// @statement socket for openvpn
@property CFSocketRef readSocket;
@property CFSocketRef writeSocket;

// @function the tun network settings
- (NEPacketTunnelNetworkSettings *)settings;

// @function read data from tun device
- (void)readDatas;

// @statement write data to tun
- (void)writeDatas:(NSData *)packet;

// @function deinit socket
- (void)deinit;

@end
