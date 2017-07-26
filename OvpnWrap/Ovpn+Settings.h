//
//  Builder+Settings.h
//  ovpn-wrap
//
//  Created by admin on 7/25/17.
//  Copyright © 2017 Yt-L. All rights reserved.
//

#import "OvpnAPI.h"

@interface OvpnAPI (Settings)

// tun builder new, create a pire of socket for read/write
// true socket create succeed, else false
- (BOOL)tunBuilder;

// parse config profile, obtain remote address and bool value indicate
// it is IPv4 or IPv6
- (BOOL)addRemoteAddress:(NSString *)address isIPv6:(BOOL)isIPv6;

// obtain tun settings address with ipv4Setting or ipv6Setting
- (BOOL)tunSettingsAddress:(NSString *)address prefix:(NSInteger)prefix isIPv6:(BOOL)isIPv6;

// set route default for tun device
- (BOOL)routeDefault:(BOOL)defaultIPv4 shouldIPv6:(BOOL)defaultIPv6;

// add include route for tun
// traffic through the tun device if match the route
- (BOOL)addIncludeRoute:(NSString *)address prefix:(NSInteger)prefix isIPv6:(BOOL)isIPv6;

// add exclude route for tun
// traffic through physic ethernet if match the route
- (BOOL)addExcludeRoute:(NSString *)address prefix:(NSInteger)prefix isIPv6:(BOOL)isIPv6;

// add dns server for tun
// DNS server
- (BOOL)addDNSServer:(NSString *)server isIPv6:(BOOL)isIPv6;

// add dns domain for tun
// DNS domain
- (BOOL)addDNSSearchDomain:(NSString *)domain;

// add mtu for tun
// mtu max trans unit
- (BOOL)addMTU:(NSInteger)mtu;

// establish tun
// return the socket description
- (NSInteger)tunEstablish;

// Return true if tun interface may be persisted, i.e. rolled
// into a new session with properties untouched.  This method
// is only called after all other tests of persistence
// allowability succeed, therefore it can veto persistence.
// If persistence is ultimately enabled,
- (BOOL)tunPersist;

// Indicates a reconnection with persisted tun state.
- (void)tunEstablisthLite;

// Indicates that tunnel is being torn down.
// If disconnect == true, then the teardown is occurring
// prior to final disconnect.
- (void)tunTeardown;

#pragma mark - Not common used
// set session name for tun
// a name flag for session
- (BOOL)setSessionName:(NSString *)name;

// add proxy config by given host
- (BOOL)addProxyBy:(NSString *)host;

// set proxy auto config url
- (BOOL)setProxyWithURL:(NSString *)urlString;

// set http proxy
- (BOOL)setHttpProxy:(NSString *)host port:(NSInteger)port;

// set https proxy
- (BOOL)setHttpsProxy:(NSString *)host port:(NSInteger)port;

#pragma mark - Event & Log
// handle connect log information
- (void)handleLog:(NSString *)info;

// handle connect status
- (void)handleEvent:(NSString *)name info:(NSString *)info;

@end
