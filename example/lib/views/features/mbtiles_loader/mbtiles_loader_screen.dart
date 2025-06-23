import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:naxalibre/naxalibre.dart';
import 'package:path_provider/path_provider.dart';
import '../../common/feature_button.dart';
import '../base_map/base_map_screen.dart';
import 'package:another_flushbar/flushbar.dart';

class MBTilesLoaderScreen extends BaseMapScreen {
  const MBTilesLoaderScreen({super.key}) : super(title: 'MBTiles Loader');

  @override
  State<MBTilesLoaderScreen> createState() => _MBTilesLoaderScreenState();
}

class _MBTilesLoaderScreenState
    extends BaseMapScreenState<MBTilesLoaderScreen> {
  bool _mbtilesLoaded = false;
  String? _statusMessage;
  String? _errorMessage;
  final String _mbtilesAssetPath = 'assets/Enroute_Low.mbtiles';
  final String sourceId = "mbtile_source_id";
  final String layerId = "mbtile_layer_id";
  String? _mbtilesFilePath;
  double _tileSize = 512; // Default tile size
  double _opacity = 1.0; // Default opacity

  @override
  void initState() {
    super.initState();
    // Prepare the MBTiles file when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prepareMBTiles();
    });
  }

  @override
  Widget buildMapWithControls() {
    return Stack(
      children: [
        buildBaseMap(),
        // Status message display
        if (_statusMessage != null || _errorMessage != null)
          Positioned(
            top: kToolbarHeight + 20,
            left: 20,
            right: 20,
            child: Card(
              color:
                  _errorMessage != null
                      ? Colors.red.withOpacity(0.8)
                      : Colors.green.withOpacity(0.8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  _errorMessage ?? _statusMessage ?? "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        // Settings panel
        Positioned(
          left: 16,
          bottom: 120,
          right: 16,
          child: Card(
            color: Colors.black.withOpacity(0.7),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Tile size",
                    style: TextStyle(color: Colors.white),
                  ),
                  Slider(
                    value: _tileSize,
                    min: 256,
                    max: 1024,
                    divisions: 3, // 256, 512, 768, 1024
                    label: _tileSize.toStringAsFixed(0),
                    onChanged: (value) {
                      setState(() {
                        _tileSize = value;
                      });
                    },
                  ),
                  const Text("Opacity", style: TextStyle(color: Colors.white)),
                  Slider(
                    value: _opacity,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    label: _opacity.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _opacity = value;
                      });
                      // If layer is already loaded, update its opacity
                      if (_mbtilesLoaded) {
                        _updateLayerOpacity();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // Control buttons
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FeatureButton(
                label: _mbtilesLoaded ? "Remove MBTiles" : "Load MBTiles",
                icon: _mbtilesLoaded ? Icons.layers_clear : Icons.layers,
                onPressed:
                    _mbtilesLoaded ? _removeMBTilesLayer : _loadMBTilesLayer,
              ),
              const SizedBox(height: 8),
              FeatureButton(
                label: "Reset Map",
                icon: Icons.refresh,
                onPressed: _resetMap,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void onControllerReady(NaxaLibreController? mapController) {
    super.onControllerReady(mapController);
    debugPrint("MBTiles Loader: Map controller ready");
  }

  /// Copies the MBTiles file from assets to the app directory
  Future<void> _prepareMBTiles() async {
    try {
      setState(() {
        _statusMessage = "Preparing MBTiles file...";
        _errorMessage = null;
      });

      final mbtilesFilePath = await _copyMBTilesFromAssets();

      setState(() {
        _mbtilesFilePath = mbtilesFilePath;
        _statusMessage = "MBTiles file prepared. Ready to load.";
      });

      // Auto-hide status after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _statusMessage = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error preparing MBTiles: $e";
        _statusMessage = null;
      });
      debugPrint("[MBTilesLoaderScreen._prepareMBTiles] => $e");
    }
  }

  /// Copies the MBTiles file from assets to app directory and returns the path
  Future<String> _copyMBTilesFromAssets() async {
    try {
      final ByteData data = await rootBundle.load(_mbtilesAssetPath);
      final List<int> bytes = data.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${_mbtilesAssetPath.split('/').last}');
      await file.writeAsBytes(bytes);
      debugPrint("[MBTilesLoaderScreen] MBTiles file copied to: ${file.path}");

      // For Android, we need to use mbtiles:// protocol, not file://
      if (Platform.isAndroid) {
        return 'mbtiles://${file.path}';
      } else {
        return 'file://${file.path}';
      }
    } catch (e) {
      debugPrint("[MBTilesLoaderScreen] Error copying MBTiles file: $e");
      rethrow;
    }
  }

  /// Loads the MBTiles file and adds it as a layer to the map
  Future<void> _loadMBTilesLayer() async {
    if (_mbtilesFilePath == null) {
      setState(() {
        _errorMessage = "MBTiles file not ready yet. Please try again.";
      });
      return;
    }

    try {
      setState(() {
        _statusMessage = "Loading MBTiles layer...";
        _errorMessage = null;
      });

      // Debug the file path we're using
      debugPrint(
        "[MBTilesLoaderScreen] Attempting to load MBTiles from: $_mbtilesFilePath",
      );

      // Add the raster source from the MBTiles file
      await controller?.addSource<RasterSource>(
        source: RasterSource(
          sourceId: sourceId,
          sourceProperties: RasterSourceProperties(tileSize: _tileSize.toInt()),
          url: _mbtilesFilePath,
        ),
      );

      // Add a layer using the source
      await controller?.addLayer<RasterLayer>(
        layer: RasterLayer(
          layerId: layerId,
          sourceId: sourceId,
          layerProperties: RasterLayerProperties(rasterOpacity: _opacity),
        ),
      );

      debugPrint("[MBTilesLoaderScreen] Layer added successfully");

      setState(() {
        _mbtilesLoaded = true;
        _statusMessage = "MBTiles layer loaded successfully!";
      });

      // Show a success message
      if (mounted) {
        Flushbar(
          messageText: const Text(
            'MBTiles layer added',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.white.withOpacity(0.95),
          margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
          borderRadius: BorderRadius.circular(12),
          duration: const Duration(seconds: 2),
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);
      }

      // Auto-hide status after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _statusMessage = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error loading MBTiles: $e";
        _statusMessage = null;
      });
      debugPrint("[MBTilesLoaderScreen._loadMBTilesLayer] => $e");
    }
  }

  /// Removes the MBTiles layer from the map
  Future<void> _removeMBTilesLayer() async {
    try {
      setState(() {
        _statusMessage = "Removing MBTiles layer...";
        _errorMessage = null;
      });

      // Remove the layer first
      await controller?.removeLayer(layerId);

      // Then remove the source
      await controller?.removeSource(sourceId);

      setState(() {
        _mbtilesLoaded = false;
        _statusMessage = "MBTiles layer removed.";
      });

      // Auto-hide status after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _statusMessage = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error removing MBTiles layer: $e";
        _statusMessage = null;
      });
      debugPrint("[MBTilesLoaderScreen._removeMBTilesLayer] => $e");
    }
  }

  /// Updates the opacity of the MBTiles layer
  Future<void> _updateLayerOpacity() async {
    try {
      // We need to create a new layer with updated opacity and replace the existing one
      await controller?.removeLayer(layerId);

      await controller?.addLayer<RasterLayer>(
        layer: RasterLayer(
          layerId: layerId,
          sourceId: sourceId,
          layerProperties: RasterLayerProperties(rasterOpacity: _opacity),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = "Error updating layer opacity: $e";
      });
      debugPrint("[MBTilesLoaderScreen._updateLayerOpacity] => $e");
    }
  }

  /// Resets the map view
  void _resetMap() {
    controller?.animateCamera(
      CameraUpdateFactory.newLatLng(
        LatLng(28.25, 84.0), // Approximate center of Nepal
        6.0,
      ),
      duration: const Duration(milliseconds: 500),
    );
  }
}
