# Student Ride-Sharing Prototype

A Flutter prototype exploring a student ride-sharing experience. It demonstrates a map-based trip flow: choose a destination, preview a route, compare ride categories and estimated fares, and request a ride.

This is a completed prototype, not a live ride service. Nearby vehicles are synthetic, and ride requests use a simulated dispatch flow that assigns a predefined driver after a short delay. The app has no backend, live driver dispatch, student verification, or shared-ride matching.

## Features

- Custom Flutter vector map with synthetic nearby vehicles and route visualization.
- Destination selection and generated route previews with distance and duration estimates.
- Ride category selection and fare estimates.
- A simulated ride-request and driver-assignment flow.
- A pure Dart H3-style spatial indexing implementation, with an optional map grid visualization.
- Prototype security-status and device-audit UI.

The route geometry, vehicle positions, traffic segments, fares, surge values, and driver details are illustrative prototype data. They should not be treated as live transportation information or production pricing.

## Gemma and Ride Matching

Gemma is not integrated into the current app. There are no model calls or inference service in this prototype.

Gemma is a possible next step for interpreting student ride requests written in natural language—for example, extracting a preferred departure window or willingness to take a detour—and explaining why a ride may be a good fit. A separate, deterministic matching service could compare those preferences with candidate rides using factors such as location, route overlap, timing, and available seats. The model would assist with request interpretation and explanations; explicit, testable matching rules should make the actual selection.

H3 could help organize nearby candidates spatially, but the current implementation does not perform real driver discovery or ride matching.

## Run the App

Requirements: Flutter 3.x or later.

```bash
flutter pub get
flutter run
```

## Project Structure

- `lib/presentation/` — map screen, ride selection, driver tracking, and UI widgets.
- `lib/services/` — prototype ride flow, location, and map styling services.
- `lib/core/spatial/` — geographic coordinates and H3-style spatial indexing.
- `lib/core/security/` — prototype device security checks and status reporting.
- `test/` — tests for spatial indexing and security-engine behavior.

## Limitations

- No server, account system, student verification, or persistent ride data.
- No real-time locations, driver network, dispatch, or shared-ride matching.
- Gemma and other AI inference are not implemented.
- Map, route, fare, traffic, and vehicle information is synthetic and not suitable for navigation, safety, or pricing decisions.
