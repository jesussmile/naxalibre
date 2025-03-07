part of 'annotation.dart';

/// The `PolylineAnnotation` class represents a polyline annotation,
/// which is a line feature that can be rendered on the map.
///
/// This class extends the `Annotation` class and uses
/// `PolylineAnnotationOptions` to specify the properties of the polyline annotation.
///
class PolylineAnnotation extends Annotation<PolylineAnnotationOptions> {
  /// Type of the annotation
  ///
  @override
  String get type => "Polyline";

  /// Constructs a `PolylineAnnotation` instance.
  ///
  /// [annotationOptions] is required and defines the properties of the polyline annotation,
  /// such as the points that form the polyline, its color, width, and other style properties.
  PolylineAnnotation({required super.annotationOptions});

  /// Converts the `PolylineAnnotation` object to a map representation.
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
      "annotationOptions": annotationOptions.toArgs(),
    };
  }
}

/// PolylineAnnotationOptions class
/// It contains all the properties for the polygon annotation
/// e.g.
/// final polylineAnnotationOptions = PolylineAnnotationOptions(
///                points: [[ LatLng(27.34, 85.43), LatLng(27.4, 85.5)]],
///                fillColor: "#ef2d3f",
///  );
class PolylineAnnotationOptions extends AnnotationOptions {
  /// Set a list of Point for the line, which represents the locations of
  /// the line on the map
  /// Accepted data type:
  /// - List of latLng
  final List<LatLng> points;

  /// Stroke thickness.
  /// Accepted data type:
  /// - Double and
  /// - Expression
  /// default value is 1.0
  final dynamic lineWidth;

  /// StyleTransition for line width
  /// Accepted data type:
  /// - StyleTransition
  final StyleTransition? lineWidthTransition;

  /// The color with which the line will be drawn.
  /// Accepted data type:
  /// - String,
  /// - int and
  /// - Expression
  /// default value is '#000000'
  final dynamic lineColor;

  /// StyleTransition for line color
  /// Accepted data type:
  /// - StyleTransition
  final StyleTransition? lineColorTransition;

  /// Blur applied to the line, in pixels.
  /// Accepted data type:
  /// - double and
  /// - Expression
  /// default value is 0.0
  final dynamic lineBlur;

  /// StyleTransition for line blur
  /// Accepted data type:
  /// - StyleTransition
  final StyleTransition? lineBlurTransition;

  /// Specifies the lengths of the alternating dashes and gaps that form
  /// the dash pattern. The lengths are later scaled by the line width.
  /// To convert a dash length to pixels, multiply the length by the current
  /// line width. Note that GeoJSON sources with lineMetrics: true specified
  /// won't render dashed lines to the expected scale. Also note that
  /// zoom-dependent expressions will be evaluated only at integer zoom levels.
  /// Accepted data type:
  /// - List of Double and
  /// - Expression
  final dynamic lineDashArray;

  /// StyleTransition for dash array
  /// Accepted data type:
  /// - StyleTransition
  final StyleTransition? lineDashArrayTransition;

  /// Draws a line casing outside of a line's actual path. Value indicates
  /// the width of the inner gap.
  /// Accepted data type:
  /// - double and
  /// - Expression
  /// default value is 0.0
  final dynamic lineGapWidth;

  /// StyleTransition for line gap width
  /// Accepted data type:
  /// - StyleTransition
  final StyleTransition? lineGapWidthTransition;

  /// Expression
  /// e.g.
  ///   [
  ///    'interpolate',
  ///    ['linear'],
  ///    ['line-progress'],
  ///     0,
  ///    'blue',
  ///     0.1,
  ///    'green',
  ///     0.3,
  ///    'cyan',
  ///     0.5,
  ///    'lime',
  ///     0.7,
  ///    'yellow',
  ///     1,
  ///    'red'
  ///  ]
  ///
  final dynamic lineGradient;

  /// Used to automatically convert miter joins to bevel joins for sharp angles.
  /// Accepted data type:
  /// - double and
  /// - Expression
  /// default value is 2.0
  final dynamic lineMiterLimit;

  /// The line's offset. For linear features, a positive value offsets
  /// the line to the right, relative to the direction of the line, and
  /// a negative value to the left. For polygon features, a positive value
  /// results in an inset, and a negative value results in an outset.
  /// Accepted data type:
  /// - double and
  /// - Expression
  /// default value is 0.0
  final dynamic lineOffset;

  /// StyleTransition for line offset
  /// Accepted data type:
  /// - StyleTransition
  final StyleTransition? lineOffsetTransition;

  /// The opacity at which the line will be drawn.
  /// Accepted data type:
  /// - double and
  /// - Expression
  /// default value is 1.0
  final dynamic lineOpacity;

  /// StyleTransition for line opacity
  /// Accepted data type:
  /// - StyleTransition
  final StyleTransition? lineOpacityTransition;

  /// Name of image in sprite to use for drawing image lines.
  /// For seamless patterns, image width must be a factor of two
  /// (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be
  /// evaluated only at integer zoom levels.
  /// Accepted data type:
  /// - String and
  /// - Expression
  final dynamic linePattern;

  /// StyleTransition for linePattern
  /// Accepted data type:
  /// - StyleTransition
  final StyleTransition? linePatternTransition;

  /// Used to automatically convert round joins to miter joins
  /// for shallow angles.
  /// Accepted data type:
  /// - Double and
  /// - Expression
  /// default value is 1.05
  final dynamic lineRoundLimit;

  /// Sorts features in ascending order based on this value. Features with
  /// a higher sort key will appear above features with a lower sort key.
  /// Accepted data type:
  /// - Double and
  /// - Expression
  final dynamic lineSortKey;

  /// The display of line endings.
  /// Accepted data type:
  /// - LineCap and
  /// - Expression
  /// default value is LineCap.butt
  final dynamic lineCap;

  /// The display of lines when joining.
  /// Accepted data type:
  /// - LineJoin and
  /// - Expression
  /// default value is LineJoin.miter
  final dynamic lineJoin;

  /// Whether this line is draggable or not.
  /// Accepted data type - bool
  /// default value is false
  final bool draggable;

  /// Set the arbitrary json data of the annotation.
  /// Accepted data type - map of string - dynamic
  /// default value is empty map
  final Map<String, dynamic>? data;

  /// Constructor
  PolylineAnnotationOptions({
    required this.points,
    this.lineWidth,
    this.lineWidthTransition,
    this.lineColor,
    this.lineColorTransition,
    this.lineBlur,
    this.lineBlurTransition,
    this.lineDashArray,
    this.lineDashArrayTransition,
    this.lineGapWidth,
    this.lineGapWidthTransition,
    this.lineGradient,
    this.lineMiterLimit,
    this.lineOffset,
    this.lineOffsetTransition,
    this.lineOpacity,
    this.lineOpacityTransition,
    this.linePattern,
    this.linePatternTransition,
    this.lineRoundLimit,
    this.lineSortKey,
    this.lineCap,
    this.lineJoin,
    this.draggable = false,
    this.data,
  });

  /// Method to proceeds the polyline annotation properties
  ///
  @override
  Map<String, dynamic>? toArgs() {
    final args = <String, dynamic>{};

    // Adding points
    args['points'] = points.map((point) => point.toArgs()).toList();

    // Adding draggable
    args['draggable'] = draggable;

    // Adding data
    if (data != null) {
      args['data'] = data;
    }

    // Layout properties
    final layoutArgs = _lineLayoutArgs();
    args['layout'] = layoutArgs;

    // Paint properties
    final paintArgs = _linePaintArgs();
    args['paint'] = paintArgs;

    // Transitions properties
    final transitionsArgs = _lineTransitionsArgs();
    args['transition'] = transitionsArgs;

    return args.isNotEmpty ? args : null;
  }

  /// Method to create layout properties
  ///
  Map<String, dynamic> _lineLayoutArgs() {
    final layoutArgs = <String, dynamic>{};

    void insert(String key, dynamic value) {
      if (value != null) {
        layoutArgs[key] = value is List ? jsonEncode(value) : value;
      }
    }

    insert('line-miter-limit', lineMiterLimit);
    insert('line-round-limit', lineRoundLimit);
    insert('line-sort-key', lineSortKey);

    if (lineCap != null && (lineCap is LineCap || lineCap is List)) {
      layoutArgs['line-cap'] =
          lineCap is LineCap
              ? (lineCap as LineCap).name
              : lineCap is List
              ? jsonEncode(lineCap)
              : lineCap;
    }

    if (lineJoin != null && (lineJoin is LineJoin || lineJoin is List)) {
      layoutArgs['line-join'] =
          lineJoin is LineJoin
              ? (lineJoin as LineJoin).name
              : lineJoin is List
              ? jsonEncode(lineJoin)
              : lineJoin;
    }

    return layoutArgs;
  }

  /// Method to create paint properties
  ///
  Map<String, dynamic> _linePaintArgs() {
    final paintArgs = <String, dynamic>{};

    void insert(String key, dynamic value) {
      if (value != null) {
        paintArgs[key] = value is List ? jsonEncode(value) : value;
      }
    }

    insert('line-width', lineWidth);
    insert('line-color', lineColor);
    insert('line-blur', lineBlur);
    insert('line-gap-width', lineGapWidth);
    insert('line-offset', lineOffset);
    insert('line-opacity', lineOpacity);
    insert('line-pattern', linePattern);

    if (lineDashArray != null) {
      paintArgs['line-dasharray'] =
          lineDashArray is List<double> ||
                  lineDashArray is List<int> ||
                  lineDashArray is List<num>
              ? lineDashArray
              : jsonEncode(lineDashArray);
    }

    if (lineGradient != null && lineGradient is List) {
      paintArgs['line-gradient'] = jsonEncode(lineGradient);
    }

    return paintArgs;
  }

  /// Method to create transitions properties
  ///
  Map<String, dynamic> _lineTransitionsArgs() {
    final transitionsArgs = <String, dynamic>{};

    void insert(String key, dynamic transition) {
      if (transition != null) {
        transitionsArgs[key] = transition.toArgs();
      }
    }

    insert('line-width-transition', lineWidthTransition);
    insert('line-color-transition', lineColorTransition);
    insert('line-blur-transition', lineBlurTransition);
    insert('line-dash-array-transition', lineDashArrayTransition);
    insert('line-gap-width-transition', lineGapWidthTransition);
    insert('line-offset-transition', lineOffsetTransition);
    insert('line-opacity-transition', lineOpacityTransition);
    insert('line-pattern-transition', linePatternTransition);

    return transitionsArgs;
  }
}
