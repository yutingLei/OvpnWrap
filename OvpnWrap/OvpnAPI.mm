//
//  OvpnAPI.m
//  ovpn-wrap
//
//  Created by admin on 7/25/17.
//  Copyright © 2017 Yt-L. All rights reserved.
//

#import "OvpnAPI.h"
#import "OvpnClient.h"
#import "OvpnAPI_Builder.h"

@interface OvpnAPI ()

// object with client
@property OvpnClient *client;

@end

@implementation OvpnAPI
@synthesize profile = _profile;

- (instancetype)init {
    if (self = [super init]) {
        self.client = new OvpnClient((__bridge void *)self);
    }
    return self;
}

// @function init with delegate
- (instancetype)initWithDelegate:(id<OvpnDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        self.client = new OvpnClient((__bridge void *)self);
    }
    return self;
}

- (Profile *)profile {
    if (!_profile) {
        _profile = [[Profile alloc] init];
    }
    return _profile;
}

- (void)dealloc {
    _delegate = nil;
    delete self.client;
}

// @function evalute profile with error
// if failure, error returns
- (BOOL)evaluateProfile:(NSData * __nonnull)profile {
    ClientAPI::Config config;
    config.content = std::string((const char *)profile.bytes);
    config.connTimeout = 30.0;

    ClientAPI::EvalConfig evaluate = self.client->eval_config(config);
    if (!evaluate.error) {
        ClientAPI::ProvideCreds creds;
        creds.username = "";
        creds.password = "";
        ClientAPI::Status credsStatus = self.client->provide_creds(creds);
        if (!credsStatus.error) {
            return YES;
        }
    }
    [self.delegate handleEvent:error withInfo:@"profile eval error!"];
    return NO;
}

// @function connect OpenVPN
// and callback handleLog: excuting connect
// shoule invoke it in new thread
- (void)connect {

    dispatch_queue_t connectQueue = dispatch_queue_create("guncklood.ovpn.connection", NULL);
    dispatch_async(connectQueue, ^{
        OvpnClient::init_process();
        try {
            ClientAPI::Status status = self.client->connect();
            if (status.error) {
                NSString *description = [NSString stringWithFormat:@"Client connect error: \(%s)", status.message.c_str()];
                [self.delegate handleEvent:error withInfo:description];
            }
        } catch (const std::exception& e) {
            NSString *description = [NSString stringWithFormat:@"Client connect error: \(%s)", e.what()];
            [self.delegate handleEvent:error withInfo:description];
        }
        [self deinit];
        [self.profile deinit];
        OvpnClient::uninit_process();
    });
}

// @function disconnect OpenVPN
- (void)disconnect {
    self.client->stop();
}

// @function the tun device's network settings
- (NEPacketTunnelNetworkSettings *)settings {
    NEPacketTunnelNetworkSettings *settings = [[NEPacketTunnelNetworkSettings alloc] initWithTunnelRemoteAddress:self.profile.remoteAddress];

    //! IPv4 settings
    if (self.profile.ipv4Address.count != 0) {
        NSMutableArray *addresses = [NSMutableArray array];
        NSMutableArray *subnetMasks = [NSMutableArray array];
        for (IPAddress *ip in self.profile.ipv4Address) {
            [addresses addObject:ip.name];
            [addresses addObject:[self convertBitToSubnetMask:ip.prefix]];
        }
        NEIPv4Settings *ipv4Setting = [[NEIPv4Settings alloc] initWithAddresses:addresses subnetMasks:subnetMasks];
        NSMutableArray *ipv4IncludeRoutes = [NSMutableArray array];
        NSMutableArray *ipv4ExcludeRoutes = [NSMutableArray array];
        for (NSInteger i = 0; i < MAX(self.profile.ipv4IncludeRoutes.count, self.profile.ipv4ExcludeRoutes.count); i++) {
            if (self.profile.ipv4IncludeRoutes.count > i) {
                IPAddress *ip = self.profile.ipv4IncludeRoutes[i];
                NEIPv4Route *ipv4Route = [[NEIPv4Route alloc] initWithDestinationAddress:ip.name subnetMask:[self convertBitToSubnetMask:ip.prefix]];
                [ipv4IncludeRoutes addObject:ipv4Route];
            }
            if (self.profile.ipv4ExcludeRoutes.count > i) {
                IPAddress *ip = self.profile.ipv4ExcludeRoutes[i];
                NEIPv4Route *ipv4Route = [[NEIPv4Route alloc] initWithDestinationAddress:ip.name subnetMask:[self convertBitToSubnetMask:ip.prefix]];
                [ipv4ExcludeRoutes addObject:ipv4Route];
            }
        }
        [ipv4IncludeRoutes addObject:[NEIPv4Route defaultRoute]];
        ipv4Setting.includedRoutes = ipv4IncludeRoutes;
        ipv4Setting.excludedRoutes = ipv4ExcludeRoutes;
        settings.IPv4Settings = ipv4Setting;
    }

    //! IPv6 settings
    /*
    [addresses removeAllObjects];
    [subnetMasks removeAllObjects];
    for (IPAddress *ip in self.profile.ipv6Address) {
        [addresses addObject:ip.name];
        [subnetMasks addObject:@(ip.prefix)];
    }
    if (addresses.count != 0 && subnetMasks.count != 0) {
        NEIPv6Settings *ipv6Setting = [[NEIPv6Settings alloc] initWithAddresses:addresses networkPrefixLengths:subnetMasks];
        NSMutableArray *ipv6IncludeRoutes = [NSMutableArray array];
        NSMutableArray *ipv6ExcludeRoutes = [NSMutableArray array];
        for (NSInteger i = 0; i < MAX(self.profile.ipv4IncludeRoutes.count, self.profile.ipv4ExcludeRoutes.count); i++) {
            if (self.profile.ipv4IncludeRoutes.count > i) {
                IPAddress *ip = self.profile.ipv6IncludeRoutes[i];
                NEIPv6Route *ipv6Route = [[NEIPv6Route alloc] initWithDestinationAddress:ip.name networkPrefixLength:@(ip.prefix)];
                [ipv6IncludeRoutes addObject:ipv6Route];
            }
            if (self.profile.ipv4ExcludeRoutes.count > i) {
                IPAddress *ip = self.profile.ipv6ExcludeRoutes[i];
                NEIPv6Route *ipv6Route = [[NEIPv6Route alloc] initWithDestinationAddress:ip.name networkPrefixLength:@(ip.prefix)];
                [ipv6ExcludeRoutes addObject:ipv6Route];
            }
        }
        [ipv6IncludeRoutes addObject:[NEIPv6Route defaultRoute]];
        ipv6Setting.includedRoutes = ipv6IncludeRoutes;
        ipv6Setting.excludedRoutes = ipv6ExcludeRoutes;
        settings.IPv6Settings = ipv6Setting;
    }*/

    //! DNS setting
    if (self.profile.dnsServers.count != 0) {
        NEDNSSettings *dnsSetting = [[NEDNSSettings alloc] initWithServers:self.profile.dnsServers];
        dnsSetting.searchDomains = self.profile.dnsDomains;
        settings.DNSSettings = dnsSetting;
    }

    //! MTU
    if (self.profile.mtu != 0) {
        settings.MTU = @(self.profile.mtu);
    }
    return settings;
}

// @function read data from tun device
// if VPN connected, read data in a loop until disconnected
// OpenVPN contain prefix protocol, and using uint32_t, so convert protocol to big byte order
// then send to vpn
- (void)readDatas {
    [self.delegate readPacketsWithcompletionHandler:^(NSArray<NSData *> *packets, NSArray<NSNumber *> *protocols) {
        for (NSInteger i = 0; i < packets.count; i++) {
            NSNumber *protocol = protocols[i];
            uint32_t prefix = CFSwapInt32HostToBig((uint32_t)[protocol unsignedIntegerValue]);
            NSMutableData *packet = [NSMutableData new];
            [packet appendBytes:&prefix length:sizeof(prefix)];
            [packet appendData:packets[i]];
            CFSocketSendData(self.readSocket, NULL, (CFDataRef)packet, 0.05);
        }
        [self readDatas];
    }];
}

// @function vpn write data to tun device
// @param packet    data type. OpenVPN using prefix protocol
- (void)writeDatas:(NSData *)packet {
    // Get network protocol from data
    NSUInteger prefixSize = sizeof(uint32_t);

    if (packet.length < prefixSize) {
        NSLog(@"Incorrect OpenVPN packet size");
        return;
    }

    uint32_t protocol = UINT32_MAX;
    [packet getBytes:&protocol length:prefixSize];

    protocol = CFSwapInt32BigToHost(protocol);
    NSData *data = [packet subdataWithRange:NSMakeRange(prefixSize, packet.length - prefixSize)];
    [self.delegate writePackets:@[data] withProtocols:@[@(protocol)]];
}

// @function deinit
- (void)deinit {
    if (self.readSocket) {
        CFSocketInvalidate(self.readSocket);
        CFRelease(self.readSocket);
    }
    if (self.writeSocket) {
        CFSocketInvalidate(self.writeSocket);
        CFRelease(self.writeSocket);
    }
}

#pragma mark - Support
// @function convert the bit to subnet mask
- (NSString *)convertBitToSubnetMask:(NSInteger)bitvalue {
    uint32_t bitmask = UINT_MAX << (sizeof(uint32_t) * 8 - bitvalue);

    uint8_t first = (bitmask >> 24) & 0xFF;
    uint8_t second = (bitmask >> 16) & 0xFF;
    uint8_t third = (bitmask >> 8) & 0xFF;
    uint8_t fourth = bitmask & 0xFF;

    return [NSString stringWithFormat:@"%hhu.%hhu.%hhu.%hhu", first, second, third, fourth];
}

@end
