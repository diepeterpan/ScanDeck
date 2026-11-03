# Changelog

All notable changes to ScanDeck are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

`MAJOR.MINOR.PATCH` represents:

- **MAJOR** — Breaking changes in the REST API or `config.json` schema requiring manual intervention.
- **MINOR** — New backward-compatible features and functionality.
- **PATCH** — Backward-compatible bug fixes and internal improvements.

## [Unreleased]

## [1.10.0] - 2026-08-13

### Added

- **Skip blank pages** (opt-in). Blank reverse sides during duplex scans are detected by evaluating page coverage (excluding 4% outer margin to discount dust or shadow). Pages with even a single line of text are kept. If all pages in a job are blank, an error is reported instead of storing an empty document.
- **Deskew crooked pages** (opt-in). Straightens misaligned scans using a projection profile algorithm (accurate to 0.1°), improving OCR quality. Skews under 0.4° are untouched to avoid unnecessary re-rasterization.
- **Profiles**: One tap instead of multiple switches. Presets save source, resolution, color, format, paper size, and tags, appearing as a quick-action button above the scan orb. Validated under standard config rules. Supported via Home Assistant: `{"profile": "invoice"}`.
- **Home Assistant via MQTT**: Automatic entity discovery — 5 buttons (scan, cancel, batch start/save/discard) and 7 sensors (status, progress, queue, last scan, feeder, scanning, batch open). No `configuration.yaml` changes required.
- **Web Push notifications to phone** (opt-in): Notifies when Paperless confirms a document. Keys generated locally on first activation.
- **Sound and vibration feedback** (opt-in): Immediate audio/vibration feedback upon scan completion or failure.

### Fixed

- **MQTT broker password and push private key exclusion**: Ensured secrets are omitted from `/api/config` responses.

## [1.9.0] - 2026-08-12

### Fixed

- **Feeder tray polling**: Status is now polled dynamically every 4 seconds while feeder is selected and app is visible.

### Changed

- **Streamlined dashboard resolutions**: Quick-toggle now cycles 150, 300, and 600 dpi. 1200 dpi remains available under full settings.
- **Reorganized settings**: Device capabilities are displayed directly in the Scanner card.
- **Collapsible sections**: Paperless and Home Assistant settings are collapsed by default.

### Added

- **Rotate all and Reverse order**: Bulk reordering operations for batch mode.

## [1.8.0] - 2026-08-12

### Added

- **Paper size selector**: Added support for A4, Letter, Legal, and A5, with automatic dimension validation and clipping against scanner capabilities.
- **Duplex scanning support**: Allows scanning both sides when supported by feeder hardware.

## [1.7.0] - 2026-08-11

### Added

- **Access protection**: Optional password protection for web UI and API endpoints, leaving `/health` and Home Assistant API key endpoints open.
- **Brute force lockout**: Repeated failed logins trigger exponential throttling.

## [1.6.2] - 2026-08-11

### Fixed

- Reconnection resilience for SSE log streaming.

## [1.6.1] - 2026-08-11

### Fixed

- Handled edge cases in scanner capability XML parsing across various vendor models.

## [1.6.0] - 2026-08-11

### Added

- **Automatic retention cleanup**: Scheduled cleanup of local scan copies once confirmed by Paperless-ngx.

## [1.5.0] - 2026-08-11

### Added

- **Accurate scan progress estimates**: Profiles maintain rolling averages in `timings.json` to calculate realistic progress ramps.

## [1.4.1] - 2026-08-10

### Fixed

- Improved sheet feeder NextDocument polling handling.

## [1.4.0] - 2026-08-10

### Added

- **Paperless metadata picker**: Choose correspondent and document type directly before scan.
- **Quick tags**: Suggestions populated from existing Paperless tags.

## [1.3.0] - 2026-08-10

### Added

- **Interactive batch mode**: Collect pages into a unified PDF with visual reordering, rotation, page replacement, and deletion.

## [1.2.0] - 2026-08-10

### Added

- **Automatic network discovery**: Probes local subnets for eSCL scanners on startup and setup.
- **Home Assistant batch controls**: REST endpoints to manage batches from automations.

## [1.1.0] - 2026-08-10

### Added

- Version display and automated GitHub release checks.
- Multi-arch Docker images published to GitHub Container Registry.
- Automatic permissions setup in container entrypoint with `PUID`/`PGID` support.

## [1.0.0] - 2026-08-10

Initial stable release.

### Added

- Step-by-step setup wizard.
- Live scan progress reporting via SSE.
- 10-second post-scan rasterized preview.
- Home Assistant REST integration and webhooks.
- PWA support with offline caching and home screen shortcuts.
- eSCL network scanner discovery.
- Session-specific tags.

[Unreleased]: https://github.com/derSumo/ScanDeck/compare/v1.10.0...HEAD
[1.10.0]: https://github.com/derSumo/ScanDeck/compare/v1.9.0...v1.10.0
[1.9.0]: https://github.com/derSumo/ScanDeck/compare/v1.8.0...v1.9.0
[1.8.0]: https://github.com/derSumo/ScanDeck/compare/v1.7.0...v1.8.0
[1.7.0]: https://github.com/derSumo/ScanDeck/compare/v1.6.2...v1.7.0
[1.6.2]: https://github.com/derSumo/ScanDeck/compare/v1.6.1...v1.6.2
[1.6.1]: https://github.com/derSumo/ScanDeck/compare/v1.6.0...v1.6.1
[1.6.0]: https://github.com/derSumo/ScanDeck/compare/v1.5.0...v1.6.0
[1.5.0]: https://github.com/derSumo/ScanDeck/compare/v1.4.1...v1.5.0
[1.4.1]: https://github.com/derSumo/ScanDeck/compare/v1.4.0...v1.4.1
[1.4.0]: https://github.com/derSumo/ScanDeck/compare/v1.3.0...v1.4.0
[1.3.0]: https://github.com/derSumo/ScanDeck/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/derSumo/ScanDeck/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/derSumo/ScanDeck/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/derSumo/ScanDeck/releases/tag/v1.0.0
