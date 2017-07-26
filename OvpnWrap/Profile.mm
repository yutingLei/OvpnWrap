//
//  Profile.m
//  ovpn-wrap
//
//  Created by admin on 7/25/17.
//  Copyright © 2017 Yt-L. All rights reserved.
//

#import "Profile.h"

@implementation IPAddress

- (instancetype)initWithName:(NSString *)name andPrefix:(NSInteger)prefix {
    if (self = [super init]) {
        self.name = name;
        self.prefix = prefix;
    }
    return self;
}

@end


@implementation Profile

#pragma mark - Address Getter
- (NSMutableArray *)ipv4Address {
    if (!_ipv4Address) {
        _ipv4Address = [NSMutableArray array];
    }
    return _ipv4Address;
}

- (NSMutableArray *)ipv6Address {
    if (!_ipv6Address) {
        _ipv6Address = [NSMutableArray array];
    }
    return _ipv6Address;
}

#pragma mark - Routes Getter

- (NSMutableArray *)ipv4IncludeRoutes {
    if (!_ipv4IncludeRoutes) {
        _ipv4IncludeRoutes = [NSMutableArray array];
    }
    return _ipv4IncludeRoutes;
}

- (NSMutableArray *)ipv4ExcludeRoutes {
    if (!_ipv4ExcludeRoutes) {
        _ipv4ExcludeRoutes = [NSMutableArray array];
    }
    return _ipv4ExcludeRoutes;
}

- (NSMutableArray *)ipv6IncludeRoutes {
    if (!_ipv6IncludeRoutes) {
        _ipv6IncludeRoutes = [NSMutableArray array];
    }
    return _ipv6IncludeRoutes;
}
- (NSMutableArray *)ipv6ExcludeRoutes {
    if (!_ipv6ExcludeRoutes) {
        _ipv6ExcludeRoutes = [NSMutableArray array];
    }
    return _ipv6ExcludeRoutes;
}

#pragma mark - DNS Servers
- (NSMutableArray *)dnsServers {
    if (!_dnsServers) {
        _dnsServers = [NSMutableArray array];
    }
    return _dnsServers;
}

- (NSMutableArray *)dnsDomains {
    if (!_dnsDomains) {
        _dnsDomains = [NSMutableArray array];
    }
    return _dnsDomains;
}

#pragma mark proxy
- (NSMutableArray *)passProxyHost {
    if (!_passProxyHost) {
        _passProxyHost = [NSMutableArray array];
    }
    return _passProxyHost;
}

#pragma mark deinit
- (void)deinit {
    if (_ipv4Address) {
        [_ipv4Address removeAllObjects];
    }
    if (_ipv6Address) {
        [_ipv6Address removeAllObjects];
    }
    if (_ipv4IncludeRoutes) {
        [_ipv4IncludeRoutes removeAllObjects];
    }
    if (_ipv4ExcludeRoutes) {
        [_ipv4ExcludeRoutes removeAllObjects];
    }
    if (_ipv6IncludeRoutes) {
        [_ipv6IncludeRoutes removeAllObjects];
    }
    if (_ipv6ExcludeRoutes) {
        [_ipv6ExcludeRoutes removeAllObjects];
    }
    if (_dnsServers) {
        [_dnsServers removeAllObjects];
    }
    if (_dnsDomains) {
        [_dnsDomains removeAllObjects];
    }
    if (_passProxyHost) {
        [_passProxyHost removeAllObjects];
    }
    _isDefaultIPv4Route = false;
    _isDefaultIPv6Route = false;

}

@end
