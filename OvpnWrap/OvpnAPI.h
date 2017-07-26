//
//  OvpnAPI.h
//  ovpn-wrap
//
//  Created by admin on 7/25/17.
//  Copyright © 2017 Yt-L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NetworkExtension/NetworkExtension.h>

typedef enum : NSUInteger {
    connected,
    disconnected,
    connectTimeout,
    others,
    error,
} OvpnState;

@protocol OvpnDelegate <NSObject>

// @function log info
- (void)handleLog:(NSString * __nonnull)log;

// @function event name and info
- (void)handleEvent:(OvpnState)state withInfo:(NSString * __nullable)info;

// @function tun device settings options
// completionHandler responseObj is BOOL value. indicate custom implementation following read/write protocols
- (void)tunnelSetting:(NEPacketTunnelNetworkSettings * __nonnull)settings withCompletionHandler:(void(^__nonnull)(BOOL isSucceed))completionHandler;
- (void)readPacketsWithcompletionHandler:(void (^ __nonnull)(NSArray<NSData *> * __nonnull packets, NSArray<NSNumber *> * __nonnull protocols))completionHandler;
- (BOOL)writePackets:(NSArray<NSData *> * __nonnull)packets withProtocols:(NSArray<NSNumber *> * __nonnull)protocols;

@end

@interface OvpnAPI : NSObject

- (instancetype __nonnull)init;

// @function init method
- (instancetype __nonnull)initWithDelegate:(id<OvpnDelegate> __nonnull)delegate;

// @statement the ovpn delegate
@property (nonatomic, assign) id<OvpnDelegate> __nonnull delegate;

// @function evalute profile with error
// if failure, error returns
- (BOOL)evaluateProfile:(NSData * __nonnull)profile;

// @function connect OpenVPN
// and callback handleLog: excuting connect
// shoule invoke it in new thread
- (void)connect;

// @function disconnect OpenVPN
- (void)disconnect;

@end
