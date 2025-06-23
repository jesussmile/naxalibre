import 'package:flutter/material.dart';
import 'package:naxalibre_example/views/features/annotations_management/annotations_management_screen.dart';
import 'package:naxalibre_example/views/features/offline_management/offline_management_screen.dart';
import 'package:naxalibre_example/views/features/image_overlay/image_overlay_screen.dart';
import 'dart:ui';

import '../basic_map_controls/basic_map_controls_screen.dart';
import '../camera_animations/camera_animations_screen.dart';
import '../layers_management/layer_management_screen.dart';
import '../location_features/location_features_screen.dart';
import '../map_performance/map_performance_screen.dart';
import '../map_utilities/map_utilities_screen.dart';
import '../interactive_markers/interactive_markers_screen.dart';
import '../mbtiles_loader/mbtiles_loader_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF23242B),
        elevation: 0,
        title: const Text(
          'NaxaLibre Features',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ModernFeatureCard(
            title: 'Basic Map Controls',
            description: 'Zoom in/out, toggle style, and camera animations',
            icon: Icons.map_outlined,
            iconColor: Colors.blueAccent,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BasicMapControlsScreen(),
                  ),
                ),
          ),
          _ModernFeatureCard(
            title: 'Image Overlay',
            description: 'Add and manage image overlays on the map',
            icon: Icons.image_outlined,
            iconColor: Colors.pinkAccent,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ImageOverlayScreen()),
                ),
          ),
          _ModernFeatureCard(
            title: 'Camera Animations',
            description: 'Various camera animation techniques',
            icon: Icons.animation,
            iconColor: Colors.purpleAccent,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CameraAnimationsScreen(),
                  ),
                ),
          ),
          _ModernFeatureCard(
            title: 'Layer Management',
            description: 'Add and manage different map layers',
            icon: Icons.layers_outlined,
            iconColor: Colors.tealAccent,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LayerManagementScreen(),
                  ),
                ),
          ),
          _ModernFeatureCard(
            title: 'Interactive Markers',
            description: 'Add, tap, and drag markers on the map',
            icon: Icons.place_outlined,
            iconColor: Colors.amberAccent,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InteractiveMarkersScreen(),
                  ),
                ),
          ),
          _ModernFeatureCard(
            title: 'Annotation Management',
            description: 'Add and manage different map annotations',
            icon: Icons.control_point_duplicate,
            iconColor: Colors.orangeAccent,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AnnotationsManagementScreen(),
                  ),
                ),
          ),
          _ModernFeatureCard(
            title: 'Location Features',
            description: 'Location tracking and services',
            icon: Icons.share_location_outlined,
            iconColor: Colors.greenAccent,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LocationFeaturesScreen(),
                  ),
                ),
          ),
          _ModernFeatureCard(
            title: 'Map Performance',
            description: 'FPS settings and optimization',
            icon: Icons.speed,
            iconColor: Colors.redAccent,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MapPerformanceScreen(),
                  ),
                ),
          ),
          _ModernFeatureCard(
            title: 'Map Utilities',
            description: 'Snapshot, JSON export, and other utilities',
            icon: Icons.build_circle_outlined,
            iconColor: Colors.cyanAccent,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MapUtilitiesScreen()),
                ),
          ),
          _ModernFeatureCard(
            title: 'Offline Management',
            description: 'Offline region downloading and management',
            icon: Icons.download_for_offline_outlined,
            iconColor: Colors.yellowAccent,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OfflineManagementScreen(),
                  ),
                ),
          ),
          _ModernFeatureCard(
            title: 'MBTiles Loader',
            description: 'Load and display MBTiles from local assets',
            icon: Icons.map_outlined,
            iconColor: Colors.lightGreenAccent,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MBTilesLoaderScreen(),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _ModernFeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _ModernFeatureCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 32),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white54,
                  size: 20,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
