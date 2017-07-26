//
//  Profile.h
//  ovpn-wrap
//
//  Created by admin on 7/25/17.
//  Copyright © 2017 Yt-L. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPAddress : NSObject

// @statement the route's address
@property (nonatomic, strong) NSString *name;

// @statement the route's address prefix
@property (nonatomic, assign) NSInteger prefix;

- (instancetype)initWithName:(NSString *)name andPrefix:(NSInteger)prefix;

@end




@interface Profile : NSObject

// @statement remote address and type
@property (nonatomic, strong) NSString *remoteAddress;
@property (nonatomic, assign) BOOL isIPv6;

// @statement ip address settings
@property (nonatomic, strong) NSMutableArray<IPAddress *> *ipv4Address;
@property (nonatomic, strong) NSMutableArray<IPAddress *> *ipv6Address;

// @statement default route
@property (nonatomic, assign) BOOL isDefaultIPv4Route;
@property (nonatomic, assign) BOOL isDefaultIPv6Route;

// @statement include route and exclude route for IPv4/IPv6
@property (nonatomic, strong) NSMutableArray<IPAddress *> *ipv4IncludeRoutes;
@property (nonatomic, strong) NSMutableArray<IPAddress *> *ipv4ExcludeRoutes;
@property (nonatomic, strong) NSMutableArray<IPAddress *> *ipv6IncludeRoutes;
@property (nonatomic, strong) NSMutableArray<IPAddress *> *ipv6ExcludeRoutes;

// @statement dns server
@property (nonatomic, strong) NSMutableArray *dnsServers;
@property (nonatomic, strong) NSMutableArray *dnsDomains;

// @statement MTU
@property (nonatomic, assign) NSInteger mtu;

// @statement proxy
@property (nonatomic, strong) NSMutableArray *passProxyHost;
@property (nonatomic, strong) NSString *autoConfigProxyURL;
@property (nonatomic, strong) IPAddress *httpProxy;
@property (nonatomic, strong) IPAddress *httpsProxy;

- (void)deinit;

@end
