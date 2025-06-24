import 'package:flutter/material.dart';
import 'package:naxalibre/naxalibre.dart';

import '../base_map/base_map_screen.dart';

// Traffic Screen - using MapLibre demo tiles which work offline once loaded
class TrafficScreen extends BaseMapScreen {
  const TrafficScreen({super.key}) : super(title: 'Traffic');

  @override
  State<TrafficScreen> createState() => _TrafficScreenState();
}

class _TrafficScreenState extends BaseMapScreenState<TrafficScreen> {
  // We don't track _isMapLoaded since we're not using it for any functionality
  String? _infoMessage;

  // Default MapLibre demo tiles URL - works offline once initially loaded
  final String _mapStyleUrl = "https://demotiles.maplibre.org/style.json";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget buildMapWithControls() {
    return Stack(
      children: [
        // Use NaxaLibreMap directly instead of buildBaseMap() to use custom style URL
        NaxaLibreMap(
          style: _mapStyleUrl,
          locationSettings: LocationSettings(
            locationEnabled: true,
            shouldRequestAuthorizationOrPermission: true,
            locationComponentOptions: LocationComponentOptions(
              pulseColor: "red",
              backgroundTintColor: "yellow",
              foregroundTintColor: "green",
            ),
          ),
          onMapCreated: (controller) {
            debugPrint("[TrafficScreen] Map created");
            this.controller = controller;
            onControllerReady(controller);

            // Schedule the setState for after the build is complete
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _infoMessage = "Map will work offline once initially loaded";
                });

                // Auto-hide the message after 5 seconds
                Future.delayed(const Duration(seconds: 5), () {
                  if (mounted) {
                    setState(() {
                      _infoMessage = null;
                    });
                  }
                });
              }
            });
          },
          onStyleLoaded: () {
            debugPrint("[TrafficScreen] Style loaded");
            // No need to track _isMapLoaded since we don't use it
          },
          onMapClick: (latLng) {
            debugPrint(
              "[TrafficScreen] Click on map at ${latLng.latLngList()}",
            );
          },
        ),

        // Show info message
        if (_infoMessage != null)
          Positioned(
            top: kToolbarHeight + 20,
            left: 20,
            right: 20,
            child: Card(
              color: Colors.green.withValues(alpha: 180),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  _infoMessage!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

        // Simple control buttons
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: "zoomIn",
                onPressed: () => controller?.zoomIn(),
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: "zoomOut",
                onPressed: () => controller?.zoomOut(),
                child: const Icon(Icons.remove),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: "info",
                onPressed: _showInfoMessage,
                child: const Icon(Icons.info_outline),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Show an info message about the offline capability
  void _showInfoMessage() {
    setState(() {
      _infoMessage =
          "This map uses MapLibre's demo tiles.\nIt works offline after initial loading.";
    });

    // Auto-hide the message after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _infoMessage = null;
        });
      }
    });
  }
}
