//
//  Server.swift
//  feather
//
//  Created by samara on 22.08.2024.
//  Copyright © 2024 Lakr Aream. All Rights Reserved.
//  ORIGINALLY LICENSED UNDER GPL-3.0, MODIFIED FOR USE FOR FEATHER
//

import Foundation
import Vapor
import NIOSSL
import NIOTLS
import SwiftUI
import IDeviceSwift

// MARK: - Class
class ServerInstaller: Identifiable, ObservableObject {
	let id = UUID()
	let port = Int.random(in: 4000...8000)
	private var _needsShutdown = false
	
	var packageUrl: URL?
	var app: AppInfoPresentable
	@ObservedObject var viewModel: InstallerStatusViewModel
	private var _server: Application?

	init(app: AppInfoPresentable, viewModel: InstallerStatusViewModel) {
		self.app = app
		self.viewModel = viewModel
        // Constructing a SwiftUI installation sheet must not start Vapor/TLS on the UI thread.
    }

    func start() throws {
        guard _server == nil else { return }
        try _setup()
        _needsShutdown = true
        do {
            try _configureRoutes()
            try _server?.server.start()
        } catch {
            _shutdownServer()
            _server = nil
            throw error
        }
	}
	
    deinit {
        if _needsShutdown, let server = _server {
            DispatchQueue.global(qos: .utility).async {
                server.server.shutdown()
                server.shutdown()
            }
        }
    }
	
	private func _setup() throws {
		self._server = try setupApp(port: port)
	}
		
	private func _configureRoutes() throws {
		_server?.get("*") { [weak self] req in
			guard let self else { return Response(status: .badGateway) }
			
			// Never let iOS cache anything (manifest / ipa / page)
			var headers = HTTPHeaders()
			headers.add(name: .cacheControl, value: "no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0")
			headers.add(name: .pragma, value: "no-cache")
			headers.add(name: .expires, value: "0")
			
			switch req.url.path {
			case self.plistEndpoint.path:
				self._updateStatus(.sendingManifest)
				headers.add(name: .contentType, value: "text/xml")
				return Response(status: .ok, version: req.version, headers: headers, body: .init(data: self.installManifestData))
			case self.displayImageSmallEndpoint.path:
				headers.add(name: .contentType, value: "image/png")
				return Response(status: .ok, version: req.version, headers: headers, body: .init(data: self.displayImageSmallData))
			case self.displayImageLargeEndpoint.path:
				headers.add(name: .contentType, value: "image/png")
				return Response(status: .ok, version: req.version, headers: headers, body: .init(data: self.displayImageLargeData))
			case self.payloadEndpoint.path:
				guard let packageUrl = self.packageUrl else {
					return Response(status: .notFound)
				}
				
				self._updateStatus(.sendingPayload)
				
				let response = req.fileio.streamFile(
					at: packageUrl.path
				) { result in
					switch result {
					case .success:
						self._updateStatus(.installing)
					case .failure(let error):
						self._updateStatus(.broken(error))
					}
				}
				response.headers.add(name: .cacheControl, value: "no-store, no-cache, must-revalidate, max-age=0")
				return response
			case "/install":
				headers.add(name: .contentType, value: "text/html")
				var finalHTML = self.html
				let uuidBuster = UUID().uuidString.replacingOccurrences(of: "-", with: "")
				if finalHTML.contains("\"</script>") {
					finalHTML = finalHTML.replacingOccurrences(of: "\"</script>", with: "%26cb%3D\(uuidBuster)\"</script>")
				}
				return Response(status: .ok, headers: headers, body: .init(string: finalHTML))
			default:
				return Response(status: .notFound)
			}
		}
	}
	
	private func _shutdownServer() {
		guard _needsShutdown else { return }
		
		_needsShutdown = false
		_server?.server.shutdown()
		_server?.shutdown()
	}
	
	private func _updateStatus(_ newStatus: InstallerStatusViewModel.InstallerStatus) {
		DispatchQueue.main.async {
			self.viewModel.status = newStatus
		}
	}
		
	func getServerMethod() -> Int {
		UserDefaults.standard.integer(forKey: "Feather.serverMethod")
	}
	
	func getIPFix() -> Bool {
		UserDefaults.standard.bool(forKey: "Feather.ipFix")
	}
}
