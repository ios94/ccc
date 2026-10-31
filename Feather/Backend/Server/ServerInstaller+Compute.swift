//
//  Server+Compute.swift
//  feather
//
//  Created by samara on 22.08.2024.
//  Copyright © 2024 Lakr Aream. All Rights Reserved.
//  ORIGINALLY LICENSED UNDER GPL-3.0, MODIFIED FOR USE FOR FEATHER
//

import Foundation
import UIKit.UIGraphicsImageRenderer

extension ServerInstaller {
	var plistEndpoint: URL {
		var comps = URLComponents()
		comps.scheme = self.getServerMethod() == 1 ? "http" : "https"
		comps.host = sni()
		comps.path = "/\(id).plist"
		comps.port = port
		return comps.url!
	}

	var payloadEndpoint: URL {
		var comps = URLComponents()
		comps.scheme = "http"
		comps.host = "127.0.0.1"
		comps.path = "/\(id).ipa"
		comps.port = port
		return comps.url!
	}
	
	var pageEndpoint: URL {
		var comps = URLComponents()
		comps.scheme = "http"
		comps.host = "127.0.0.1"
		comps.path = "/install"
		comps.port = port
		return comps.url!
	}
	
	var externalManifestURL: URL {
		var components = URLComponents()
		components.scheme = "https"
		components.host = "install.ashtemobile.site"
		components.path = "/genPlist"
		components.queryItems = [
			.init(name: "bundleid", value: app.identifier),
			.init(name: "name", value: app.name),
			.init(name: "version", value: app.version),
			.init(name: "fetchurl", value: payloadEndpoint.absoluteString),
		]
		return components.url!
	}

	var iTunesLink: String {
		_iTunesLink(with: plistEndpoint.absoluteString)
	}
	
	var iTunesLinkExternal: String {
		_iTunesLink(with: externalManifestURL.absoluteString)
	}
	
	private func _iTunesLink(with url: String) -> String {
		let encodedManifestURL = url.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
		return "itms-services://?action=download-manifest&url=\(encodedManifestURL)"
	}

    // AshteMobile does not use any third-party branded manifest host; the standard local install flow is used.
    var brandedManifestEndpoint: URL? { nil }

    @MainActor private static var brandedEndpointUnavailableUntil = Date.distantPast

    @MainActor
    func verifiedBrandedInstallLink() async -> URL? {
        guard Date() >= Self.brandedEndpointUnavailableUntil,
              let manifestURL = brandedManifestEndpoint else { return nil }
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 7
        configuration.urlCache = nil
        let session = URLSession(configuration: configuration)
        defer { session.invalidateAndCancel() }
        var request = URLRequest(url: manifestURL, cachePolicy: .reloadIgnoringLocalCacheData)
        request.setValue("application/xml", forHTTPHeaderField: "Accept")
        guard let (data, response) = try? await session.data(for: request), !Task.isCancelled else {
            Self.brandedEndpointUnavailableUntil = Date().addingTimeInterval(30)
            return nil
        }
        guard let http = response as? HTTPURLResponse else { return nil }
        if http.statusCode == 404 || http.mimeType?.lowercased() == "text/html" {
            Self.brandedEndpointUnavailableUntil = Date().addingTimeInterval(300)
            return nil
        }
        guard http.statusCode == 200,
              http.url == manifestURL,
              data.count <= 32_768,
              ["application/xml", "text/xml", "application/x-plist"].contains(http.mimeType?.lowercased() ?? ""),
              let root = (try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)) as? [String: Any],
              let items = root["items"] as? [[String: Any]], let item = items.first,
              let metadata = item["metadata"] as? [String: Any],
              metadata["bundle-identifier"] as? String == app.identifier,
              metadata["bundle-version"] as? String == (app.version ?? "1.0"),
              let assets = item["assets"] as? [[String: Any]],
              assets.contains(where: { ($0["kind"] as? String) == "software-package" && ($0["url"] as? String) == payloadEndpoint.absoluteString })
        else { return nil }
        return URL(string: _iTunesLink(with: manifestURL.absoluteString))
    }


	var displayImageSmallEndpoint: URL {
		var comps = URLComponents()
		comps.scheme = "https"
		comps.host = sni()
		comps.path = "/app57x57.png"
		comps.port = port
		return comps.url!
	}

	var displayImageLargeEndpoint: URL {
		var comps = URLComponents()
		comps.scheme = "https"
		comps.host = sni()
		comps.path = "/app512x512.png"
		comps.port = port
		return comps.url!
	}
	
	var displayImageSmallData: Data {
		_createIcon(57)
	}
	
	var displayImageLargeData: Data {
		_createIcon(512)
	}
	
	private func _createIcon(_ r: CGFloat) -> Data {
		let renderer = UIGraphicsImageRenderer(size: .init(width: r, height: r))
		let image = renderer.image { ctx in
			UIColor.tintColor.setFill()
			ctx.fill(.init(x: 0, y: 0, width: r, height: r))
		}
		return image.pngData()!
	}

	var html: String {
		"""
		<html style="background-color: black;">
		<script type="text/javascript">window.location="\(iTunesLinkExternal)"</script>
		</html>
		"""
	}

	var installManifest: [String: Any] {[
		"items": [[
			"assets": [
				[
					"kind": "software-package",
					"url": payloadEndpoint.absoluteString,
				],
				[
					"kind": "display-image",
					"url": displayImageSmallEndpoint.absoluteString,
				],
				[
					"kind": "full-size-image",
					"url": displayImageLargeEndpoint.absoluteString,
				],
			],
			"metadata": [
				"bundle-identifier": app.identifier,
				"bundle-version": app.version,
				"kind": "software",
				"title": app.name,
			],
		],],
	]}

	var installManifestData: Data {
		(try? PropertyListSerialization.data(
			fromPropertyList: installManifest,
			format: .xml,
			options: .zero
		)) ?? .init()
	}
}
