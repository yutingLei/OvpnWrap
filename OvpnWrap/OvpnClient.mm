//
//  OvpnClient.m
//  opendev
//
//  Created by admin on 2017/4/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "OvpnClient.h"
#import "Ovpn+Settings.h"

#import <Foundation/Foundation.h>

OvpnClient::OvpnClient(void *delegate) : ClientAPI::OpenVPNClient() {
    this->clientDelegate = delegate;
}

#pragma mark Custom implementation
// Callback to construct a new tun builder
// Should be called first.
bool OvpnClient::tun_builder_new() {
    return [(__bridge OvpnAPI *)clientDelegate tunBuilder];
}

// Callback to set address of remote server
// Never called more than once per tun_builder session.
bool OvpnClient::tun_builder_set_remote_address(const std::string& address, bool ipv6) {
    NSString *remoteAddress = [NSString stringWithUTF8String:address.c_str()];
    return [(__bridge OvpnAPI *)clientDelegate addRemoteAddress:remoteAddress isIPv6:ipv6];
}

// Callback to add network address to VPN interface
// May be called more than once per tun_builder session
bool OvpnClient::tun_builder_add_address(const std::string& address,
                                         int prefix_length,
                                         const std::string& gateway, // optional
                                         bool ipv6,
                                         bool net30) {
    NSString *setAddress = [NSString stringWithUTF8String:address.c_str()];
    NSInteger prefix     = prefix_length;
    return [(__bridge OvpnAPI *)clientDelegate tunSettingsAddress:setAddress prefix:prefix isIPv6:ipv6];
}

// Callback to reroute default gateway to VPN interface.
// ipv4 is true if the default route to be added should be IPv4.
// ipv6 is true if the default route to be added should be IPv6.
// flags are defined in RGWFlags (rgwflags.hpp).
// Never called more than once per tun_builder session.
bool OvpnClient::tun_builder_reroute_gw(bool ipv4, bool ipv6, unsigned int flags) {
    return [(__bridge OvpnAPI *)clientDelegate routeDefault:ipv4 shouldIPv6:ipv6];
}

// Callback to add route to VPN interface
// May be called more than once per tun_builder session
// metric is optional and should be ignored if < 0
bool OvpnClient:: tun_builder_add_route(const std::string& address,
                                        int prefix_length,
                                        int metric,
                                        bool ipv6) {
    NSString *routeAddress = [NSString stringWithUTF8String:address.c_str()];
    NSInteger prefix       = prefix_length;
    return [(__bridge OvpnAPI *)clientDelegate addIncludeRoute:routeAddress prefix:prefix isIPv6:ipv6];
}

// Callback to exclude route from VPN interface
// May be called more than once per tun_builder session
// metric is optional and should be ignored if < 0
bool OvpnClient::tun_builder_exclude_route(const std::string& address,
                                            int prefix_length,
                                            int metric,
                                            bool ipv6) {
    NSString *routeAddress = [NSString stringWithUTF8String:address.c_str()];
    NSInteger prefix       = prefix_length;
    return [(__bridge OvpnAPI *)clientDelegate addExcludeRoute:routeAddress prefix:prefix isIPv6:ipv6];
}

// Callback to add DNS server to VPN interface
// May be called more than once per tun_builder session
// If reroute_dns is true, all DNS traffic should be routed over the
// tunnel, while if false, only DNS traffic that matches an added search
// domain should be routed.
// Guaranteed to be called after tun_builder_reroute_gw.
bool OvpnClient::tun_builder_add_dns_server(const std::string& address, bool ipv6) {
    NSString *dnsServer = [NSString stringWithUTF8String:address.c_str()];
    return [(__bridge OvpnAPI *)clientDelegate addDNSServer:dnsServer isIPv6:ipv6];
}

// Callback to add search domain to DNS resolver
// May be called more than once per tun_builder session
// See tun_builder_add_dns_server above for description of
// reroute_dns parameter.
// Guaranteed to be called after tun_builder_reroute_gw.
bool OvpnClient::tun_builder_add_search_domain(const std::string& domain) {
    NSString *dnsDomain = [NSString stringWithUTF8String:domain.c_str()];
    return [(__bridge OvpnAPI *)clientDelegate addDNSSearchDomain:dnsDomain];
}

// Callback to set MTU of the VPN interface
// Never called more than once per tun_builder session.
bool OvpnClient::tun_builder_set_mtu(int mtu) {
    return [(__bridge OvpnAPI *)clientDelegate addMTU:mtu];
}

// Callback to set the session name
// Never called more than once per tun_builder session.
bool OvpnClient::tun_builder_set_session_name(const std::string& name) {
    return true;
}

// Callback to add a host which should bypass the proxy
// May be called more than once per tun_builder session
bool OvpnClient::tun_builder_add_proxy_bypass(const std::string& bypass_host) {
    NSString *proxyHost = [NSString stringWithUTF8String:bypass_host.c_str()];
    return [(__bridge OvpnAPI *)clientDelegate addProxyBy:proxyHost];
}

// Callback to set the proxy "Auto Config URL"
// Never called more than once per tun_builder session.
bool OvpnClient::tun_builder_set_proxy_auto_config_url(const std::string& url) {
    NSString *proxyURL = [NSString stringWithUTF8String:url.c_str()];
    return [(__bridge OvpnAPI *)clientDelegate setProxyWithURL:proxyURL];
}

// Callback to set the HTTP proxy
// Never called more than once per tun_builder session.
bool OvpnClient::tun_builder_set_proxy_http(const std::string& host, int port) {
    NSString *proxyHost = [NSString stringWithUTF8String:host.c_str()];
    return [(__bridge OvpnAPI *)clientDelegate setHttpProxy:proxyHost port:port];
}

// Callback to set the HTTPS proxy
// Never called more than once per tun_builder session.
bool OvpnClient::tun_builder_set_proxy_https(const std::string& host, int port) {
    NSString *proxyHost = [NSString stringWithUTF8String:host.c_str()];
    return [(__bridge OvpnAPI *)clientDelegate setHttpsProxy:proxyHost port:port];
}

// Callback to establish the VPN tunnel, returning a file descriptor
// to the tunnel, which the caller will henceforth own.  Returns -1
// if the tunnel could not be established.
// Always called last after tun_builder session has been configured.
int OvpnClient::tun_builder_establish() {
    return [(__bridge OvpnAPI *)clientDelegate tunEstablish];
}

// Return true if tun interface may be persisted, i.e. rolled
// into a new session with properties untouched.  This method
// is only called after all other tests of persistence
// allowability succeed, therefore it can veto persistence.
// If persistence is ultimately enabled,
// tun_builder_establish_lite() will be called.  Otherwise,
// tun_builder_establish() will be called.
bool OvpnClient::tun_builder_persist() {
    return [(__bridge OvpnAPI *)clientDelegate tunPersist];
}

// Indicates a reconnection with persisted tun state.
void OvpnClient::tun_builder_establish_lite() {
    [(__bridge OvpnAPI *)clientDelegate tunEstablisthLite];
}

// Indicates that tunnel is being torn down.
// If disconnect == true, then the teardown is occurring
// prior to final disconnect.
void OvpnClient::tun_builder_teardown(bool disconnect) {
    [(__bridge OvpnAPI *)clientDelegate tunTeardown];
}

#pragma mark - Client override

// Callback to "protect" a socket from being routed through the tunnel.
// Will be called from the thread executing connect().
bool OvpnClient::socket_protect(int socket) {
    return true;
}

// When a connection is close to timeout, the core will call this
// method.  If it returns false, the core will disconnect with a
// CONNECTION_TIMEOUT event.  If true, the core will enter a PAUSE
// state.
bool OvpnClient::pause_on_connection_timeout() {
    return false;
}

// External PKI callbacks
// Will be called from the thread executing connect().
void OvpnClient::external_pki_cert_request(ClientAPI::ExternalPKICertRequest& certreq) {}
void OvpnClient::external_pki_sign_request(ClientAPI::ExternalPKISignRequest& signreq) {}

// Callback for delivering events during connect() call.
// Will be called from the thread executing connect().
void OvpnClient::event(const ClientAPI::Event& ev) {
    NSString *name = [NSString stringWithUTF8String:ev.name.c_str()];
    NSString *info = [NSString stringWithUTF8String:ev.info.c_str()];
    [(__bridge OvpnAPI *)clientDelegate handleEvent:name info:info];
}

// Callback for logging.
// Will be called from the thread executing connect().
void OvpnClient::log(const ClientAPI::LogInfo& log) {
    NSString *logInfo = [NSString stringWithUTF8String:log.text.c_str()];
    [(__bridge OvpnAPI *)clientDelegate handleLog:logInfo];
}
