import 'dart:io';

import 'package:flutter/material.dart';
import 'package:naxalibre/naxalibre.dart';
import 'package:another_flushbar/flushbar.dart';

import '../base_map/base_map_screen.dart';
import 'widgets/layer_button.dart';

// 3. Layer Management Screen
class LayerManagementScreen extends BaseMapScreen {
  const LayerManagementScreen({super.key}) : super(title: 'Layer Management');

  @override
  State<LayerManagementScreen> createState() => _LayerManagementScreenState();
}

class _LayerManagementScreenState
    extends BaseMapScreenState<LayerManagementScreen> {
  int? _selectedIndex;

  void _onAction(int index, VoidCallback action) async {
    if (_selectedIndex == index) {
      setState(() {
        _selectedIndex = null;
      });
      if (index == 0) {
        // Remove Circle Layer and Source
        await controller?.removeLayer('layerId');
        await controller?.removeLayer('symbolLayerId');
        await controller?.removeSource('sourceId');
      } else if (index == 1) {
        // Remove Line Layer and Source
        await controller?.removeLayer('lineLayerId');
        await controller?.removeSource('lineSourceId');
      } else if (index == 2) {
        // Remove Fill Layer and Source
        await controller?.removeLayer('fillLayerId');
        await controller?.removeSource('fillSourceId');
      } else if (index == 3) {
        // Remove Point Layer and Source
        await controller?.removeLayer('singleFeatureLayerId');
        await controller?.removeSource('singleFeatureSourceId');
      } else if (index == 4) {
        // Remove 3D Building Layer and Source
        await controller?.removeLayer('3dLayerId');
        await controller?.removeSource('3dSourceId');
      } else if (index == 5) {
        // Remove Hillshade Layer and Source
        await controller?.removeLayer('hillShadeLayerId');
        await controller?.removeSource('hillShadeSourceId');
      } else if (index == 6) {
        // Remove/Reset Updated Source (GeoJson)
        await controller?.removeSource('sourceId');
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
      action();
    }
  }

  @override
  Widget buildMapWithControls() {
    final buttons = [
      _LayerActionButton(
        icon: Icons.circle,
        label: "Add Circle",
        selected: _selectedIndex == 0,
        onPressed: () => _onAction(0, _addCircleLayer),
      ),
      _LayerActionButton(
        icon: Icons.timeline,
        label: "Add Line",
        selected: _selectedIndex == 1,
        onPressed: () => _onAction(1, _addLineLayer),
      ),
      _LayerActionButton(
        icon: Icons.format_color_fill,
        label: "Add Fill",
        selected: _selectedIndex == 2,
        onPressed: () => _onAction(2, _addFillLayer),
      ),
      _LayerActionButton(
        icon: Icons.add_location_alt,
        label: "Add Point",
        selected: _selectedIndex == 3,
        onPressed: () => _onAction(3, _addPointLayerFromFeature),
      ),
      _LayerActionButton(
        icon: Icons.location_city,
        label: "3D Building",
        selected: _selectedIndex == 4,
        onPressed: () => _onAction(4, _add3dBuilding),
      ),
      _LayerActionButton(
        icon: Icons.terrain,
        label: "Hillshade",
        selected: _selectedIndex == 5,
        onPressed: () => _onAction(5, _addHillShadeLayer),
      ),
      _LayerActionButton(
        icon: Icons.update,
        label: "Update Source",
        selected: _selectedIndex == 6,
        onPressed: () => _onAction(6, _updateGeoJsonUrl),
      ),
    ];
    return Stack(
      children: [
        buildBaseMap(),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(mainAxisSize: MainAxisSize.min, children: buttons),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _addCircleLayer() async {
    await controller?.addSource<GeoJsonSource>(
      source: GeoJsonSource(
        sourceId: "sourceId",
        url:
            "https://d2ad6b4ur7yvpq.cloudfront.net/naturalearth-3.3.0/ne_50m_populated_places.geojson",
        sourceProperties: GeoJsonSourceProperties(cluster: true),
      ),
    );

    await controller?.addStyleImage(
      image: NetworkStyleImage(
        imageId: 'test_icon',
        url:
            'https://www.pngplay.com/wp-content/uploads/9/Map-Marker-PNG-Pic-Background.png',
      ),
    );

    await controller?.addLayer<CircleLayer>(
      layer: CircleLayer(
        layerId: "layerId",
        sourceId: "sourceId",
        layerProperties: CircleLayerProperties(
          circleColor: [
            'case',
            [
              '!',
              ['has', 'point_count'],
            ],
            'blue',
            'red',
          ],
          circleRadius: [
            'case',
            [
              '!',
              ['has', 'point_count'],
            ],
            12,
            14,
          ],
          circleRadiusTransition: StyleTransition.build(
            delay: 1500,
            duration: const Duration(milliseconds: 2000),
          ),
          circleColorTransition: StyleTransition.build(
            delay: 1500,
            duration: const Duration(milliseconds: 2000),
          ),
          circleStrokeWidth: 2.0,
          circleStrokeColor: "white",
        ),
      ),
    );

    await controller?.addLayer<SymbolLayer>(
      layer: SymbolLayer(
        layerId: "symbolLayerId",
        sourceId: "sourceId",
        layerProperties: SymbolLayerProperties(
          textColor: "yellow",
          textField: ['get', 'point_count_abbreviated'],
          textSize: 10,
          iconImage: [
            'case',
            [
              '!',
              ['has', 'point_count'],
            ],
            'test_icon',
            '',
          ],
          iconSize: Platform.isIOS ? 0.035 : 0.075,
          iconColor: "#fff",
        ),
      ),
    );

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.hideCurrentSnackBar();
    Flushbar(
      messageText: const Text(
        'Circle layer added',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.white.withOpacity(0.95),
      margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
      borderRadius: BorderRadius.circular(12),
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  Future<void> _addPointLayerFromFeature() async {
    await controller?.addSource<GeoJsonSource>(
      source: GeoJsonSource(
        sourceId: "singleFeatureSourceId",
        geoJson: GeoJson.fromFeature(
          Feature.fromGeometry(
            Geometry.point(coordinates: [85.331033, 27.741712]),
            id: "1",
            properties: {"name": "Amit"},
          ),
        ),
        sourceProperties: GeoJsonSourceProperties(cluster: false),
      ),
    );

    await controller?.addLayer<CircleLayer>(
      layer: CircleLayer(
        layerId: "singleFeatureLayerId",
        sourceId: "singleFeatureSourceId",
        layerProperties: CircleLayerProperties(
          circleColor: 'yellow',
          circleStrokeWidth: 2.0,
          circleStrokeColor: "white",
          circleRadius: 12.0,
          circleRadiusTransition: StyleTransition.build(
            delay: 1500,
            duration: const Duration(milliseconds: 2000),
          ),
          circleColorTransition: StyleTransition.build(
            delay: 1500,
            duration: const Duration(milliseconds: 2000),
          ),
        ),
      ),
    );

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.hideCurrentSnackBar();
    Flushbar(
      messageText: const Text(
        'Point added',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.white.withOpacity(0.95),
      margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
      borderRadius: BorderRadius.circular(12),
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  Future<void> _addLineLayer() async {
    if ((await controller?.isLayerExist('lineLayerId')) == true) {
      await controller?.removeLayer('lineLayerId');
    }

    if ((await controller?.isSourceExist('lineSourceId')) == true) {
      await controller?.removeSource('lineSourceId');
    }

    await controller?.addSource<GeoJsonSource>(
      source: GeoJsonSource(
        sourceId: "lineSourceId",
        url:
            "https://d2ad6b4ur7yvpq.cloudfront.net/naturalearth-3.3.0/ne_10m_rivers_europe.geojson",
      ),
    );

    await controller?.addLayerBelow<LineLayer>(
      layer: LineLayer(
        layerId: "lineLayerId",
        sourceId: "lineSourceId",
        layerProperties: LineLayerProperties(
          lineColor: "red",
          lineWidth: 2,
          lineGradient: [
            'interpolate',
            ['linear'],
            ['line-progress'],
            0,
            'blue',
            0.1,
            'royalblue',
            0.3,
            'cyan',
            0.5,
            'lime',
            0.7,
            'yellow',
            1,
            'red',
          ],
        ),
      ),
      below: "fillLayerId",
    );

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.hideCurrentSnackBar();
    Flushbar(
      messageText: const Text(
        'Line layer added',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.white.withOpacity(0.95),
      margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
      borderRadius: BorderRadius.circular(12),
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  Future<void> _addFillLayer() async {
    if ((await controller?.isLayerExist('fillLayerId')) == true) {
      await controller?.removeLayer('fillLayerId');
    }

    if ((await controller?.isSourceExist('fillSourceId')) == true) {
      await controller?.removeSource('fillSourceId');
    }

    await controller?.addSource<GeoJsonSource>(
      source: GeoJsonSource(
        sourceId: "fillSourceId",
        url:
            "https://d2ad6b4ur7yvpq.cloudfront.net/naturalearth-3.3.0/ne_50m_admin_0_map_subunits.geojson",
      ),
    );

    await controller?.addLayer<FillLayer>(
      layer: FillLayer(
        layerId: "fillLayerId",
        sourceId: "fillSourceId",
        layerProperties: FillLayerProperties(
          fillColor: "red",
          fillOpacity: 0.15,
          fillOutlineColor: "red",
        ),
      ),
    );

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.hideCurrentSnackBar();
    Flushbar(
      messageText: const Text(
        'Fill layer added',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.white.withOpacity(0.95),
      margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
      borderRadius: BorderRadius.circular(12),
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  Future<void> _add3dBuilding() async {
    await controller?.animateCamera(
      CameraUpdateFactory.newCameraPosition(
        CameraPosition(
          target: LatLng(41.86625, -87.61694),
          zoom: 15.0,
          tilt: 40.0,
          bearing: 20.0,
        ),
      ),
    );
    await controller?.addSource<GeoJsonSource>(
      source: GeoJsonSource(
        sourceId: "3dSourceId",
        url:
            "https://maplibre.org/maplibre-gl-js/docs/assets/indoor-3d-map.geojson",
      ),
    );

    await controller?.addLayer<FillExtrusionLayer>(
      layer: FillExtrusionLayer(
        layerId: "3dLayerId",
        sourceId: "3dSourceId",
        layerProperties: FillExtrusionLayerProperties(
          fillExtrusionColor: ['get', 'color'],
          fillExtrusionHeight: ['get', 'height'],
          fillExtrusionBase: ['get', 'base_height'],
          fillExtrusionOpacity: 0.6,
        ),
      ),
    );

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.hideCurrentSnackBar();
    Flushbar(
      messageText: const Text(
        '3D building added',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.white.withOpacity(0.95),
      margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
      borderRadius: BorderRadius.circular(12),
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  Future<void> _addHillShadeLayer() async {
    await controller?.animateCamera(
      CameraUpdateFactory.newCameraPosition(
        CameraPosition(
          target: LatLng(47.27574, 11.39085),
          zoom: 10.0,
          tilt: 40.0,
        ),
      ),
    );
    await controller?.addSource<RasterDemSource>(
      source: RasterDemSource(
        sourceId: "hillShadeSourceId",
        url: "https://demotiles.maplibre.org/terrain-tiles/tiles.json",
        sourceProperties: RasterDemSourceProperties(
          tileSize: 256,
          encoding: Encoding.mapbox,
        ),
      ),
    );

    await controller?.addLayer<HillShadeLayer>(
      layer: HillShadeLayer(
        layerId: "hillShadeLayerId",
        sourceId: "hillShadeSourceId",
        layerProperties: HillShadeLayerProperties(hillShadeShadowColor: 'grey'),
      ),
    );

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.hideCurrentSnackBar();
    Flushbar(
      messageText: const Text(
        'Hill shade layer added',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.white.withOpacity(0.95),
      margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
      borderRadius: BorderRadius.circular(12),
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  Future<void> _updateGeoJsonUrl() async {
    await controller?.setGeoJsonUrl(
      sourceId: "sourceId",
      geoJsonUrl:
          "https://d2ad6b4ur7yvpq.cloudfront.net/naturalearth-3.3.0/ne_10m_ports.geojson",
    );

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.hideCurrentSnackBar();
    Flushbar(
      messageText: const Text(
        'GeoJson source url updated',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.white.withOpacity(0.95),
      margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
      borderRadius: BorderRadius.circular(12),
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }
}

/// Compact icon+label button for layer actions.
class _LayerActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  const _LayerActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Material(
        color:
            selected
                ? Colors.white.withOpacity(0.25)
                : Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(32),
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color:
                      selected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color:
                        selected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
