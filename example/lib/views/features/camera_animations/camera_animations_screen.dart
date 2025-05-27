import 'package:flutter/material.dart';
import 'package:naxalibre/naxalibre.dart';

import '../base_map/base_map_screen.dart';
import 'widgets/animation_button.dart';

// 2. Camera Animations Screen
class CameraAnimationsScreen extends BaseMapScreen {
  const CameraAnimationsScreen({super.key}) : super(title: 'Camera Animations');

  @override
  State<CameraAnimationsScreen> createState() => _CameraAnimationsScreenState();
}

class _CameraAnimationsScreenState
    extends BaseMapScreenState<CameraAnimationsScreen> {
  @override
  Widget buildMapWithControls() {
    final buttons = [
      _SideLabeledButton(
        icon: Icons.place,
        label: "To New LatLng",
        onPressed: () {
          controller?.animateCamera(
            CameraUpdateFactory.newLatLng(const LatLng(27.34, 85.73)),
            duration: const Duration(milliseconds: 5000),
          );
        },
      ),
      _SideLabeledButton(
        icon: Icons.camera,
        label: "To Camera Position",
        onPressed: () {
          controller?.animateCamera(
            CameraUpdateFactory.newCameraPosition(
              const CameraPosition(
                target: LatLng(27.38, 85.75),
                zoom: 16,
                bearing: 0,
                tilt: 0,
              ),
            ),
            duration: const Duration(milliseconds: 5000),
          );
        },
      ),
      _SideLabeledButton(
        icon: Icons.crop_free,
        label: "To LatLng Bounds",
        onPressed: () {
          controller?.animateCamera(
            CameraUpdateFactory.newLatLngBounds(
              const LatLngBounds(
                southwest: LatLng(27.34, 85.73),
                northeast: LatLng(27.35, 85.74),
              ),
              tilt: 5,
              padding: EdgeInsets.all(50),
              bearing: 90,
            ),
            duration: const Duration(milliseconds: 5000),
          );
        },
      ),
      _SideLabeledButton(
        icon: Icons.my_location,
        label: "To Current Location",
        onPressed: () {
          controller?.animateCameraToCurrentLocation(
            duration: const Duration(milliseconds: 5000),
          );
        },
      ),
      _SideLabeledButton(
        icon: Icons.zoom_in,
        label: "Zoom To 10",
        onPressed: () {
          controller?.animateCamera(
            CameraUpdateFactory.zoomTo(10),
            duration: const Duration(milliseconds: 5000),
          );
        },
      ),
      _SideLabeledButton(
        icon: Icons.add_circle_outline,
        label: "Zoom By +2",
        onPressed: () {
          controller?.animateCamera(
            CameraUpdateFactory.zoomBy(2),
            duration: const Duration(milliseconds: 5000),
          );
        },
      ),
      _SideLabeledButton(
        icon: Icons.remove_circle_outline,
        label: "Zoom By -2",
        onPressed: () {
          controller?.animateCamera(
            CameraUpdateFactory.zoomBy(-2),
            duration: const Duration(milliseconds: 5000),
          );
        },
      ),
    ];
    final firstRow = buttons.sublist(0, (buttons.length / 2).ceil());
    final secondRow = buttons.sublist((buttons.length / 2).ceil());
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: firstRow,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: secondRow,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A compact icon+label button for the side panel.
class _SideLabeledButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SideLabeledButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: Material(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(32),
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
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
