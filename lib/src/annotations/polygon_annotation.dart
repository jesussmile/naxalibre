part of 'annotation.dart';

/// The `PolygonAnnotation` class represents a polygon annotation,
/// which is a filled geometric shape that can be rendered on the map.
///
/// This class extends the `Annotation` class and uses
/// `PolygonAnnotationOptions` to define the properties of the polygon annotation.
///
class PolygonAnnotation extends Annotation<PolygonAnnotationOptions> {
  /// Type of the annotation
  ///
  @override
  String get type => "Polygon";

  /// Constructs a `PolygonAnnotation` instance.
  ///
  /// [options] is required and defines the properties of the polygon annotation,
  /// such as the points that form the polygon, its fill color, stroke color, and other style properties.
  PolygonAnnotation({required super.options});

  /// Converts the `PolygonAnnotation` object to a map representation.
  ///
  /// This method prepares the annotation data in a format suitable
  /// for passing to the native platform through the `args` parameter.
  ///
  /// Returns:
  /// - A json map containing the annotation options.
  @override
  Map<String, dynamic> toArgs() {
    return <String, dynamic>{
      "type": type,
      "options": options.toArgs(),
    };
  }
}

/// PolygonAnnotationOptions class
/// It contains all the properties for the polygon annotation
/// e.g.
/// final polygonAnnotationOptions = PolygonAnnotationOptions(
///           points: [[[LatLng(27.34, 85.43), LatLng(27.4, 85.5)]]],
///           fillColor: "#ef2d3f",
/// );
class PolygonAnnotationOptions extends AnnotationOptions {
  /// Set a list of lists of Point for the fill, which represents
  /// the locations of the fill on the map
  /// Accepted data type:
  /// - List of List of LatLng
  final List<List<LatLng>> points;

  /// The color of the filled part of this layer. This color can be specified
  /// as rgba with an alpha component and the color's opacity will not affect
  /// the opacity of the 1px stroke, if it is used.
  /// Accepted data type:
  /// - String,
  /// - Int and
  /// - Expression
  /// default value is '#000000'
  final dynamic fillColor;

  /// StyleTransition for fill color
  /// Accepted data type:
  /// - StyleTransition
  final StyleTransition? fillColorTransition;

  /// Whether or not the fill should be antialiasing.
  /// Accepted data type:
  /// - Boolean and
  /// - Expression
  /// default value is true
  final dynamic fillAntialias;

  /// The opacity of the entire fill layer.
  /// In contrast to the fill-color, this value will also affect the
  /// 1px stroke around the fill, if the stroke is used.
  /// Accepted data type:
  /// - Double and
  /// - Expression
  /// default value is 1.0
  final dynamic fillOpacity;

  /// StyleTransition for fill opacity
  /// Accepted data type:
  /// - StyleTransition
  final StyleTransition? fillOpacityTransition;

  /// The outline color of the fill. Matches the value of fill-color if unspecified.
  /// Accepted data type:
  /// - String,
  /// - Int and
  /// - Expression
  final dynamic fillOutlineColor;

  /// StyleTransition for fillOutlineColor
  /// Accepted data type:
  /// - StyleTransition
  final StyleTransition? fillOutlineColorTransition;

  /// Name of image in sprite to use for drawing image fills.
  /// For seamless patterns, image width and height must be a factor of
  /// two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will
  /// be evaluated only at integer zoom levels.
  /// Accepted data type:
  /// - String and
  /// - Expression
  final dynamic fillPattern;

  /// StyleTransition for fill pattern
  /// Accepted data type:
  /// - StyleTransition
  final StyleTransition? fillPatternTransition;

  /// Sorts features in ascending order based on this value. Features with
  /// a higher sort key will appear above features with a lower sort key.
  /// Accepted data type:
  /// - Double and
  /// - Expression
  final dynamic fillSortKey;

  /// Set whether this circleAnnotation should be draggable, meaning it can be
  /// dragged across the screen when touched and moved.
  /// Accepted data type - bool
  /// default value is false
  final bool draggable;

  /// Set the arbitrary json data of the annotation.
  /// Accepted data type - map of string - dynamic
  /// default value is empty map
  final Map<String, dynamic>? data;

  PolygonAnnotationOptions({
    required this.points,
    this.fillColor,
    this.fillColorTransition,
    this.fillAntialias,
    this.fillOpacity,
    this.fillOpacityTransition,
    this.fillOutlineColor,
    this.fillOutlineColorTransition,
    this.fillPattern,
    this.fillPatternTransition,
    this.fillSortKey,
    this.draggable = false,
    this.data,
  });

  /// Converts the properties of the FillLayer into a map format.
  @override
  Map<String, dynamic>? toArgs() {
    final args = <String, dynamic>{};

    // Adding points
    args['points'] =
        points.map((point) => point.map((p) => p.toArgs()).toList()).toList();

    // Adding draggable
    args['draggable'] = draggable;

    // Adding data
    if (data != null) {
      args['data'] = data;
    }

    // Layout properties
    final layoutArgs = _fillLayoutArgs();
    args['layout'] = layoutArgs;

    // Paint properties
    final paintArgs = _fillPaintArgs();
    args['paint'] = paintArgs;

    // Transition properties
    final transitionsArgs = _fillTransitionsArgs();
    args['transition'] = transitionsArgs;

    return args.isNotEmpty ? args : null;
  }

  /// Method to create layout properties
  ///
  Map<String, dynamic> _fillLayoutArgs() {
    final layoutArgs = <String, dynamic>{};

    void insert(String key, dynamic value) {
      if (value != null) {
        layoutArgs[key] = value is List ? jsonEncode(value) : value;
      }
    }

    insert('fill-sort-key', fillSortKey);

    return layoutArgs;
  }

  /// Method to create paint properties
  ///
  Map<String, dynamic> _fillPaintArgs() {
    final paintArgs = <String, dynamic>{};

    void insert(String key, dynamic value) {
      if (value != null) {
        paintArgs[key] = value is List ? jsonEncode(value) : value;
      }
    }

    insert('fill-color', fillColor);
    insert('fill-antialias', fillAntialias);
    insert('fill-opacity', fillOpacity);
    insert('fill-outline-color', fillOutlineColor);
    insert('fill-pattern', fillPattern);

    return paintArgs;
  }

  /// Method to create transitions properties
  ///
  Map<String, dynamic> _fillTransitionsArgs() {
    final transitionsArgs = <String, dynamic>{};

    void insert(String key, dynamic transition) {
      if (transition != null) {
        transitionsArgs[key] = transition.toArgs();
      }
    }

    insert('fill-pattern-transition', fillPatternTransition);
    insert('fill-outline-color-transition', fillOutlineColorTransition);
    insert('fill-opacity-transition', fillOpacityTransition);
    insert('fill-color-transition', fillColorTransition);

    return transitionsArgs;
  }
}
