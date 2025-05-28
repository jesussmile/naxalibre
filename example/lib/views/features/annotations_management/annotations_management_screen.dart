import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:naxalibre/naxalibre.dart';
import 'package:another_flushbar/flushbar.dart';

import '../base_map/base_map_screen.dart';
import 'widgets/annotation_button.dart';

// 7. Annotations Management Screen
class AnnotationsManagementScreen extends BaseMapScreen {
  const AnnotationsManagementScreen({super.key})
    : super(title: 'Annotation Management');

  @override
  State<AnnotationsManagementScreen> createState() =>
      _LayerManagementScreenState();
}

class _LayerManagementScreenState
    extends BaseMapScreenState<AnnotationsManagementScreen> {
  int? _circleAnnotationId;
  int? _polylineAnnotationId;
  int? _polygonAnnotationId;
  int? _pointAnnotationId;

  void _showFlushbar(String message) {
    Flushbar(
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Colors.white.withOpacity(0.95),
      margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
      borderRadius: BorderRadius.circular(12),
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  @override
  Widget buildMapWithControls() {
    return SizedBox.expand(
      child: Stack(
        children: [
          buildBaseMap(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.18),
                  width: 1.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnnotationButton(
                    label: "Circle",
                    icon: Icons.circle,
                    iconColor: Colors.pinkAccent,
                    onPressed: () => _toggleCircleAnnotation(),
                  ),
                  AnnotationButton(
                    label: "Polyline",
                    icon: Icons.polyline,
                    iconColor: Colors.lightBlueAccent,
                    onPressed: () => _togglePolylineAnnotation(),
                  ),
                  AnnotationButton(
                    label: "Polygon",
                    icon: Icons.hexagon_outlined,
                    iconColor: Colors.amberAccent,
                    onPressed: () => _togglePolygonAnnotation(),
                  ),
                  AnnotationButton(
                    label: "Point",
                    icon: Icons.location_on_rounded,
                    iconColor: Colors.greenAccent,
                    onPressed: () => _togglePointAnnotation(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleCircleAnnotation() async {
    if (_circleAnnotationId != null) {
      await controller?.removeAnnotation<CircleAnnotation>(
        _circleAnnotationId!,
      );
      _showFlushbar('Circle annotation removed');
      setState(() => _circleAnnotationId = null);
      return;
    }
    await controller?.animateCamera(
      CameraUpdateFactory.newCameraPosition(
        CameraPosition(target: LatLng(27.741712, 85.331033), zoom: 15),
      ),
    );
    final result = await controller?.addAnnotation<CircleAnnotation>(
      annotation: CircleAnnotation(
        options: CircleAnnotationOptions(
          point: LatLng(27.741712, 85.331033),
          circleColor: "red",
          circleStrokeColor: "white",
          circleStrokeWidth: 2.0,
          circleRadius: 12.0,
          circleRadiusTransition: StyleTransition.build(
            delay: 1500,
            duration: const Duration(milliseconds: 2000),
          ),
          circleColorTransition: StyleTransition.build(
            delay: 1500,
            duration: const Duration(milliseconds: 2000),
          ),
          data: {
            "name": "Circle Annotation",
            "description": "This is a circle annotation",
            "taskId": 11,
          },
          draggable: true,
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _circleAnnotationId = result?["id"] as int?);
    _showFlushbar('Circle annotation added');
  }

  Future<void> _togglePolylineAnnotation() async {
    if (_polylineAnnotationId != null) {
      await controller?.removeAnnotation<PolylineAnnotation>(
        _polylineAnnotationId!,
      );
      _showFlushbar('Polyline annotation removed');
      setState(() => _polylineAnnotationId = null);
      return;
    }
    await controller?.animateCamera(
      CameraUpdateFactory.newCameraPosition(
        CameraPosition(target: LatLng(27.741712, 85.331033), zoom: 15),
      ),
    );
    final result = await controller?.addAnnotation<PolylineAnnotation>(
      annotation: PolylineAnnotation(
        options: PolylineAnnotationOptions(
          points: [LatLng(27.741712, 85.331033), LatLng(27.7420, 85.3412)],
          lineColor: "red",
          lineWidth: 3.75,
          lineCap: LineCap.round,
          lineJoin: LineJoin.round,
          draggable: true,
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _polylineAnnotationId = result?["id"] as int?);
    _showFlushbar('Polyline annotation added');
  }

  Future<void> _togglePolygonAnnotation() async {
    if (_polygonAnnotationId != null) {
      await controller?.removeAnnotation<PolygonAnnotation>(
        _polygonAnnotationId!,
      );
      _showFlushbar('Polygon annotation removed');
      setState(() => _polygonAnnotationId = null);
      return;
    }
    final result = await controller?.addAnnotation<PolygonAnnotation>(
      annotation: PolygonAnnotation(
        options: PolygonAnnotationOptions(
          points: [
            [
              LatLng(27.741712, 85.331033),
              LatLng(27.7420, 85.3412),
              LatLng(27.7525, 85.3578),
            ],
          ],
          fillColor: "red",
          fillOpacity: 0.15,
          fillOutlineColor: "blue",
          draggable: true,
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _polygonAnnotationId = result?["id"] as int?);
    _showFlushbar('Polygon annotation added');
  }

  Future<void> _togglePointAnnotation() async {
    if (_pointAnnotationId != null) {
      await controller?.removeAnnotation<PointAnnotation>(_pointAnnotationId!);
      _showFlushbar('Point annotation removed');
      setState(() => _pointAnnotationId = null);
      return;
    }
    final result = await controller?.addAnnotation<PointAnnotation>(
      annotation: PointAnnotation(
        image: NetworkStyleImage(
          imageId: "pointImageId",
          url:
              "https://www.cp-desk.com/wp-content/uploads/2019/02/map-marker-free-download-png.png",
        ),
        options: PointAnnotationOptions(
          point: LatLng(27.7525, 85.3578),
          iconSize: 0.1,
          draggable: true,
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _pointAnnotationId = result?["id"] as int?);
    _showFlushbar('Point annotation added');
  }
}
