import CoreLocation

/// Lightweight service that fetches the user's current location name (city/neighborhood).
final class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var locationContinuation: CheckedContinuation<String?, Never>?

    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    /// Requests permission if needed, fetches the current location, and reverse-geocodes it.
    /// Returns a readable place name (e.g. "Downtown Coffee Shop" area) or nil if unavailable.
    func fetchCurrentLocationName() async -> String? {
        let status = manager.authorizationStatus

        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
            // Wait briefly for the authorization callback
            try? await Task.sleep(for: .milliseconds(500))
        }

        let currentStatus = manager.authorizationStatus
        guard currentStatus == .authorizedWhenInUse || currentStatus == .authorizedAlways else {
            return nil
        }

        // Get the current location
        guard let location = await requestLocation() else { return nil }

        // Reverse geocode
        return await reverseGeocode(location)
    }

    private func requestLocation() async -> CLLocation? {
        await withCheckedContinuation { (continuation: CheckedContinuation<CLLocation?, Never>) in
            // Use the last known location if it's recent (within 60 seconds)
            if let last = manager.location,
               Date.now.timeIntervalSince(last.timestamp) < 60 {
                continuation.resume(returning: last)
                return
            }

            // Otherwise request a fresh location
            self.locationContinuation = nil
            manager.requestLocation()

            // Wait up to 5 seconds for a location update
            Task {
                try? await Task.sleep(for: .seconds(5))
                if let loc = self.manager.location {
                    continuation.resume(returning: loc)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    private func reverseGeocode(_ location: CLLocation) async -> String? {
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            guard let placemark = placemarks.first else { return nil }

            // Build a readable name: prefer locality (city), with subLocality (neighborhood) if available
            var parts: [String] = []

            if let subLocality = placemark.subLocality {
                parts.append(subLocality)
            }
            if let locality = placemark.locality {
                parts.append(locality)
            }

            if parts.isEmpty, let name = placemark.name {
                return name
            }

            return parts.isEmpty ? nil : parts.joined(separator: ", ")
        } catch {
            return nil
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Location received — handled by the polling in requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Location failed — handled by the timeout in requestLocation()
    }
}
