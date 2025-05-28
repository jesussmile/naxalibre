import 'package:flutter/material.dart';
import 'package:naxalibre/naxalibre.dart';
import 'package:naxalibre/src/sources/source.dart';
import 'package:naxalibre/src/layers/layer.dart';
import 'package:naxalibre/src/models/latlng.dart';
import 'dart:io'; // For File operations
import 'dart:typed_data'; // For ByteData
import 'dart:ui'; // For ByteData
import 'package:flutter/services.dart' show rootBundle; // For loading assets
import 'package:path_provider/path_provider.dart'; // For temporary directory
import 'package:naxalibre/src/models/latlng_quad.dart';
import 'package:naxalibre/src/models/naxalibre_map_options.dart'; // Import NaxaLibreMapOptions
import 'package:naxalibre/src/models/camera_position.dart'; // Import CameraPosition
import 'package:naxalibre/src/models/camera_update.dart'; // Import CameraUpdate for CameraUpdateFactory

class ImageOverlayScreen extends StatefulWidget {
  const ImageOverlayScreen({super.key});

  @override
  State<ImageOverlayScreen> createState() => _ImageOverlayScreenState();
}

class _ImageOverlayScreenState extends State<ImageOverlayScreen> {
  NaxaLibreController? _controller;
  String _currentImageUrl =
      "https://docs.mapbox.com/mapbox-gl-js/assets/radar.gif";
  bool _isNetworkImage = true;

  final String _networkImageUrl =
      "https://docs.mapbox.com/mapbox-gl-js/assets/radar.gif";
  final String _assetImageUrl = "assets/overlay_image.jpeg";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Overlay')),
      body: Stack(
        children: [
          NaxaLibreMap(
            style:
                "https://tiles.basemaps.cartocdn.com/gl/positron-gl-style/style.json", // Using a public CartoDB style
            mapOptions: NaxaLibreMapOptions(
              // Use mapOptions to set camera position
              position: CameraPosition(
                target: LatLng(27.7172, 85.3240), // Center of Nepal (Kathmandu)
                zoom: 6.0, // Adjust zoom level as needed
              ),
            ),
            onMapCreated: (controller) {
              debugPrint("[ImageOverlayScreen] Map created, controller set.");
              _controller = controller;
            },
            onStyleLoaded: () async {
              debugPrint(
                "[ImageOverlayScreen] Style loaded. Attempting to add image source and layer.",
              );
              _addImageOverlay();
            },
          ),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentImageUrl = _networkImageUrl;
                      _isNetworkImage = true;
                    });
                    _updateImageOverlay();
                  },
                  child: const Text('Show Network Image'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentImageUrl = _assetImageUrl;
                      _isNetworkImage = false;
                    });
                    _updateImageOverlay();
                  },
                  child: const Text('Show Asset Image'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addImageOverlay() async {
    // Define the coordinates for the four corners of your image
    // These LatLng values represent: topLeft, topRight, bottomRight, bottomLeft
    final LatLngQuad imageCoordinates = LatLngQuad(
      LatLng(30.5, 80.0), // Top-left (northwest)
      LatLng(30.5, 88.0), // Top-right (northeast)
      LatLng(26.0, 88.0), // Bottom-right (southeast)
      LatLng(26.0, 80.0), // Bottom-left (southwest)
    );

    // Remove existing source and layer if they exist
    await _controller?.removeLayer("my-overlay-image-layer");
    await _controller?.removeSource("my-overlay-image-source");

    String imageUrlToUse = _currentImageUrl;
    if (!_isNetworkImage) {
      imageUrlToUse = await _loadAssetImageAsFileUrl(_assetImageUrl);
      debugPrint("[ImageOverlayScreen] Asset image URL: $imageUrlToUse");
    }

    // Add the ImageSource
    await _controller?.addSource<ImageSource>(
      source: ImageSource(
        sourceId: "my-overlay-image-source",
        url: imageUrlToUse,
        coordinates: imageCoordinates,
        sourceProperties: ImageSourceProperties(prefetchZoomDelta: 4),
      ),
    );

    // Add a RasterLayer to display the image
    await _controller?.addLayer<RasterLayer>(
      layer: RasterLayer(
        layerId: "my-overlay-image-layer",
        sourceId: "my-overlay-image-source",
        layerProperties: RasterLayerProperties(
          rasterOpacity: 1.0, // Ensure the image is fully opaque
        ),
      ),
    );
    debugPrint("[ImageOverlayScreen] Image overlay added: $imageUrlToUse");

    // Animate camera to the center of Nepal
    await _controller?.animateCamera(
      CameraUpdateFactory.newLatLng(
        LatLng(28.25, 84.0), // Approximate center of Nepal
        6.0, // Adjust zoom level as needed to fit the image
      ),
      duration: const Duration(milliseconds: 500),
    );
  }

  Future<String> _loadAssetImageAsFileUrl(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final List<int> bytes = data.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${assetPath.split('/').last}');
      await file.writeAsBytes(bytes);
      return 'file://${file.path}';
    } catch (e) {
      debugPrint("[ImageOverlayScreen] Error loading asset image: $e");
      return ""; // Return empty string or handle error appropriately
    }
  }

  Future<void> _updateImageOverlay() async {
    if (_controller != null) {
      await _addImageOverlay();
    } else {
      debugPrint("[ImageOverlayScreen] Controller not ready for update.");
    }
  }
}
