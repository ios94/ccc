import Foundation

/// Stops the app from sending any http(s) request while a proxy / VPN /
/// traffic-capture tool is active, so nothing (source links, JSON, images)
/// can be seen by that tool.
enum NetworkShield {
    /// Call once at app start. Also covers `URLSession.shared`.
    static func install() {
        URLProtocol.registerClass(ShieldURLProtocol.self)
    }

    /// Adds the shield to a custom session configuration.
    static func protect(_ config: URLSessionConfiguration) -> URLSessionConfiguration {
        var classes = config.protocolClasses ?? []
        if !classes.contains(where: { $0 == ShieldURLProtocol.self }) {
            classes.insert(ShieldURLProtocol.self, at: 0)
        }
        config.protocolClasses = classes
        return config
    }

    /// True while a proxy / VPN is detected on the device.
    static var isHostileNetwork: Bool {
        guard let cf = CFNetworkCopySystemProxySettings()?.takeRetainedValue(),
              let settings = cf as NSDictionary as? [String: Any] else { return false }

        let proxyKeys = ["HTTPEnable", "HTTPSEnable", "SOCKSEnable", "ProxyAutoConfigEnable",
                         "HTTPProxy", "HTTPSProxy", "SOCKSProxy"]
        for key in proxyKeys {
            if let val = settings[key] as? Int, val == 1 { return true }
            if let str = settings[key] as? String, !str.isEmpty { return true }
        }
        if let scoped = settings["__SCOPED__"] as? [String: Any] {
            let vpnNames = ["tap", "tun", "utun", "ppp", "ipsec", "wg", "pptp", "l2tp"]
            for interface in scoped.keys {
                let lower = interface.lowercased()
                if vpnNames.contains(where: { lower.contains($0) }) { return true }
            }
        }
        return false
    }
}

final class ShieldURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url,
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https" else { return false }
        // Local install server must keep working.
        if let host = url.host?.lowercased(), host == "127.0.0.1" || host == "localhost" { return false }
        return NetworkShield.isHostileNetwork
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        client?.urlProtocol(self, didFailWithError: URLError(.notConnectedToInternet))
    }

    override func stopLoading() {}
}
