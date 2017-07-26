//
//  Builder+Settings.m
//  ovpn-wrap
//
//  Created by admin on 7/25/17.
//  Copyright © 2017 Yt-L. All rights reserved.
//

#import <sys/socket.h>
#import <sys/un.h>
#import <sys/stat.h>
#import <sys/ioctl.h>
#import <arpa/inet.h>

#import "Ovpn+Settings.h"
#import "OvpnAPI_Builder.h"

@implementation OvpnAPI (Settings)

static void callBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    OvpnAPI *builder = (__bridge OvpnAPI *)info;
    switch (type) {
        case kCFSocketDataCallBack:
            [builder writeDatas:(__bridge NSData *)data];
            break;
        default:
            break;
    }
}

#pragma mark - OvpnClient
// tun builder new, create a pire of socket for read/write
// true socket create succeed, else false
- (BOOL)tunBuilder {

    int sockets[2];
    if (socketpair(PF_LOCAL, SOCK_DGRAM, IPPROTO_IP, sockets) != -1) {
        int buffer = 65536;
        for (int i = 0; i < 2; i++) {
            int setRead  = setsockopt(sockets[i], SOL_SOCKET, SO_RCVBUF, &(buffer), sizeof(buffer));
            int setWrite = setsockopt(sockets[i], SOL_SOCKET, SO_SNDBUF, &(buffer), sizeof(buffer));
            if (setRead == -1 || setWrite == -1) {
                return NO;
            }
        }

        CFSocketContext context = {0, (__bridge void *)self, NULL, NULL, NULL };
        self.readSocket = CFSocketCreateWithNative(kCFAllocatorDefault, sockets[0], kCFSocketDataCallBack, &callBack, &context);
        self.writeSocket = CFSocketCreateWithNative(kCFAllocatorDefault, sockets[1], kCFSocketNoCallBack, NULL, NULL);
        if (self.readSocket && self.writeSocket) {
            CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, self.readSocket, 0);
            CFRunLoopAddSource(CFRunLoopGetMain(), source, kCFRunLoopDefaultMode);
            CFRelease(source);
            return YES;
        }
    }
    return NO;
}

// parse config profile, obtain remote address and bool value indicate
// it is IPv4 or IPv6
- (BOOL)addRemoteAddress:(NSString *)address isIPv6:(BOOL)isIPv6 {
    if (!address) {
        return NO;
    }
    self.profile.remoteAddress = address;
    self.profile.isIPv6        = isIPv6;
    return YES;
}

// obtain tun settings address with ipv4Setting or ipv6Setting
- (BOOL)tunSettingsAddress:(NSString *)address prefix:(NSInteger)prefix isIPv6:(BOOL)isIPv6 {
    if (!(address && prefix)) {
        return NO;
    }
    if (isIPv6) {
        [self.profile.ipv6Address addObject:[[IPAddress alloc] initWithName:address andPrefix:prefix]];
    } else {
        [self.profile.ipv4Address addObject:[[IPAddress alloc] initWithName:address andPrefix:prefix]];
    }
    return YES;
}

// set route default for tun device
- (BOOL)routeDefault:(BOOL)defaultIPv4 shouldIPv6:(BOOL)defaultIPv6 {
    self.profile.isDefaultIPv4Route = defaultIPv4;
    self.profile.isDefaultIPv6Route = defaultIPv6;
    return YES;
}

// add include route for tun
// traffic through the tun device if match the route
- (BOOL)addIncludeRoute:(NSString *)address prefix:(NSInteger)prefix isIPv6:(BOOL)isIPv6 {
    if (!(address && prefix)) {
        return NO;
    }
    if (isIPv6) {
        [self.profile.ipv6IncludeRoutes addObject:[[IPAddress alloc] initWithName:address andPrefix:prefix]];
    } else {
        [self.profile.ipv4IncludeRoutes addObject:[[IPAddress alloc] initWithName:address andPrefix:prefix]];
    }
    return YES;
}

// add exclude route for tun
// traffic through physic ethernet if match the route
- (BOOL)addExcludeRoute:(NSString *)address prefix:(NSInteger)prefix isIPv6:(BOOL)isIPv6 {
    if (!(address && prefix)) {
        return NO;
    }
    if (isIPv6) {
        [self.profile.ipv6ExcludeRoutes addObject:[[IPAddress alloc] initWithName:address andPrefix:prefix]];
    } else {
        [self.profile.ipv4ExcludeRoutes addObject:[[IPAddress alloc] initWithName:address andPrefix:prefix]];
    }
    return YES;
}

// add dns server for tun
// DNS server
- (BOOL)addDNSServer:(NSString *)server isIPv6:(BOOL)isIPv6 {
    if (!server) {
        return NO;
    }
    [self.profile.dnsServers addObject:server];
    return YES;
}

// add dns domain for tun
// DNS domain
- (BOOL)addDNSSearchDomain:(NSString *)domain {
    if (!domain) {
        return NO;
    }
    [self.profile.dnsDomains addObject:domain];
    return YES;
}

// add mtu for tun
// mtu max trans unit
- (BOOL)addMTU:(NSInteger)mtu {
    self.profile.mtu = mtu;
    return YES;
}

// establish tun
// return the socket description
- (NSInteger)tunEstablish {
    if (!(self.readSocket && self.writeSocket)) {
        return -1;
    }
    if (self.delegate) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [self.delegate tunnelSetting:[self settings] withCompletionHandler:^(BOOL isSucceed) {
            if (isSucceed) {
                dispatch_semaphore_signal(sema);
            }
        }];
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 10);
        if (dispatch_semaphore_wait(sema, time) == 0) {
            [self readDatas];
            return CFSocketGetNative(self.writeSocket);
        }
    }
    return -1;
}

// Return true if tun interface may be persisted, i.e. rolled
// into a new session with properties untouched.  This method
// is only called after all other tests of persistence
// allowability succeed, therefore it can veto persistence.
// If persistence is ultimately enabled,
- (BOOL)tunPersist {
    return YES;
}

// Indicates a reconnection with persisted tun state.
- (void)tunEstablisthLite {}

// Indicates that tunnel is being torn down.
// If disconnect == true, then the teardown is occurring
// prior to final disconnect.
- (void)tunTeardown {}


#pragma mark - Not common used
// set session name for tun
// a name flag for session
- (BOOL)setSessionName:(NSString *)name {
    return YES;
}

// add proxy config by given host
- (BOOL)addProxyBy:(NSString *)host {
    if (host) {
        [self.profile.passProxyHost addObject:host];
    }
    return YES;
}

// set proxy auto config url
- (BOOL)setProxyWithURL:(NSString *)urlString {
    if (urlString) {
        self.profile.autoConfigProxyURL = urlString;
    }
    return YES;
}

// set http proxy
- (BOOL)setHttpProxy:(NSString *)host port:(NSInteger)port {
    if (host) {
        self.profile.httpProxy = [[IPAddress alloc] initWithName:host andPrefix:port];
    }
    return YES;
}

// set https proxy
- (BOOL)setHttpsProxy:(NSString *)host port:(NSInteger)port {
    if (host) {
        self.profile.httpsProxy = [[IPAddress alloc] initWithName:host andPrefix:port];
    }
    return YES;
}

// handle connect log information
- (void)handleLog:(NSString * __nullable)info {
    if (info) {
        [self.delegate handleLog:info];
    }
}

// handle connect status
- (void)handleEvent:(NSString * __nullable)name info:(NSString *__nullable)info {
    if ([name isEqualToString:@"DISCONNECTED"]) {
        [self.delegate handleEvent:disconnected withInfo:info];
    } else if ([name isEqualToString:@"CONNECTED"]) {
        [self.delegate handleEvent:connected withInfo:info];
    } else if ([name isEqualToString:@"INACTIVE_TIMEOUT"]) {
        [self.delegate handleEvent:connectTimeout withInfo:info];
    } else {
        [self.delegate handleEvent:others withInfo:info];
    }
}

@end
