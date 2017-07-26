//
//  OvpnClient.h
//  opendev
//
//  Created by admin on 2017/4/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <client/ovpncli.hpp>

using namespace openvpn;

class OvpnClient : public ClientAPI::OpenVPNClient {

private:

    void *clientDelegate;

public:

    OvpnClient(void *);
#pragma mark Tun builder
    // Callback to construct a new tun builder
    // Should be called first.
    virtual bool tun_builder_new() override;

    // Callback to set address of remote server
    // Never called more than once per tun_builder session.
    virtual bool tun_builder_set_remote_address(const std::string& address, bool ipv6) override;

    // Callback to add network address to VPN interface
    // May be called more than once per tun_builder session
    virtual bool tun_builder_add_address(const std::string& address,
                                         int prefix_length,
                                         const std::string& gateway, // optional
                                         bool ipv6,
                                         bool net30) override;


    // Callback to reroute default gateway to VPN interface.
    // ipv4 is true if the default route to be added should be IPv4.
    // ipv6 is true if the default route to be added should be IPv6.
    // flags are defined in RGWFlags (rgwflags.hpp).
    // Never called more than once per tun_builder session.
    virtual bool tun_builder_reroute_gw(bool ipv4,
                                        bool ipv6,
                                        unsigned int flags) override;

    // Callback to add route to VPN interface
    // May be called more than once per tun_builder session
    // metric is optional and should be ignored if < 0
    virtual bool tun_builder_add_route(const std::string& address,
                                       int prefix_length,
                                       int metric,
                                       bool ipv6) override;

    // Callback to exclude route from VPN interface
    // May be called more than once per tun_builder session
    // metric is optional and should be ignored if < 0
    virtual bool tun_builder_exclude_route(const std::string& address,
                                           int prefix_length,
                                           int metric,
                                           bool ipv6) override;

    // Callback to add DNS server to VPN interface
    // May be called more than once per tun_builder session
    // If reroute_dns is true, all DNS traffic should be routed over the
    // tunnel, while if false, only DNS traffic that matches an added search
    // domain should be routed.
    // Guaranteed to be called after tun_builder_reroute_gw.
    virtual bool tun_builder_add_dns_server(const std::string& address, bool ipv6) override;

    // Callback to add search domain to DNS resolver
    // May be called more than once per tun_builder session
    // See tun_builder_add_dns_server above for description of
    // reroute_dns parameter.
    // Guaranteed to be called after tun_builder_reroute_gw.
    virtual bool tun_builder_add_search_domain(const std::string& domain) override;

    // Callback to set MTU of the VPN interface
    // Never called more than once per tun_builder session.
    virtual bool tun_builder_set_mtu(int mtu) override;

    // Callback to set the session name
    // Never called more than once per tun_builder session.
    virtual bool tun_builder_set_session_name(const std::string& name) override;

    // Callback to add a host which should bypass the proxy
    // May be called more than once per tun_builder session
    virtual bool tun_builder_add_proxy_bypass(const std::string& bypass_host) override;

    // Callback to set the proxy "Auto Config URL"
    // Never called more than once per tun_builder session.
    virtual bool tun_builder_set_proxy_auto_config_url(const std::string& url) override;

    // Callback to set the HTTP proxy
    // Never called more than once per tun_builder session.
    virtual bool tun_builder_set_proxy_http(const std::string& host, int port) override;

    // Callback to set the HTTPS proxy
    // Never called more than once per tun_builder session.
    virtual bool tun_builder_set_proxy_https(const std::string& host, int port) override;

    // Callback to establish the VPN tunnel, returning a file descriptor
    // to the tunnel, which the caller will henceforth own.  Returns -1
    // if the tunnel could not be established.
    // Always called last after tun_builder session has been configured.
    virtual int tun_builder_establish() override;

    // Return true if tun interface may be persisted, i.e. rolled
    // into a new session with properties untouched.  This method
    // is only called after all other tests of persistence
    // allowability succeed, therefore it can veto persistence.
    // If persistence is ultimately enabled,
    // tun_builder_establish_lite() will be called.  Otherwise,
    // tun_builder_establish() will be called.
    virtual bool tun_builder_persist() override;
    
    // Indicates a reconnection with persisted tun state.
    virtual void tun_builder_establish_lite() override;
    
    // Indicates that tunnel is being torn down.
    // If disconnect == true, then the teardown is occurring
    // prior to final disconnect.
    virtual void tun_builder_teardown(bool disconnect) override;

#pragma mark - Client override

    // Callback to "protect" a socket from being routed through the tunnel.
    // Will be called from the thread executing connect().
    virtual bool socket_protect(int socket) override;

    // When a connection is close to timeout, the core will call this
    // method.  If it returns false, the core will disconnect with a
    // CONNECTION_TIMEOUT event.  If true, the core will enter a PAUSE
    // state.
    virtual bool pause_on_connection_timeout() override;

    // External PKI callbacks
    // Will be called from the thread executing connect().
    virtual void external_pki_cert_request(ClientAPI::ExternalPKICertRequest& certreq) override;
    virtual void external_pki_sign_request(ClientAPI::ExternalPKISignRequest& signreq) override;

    // Callback for delivering events during connect() call.
    // Will be called from the thread executing connect().
    virtual void event(const ClientAPI::Event& ev) override;

    // Callback for logging.
    // Will be called from the thread executing connect().
    virtual void log(const ClientAPI::LogInfo& log) override;

};

