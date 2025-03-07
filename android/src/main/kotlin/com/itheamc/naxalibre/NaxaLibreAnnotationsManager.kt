package com.itheamc.naxalibre

import android.app.Activity
import com.itheamc.naxalibre.parsers.AnnotationArgsParser
import io.flutter.plugin.common.BinaryMessenger
import org.maplibre.android.maps.MapLibreMap
import org.maplibre.android.maps.MapView
import org.maplibre.android.style.layers.CircleLayer
import org.maplibre.android.style.layers.FillLayer
import org.maplibre.android.style.layers.Layer
import org.maplibre.android.style.layers.LineLayer
import org.maplibre.android.style.layers.SymbolLayer
import org.maplibre.android.style.sources.GeoJsonSource
import org.maplibre.geojson.Geometry
import org.maplibre.geojson.LineString
import org.maplibre.geojson.Point
import org.maplibre.geojson.Polygon
import java.util.Locale

/**
 * Manages the creation, manipulation, and storage of annotations on a MapLibre map.
 *
 * This class acts as an intermediary between the Flutter application and the underlying
 * MapLibre map view, facilitating the addition of various types of annotations like circles,
 * polyline, polygons, and symbols. It handles the conversion of data from Flutter to
 * MapLibre-compatible objects and maintains a registry of all added annotations.
 *
 * @property binaryMessenger The binary messenger used for communication with the Flutter side.
 * @property activity The Android activity the map view is attached to.
 * @property libreView The MapLibre map view.
 * @property libreMap The MapLibre map instance.
 */
class NaxaLibreAnnotationsManager(
    private val binaryMessenger: BinaryMessenger,
    private val activity: Activity,
    private val libreView: MapView,
    private val libreMap: MapLibreMap,
) {

    /**
     * Represents the different types of annotations that can be drawn on a map or image.
     *
     * Each type defines a distinct visual representation and interaction behavior:
     *
     * - **CIRCLE:**  Represents a circular area on the map. Useful for highlighting a region or showing a radius.
     * - **POLYLINE:** Represents a connected series of line segments. Ideal for paths, routes, or boundaries.
     * - **POLYGON:** Represents a closed shape formed by connected line segments. Suitable for areas, regions, or buildings.
     * - **SYMBOL:** Represents a point marker with an associated icon or text label. Used for locations, points of interest, or icons.
     */
    enum class AnnotationType { Circle, Polyline, Polygon, Symbol }

    /**
     * Represents an annotation on a map, such as a marker, line, or polygon.
     *
     * An annotation consists of visual properties (paint), spatial properties (layout),
     * data associated with the annotation, and whether it can be dragged.
     *
     * @property id A unique identifier for the annotation.
     * @property type The type of the annotation (e.g., Marker, Line, Polygon).
     * @property layer The actual layer object representing the annotation on the map.
     *
     * @property data A map of arbitrary key-value pairs associated with the annotation.
     *               This can be used to store custom data relevant to the annotation.
     *               Defaults to an empty map.
     * @property draggable Whether the annotation can be dragged by the user. Defaults to `false`.
     */
    data class Annotation<T>(
        val id: Long,
        val type: AnnotationType,
        val layer: T,
        val geometry: Geometry? = null,
        val data: Map<String, Any?> = emptyMap(),
        val draggable: Boolean = false,
    ) where T : Layer

    /**
     * A list of annotations representing circles drawn on the map.
     *
     * Each [Annotation] in this list represents a single circle.
     * These annotations can be used to visualize areas of interest,
     * radius around a point, or any other circular region on the map.
     *
     * The list is mutable, meaning annotations can be added or removed dynamically.
     *
     */
    private val circleAnnotations: MutableList<Annotation<CircleLayer>> = mutableListOf()


    /**
     * A list of annotations that represent polylines drawn on the map.
     *
     * Each annotation in this list defines a polyline's visual representation, including:
     * - The points (coordinates) that make up the polyline.
     * - The stroke (line) color, width, and other drawing properties.
     * - Any associated metadata or identifiers.
     *
     * These annotations are typically used to visually highlight routes, boundaries,
     * or other linear features on a map. They are rendered as a sequence of connected
     * line segments.
     *
     */
    private val polylineAnnotations: MutableList<Annotation<LineLayer>> = mutableListOf()

    /**
     * A list of annotations representing polygons drawn on the map.
     *
     * Each [Annotation] in this list represents a single polygon.
     * These annotations are used to visualize closed areas on the map.
     *
     * Polygons are defined by a list of coordinates that form their boundaries.
     *
     */
    private val polygonAnnotations: MutableList<Annotation<FillLayer>> = mutableListOf()

    /**
     * A list of annotations representing symbols (markers, icons) placed on the map.
     *
     * Each [Annotation] in this list represents a single symbol.
     * These annotations are used to mark specific points of interest on the map.
     *
     * Symbols can be customized with various icons, text labels, and other visual properties.
     *
     */
    private val symbolAnnotations: MutableList<Annotation<SymbolLayer>> = mutableListOf()


    /**
     * Adds an annotation based on the provided arguments.
     *
     * This function takes a map of arguments and attempts to create an annotation of a specific type.
     * The "type" key in the map is used to determine the type of annotation.
     * The function currently checks for a valid annotation type and throws an exception if the provided type is valid.
     *
     * @param args A map containing the arguments for creating the annotation.
     *             It is expected to have a key "type" whose value is a string
     *             representing the desired annotation type.
     *             The string should match one of the values in the `AnnotationType` enum (case-insensitive).
     *
     * @throws Exception If the annotation type provided in the `args` map is valid.
     *                   This is currently intentional as the function logic expects an invalid type and throws an error when it is valid.
     *                   This behavior should be addressed in the future to properly add annotations.
     *
     * @throws ClassCastException If the value associated with the "type" key in the `args` map is not a String.
     * @throws IllegalArgumentException if the string value of the type does not match one of the enum values in `AnnotationType`.
     *
     */
    fun addAnnotation(args: Map<*, *>?) {

        // Getting the annotation type args from the arguments
        val typeArgs = args?.get("type") as? String

        // Getting the annotation type from the type args
        val type = typeArgs?.let { t ->
            try {
                AnnotationType.valueOf(
                    t.replaceFirstChar {
                        if (it.isLowerCase()) it.titlecase(
                            Locale.getDefault()
                        ) else it.toString()
                    }
                )
            } catch (e: Exception) {
                null
            }
        }

        // Checking if the annotation type is valid
        // If it is not valid, throw an exception
        if (type == null) throw Exception("Invalid annotation type")

        // Adding the annotation based on the type
        when (type) {
            AnnotationType.Circle -> addCircleAnnotation(args)
            AnnotationType.Polyline -> addPolylineAnnotation(args)
            AnnotationType.Polygon -> addPolygonAnnotation(args)
            AnnotationType.Symbol -> addSymbolAnnotation(args)
        }
    }


    private fun addCircleAnnotation(args: Map<*, *>?) {

        val optionsArgs = args?.get("annotationOptions") as? Map<*, *>

        val pointArg =
            optionsArgs?.get("point") as? List<*> ?: throw Exception("Point argument is required")

        val point = pointArg.mapNotNull { it.toString().toDoubleOrNull() }
        if (point.size < 2) throw Exception("Point argument must be a list of two numbers")

        val data = (optionsArgs["data"] as? Map<*, *>)?.mapKeys { it.key.toString() }
        val draggable = (optionsArgs["draggable"] as Boolean?) ?: false

        val annotation = AnnotationArgsParser.parseArgs<CircleLayer>(args = args).copy(
            data = data ?: emptyMap(),
            geometry = Point.fromLngLat(point.last(), point.first()),
            draggable = draggable
        )

        if (libreMap.style?.getLayer(annotation.layer.id) != null) {
            libreMap.style?.removeLayer(annotation.layer.id)
        }

        if (libreMap.style?.getSource(annotation.layer.sourceId) != null) {
            libreMap.style?.removeSource(annotation.layer.sourceId)
        }

        libreMap.style?.addSource(
            GeoJsonSource(
                annotation.layer.sourceId,
                annotation.geometry
            )
        ).also {
            libreMap.style?.addLayer(annotation.layer)
        }

        circleAnnotations.add(annotation)
    }

    private fun addPolylineAnnotation(args: Map<*, *>?) {
        val optionsArgs = args?.get("annotationOptions") as? Map<*, *>

        val pointsArg =
            optionsArgs?.get("points") as? List<*> ?: throw Exception("Points argument is required")

        val points = pointsArg.mapNotNull { it as? List<*> }.mapNotNull {
            if (it.size >= 2 && it.first() is Double) Point.fromLngLat(
                it[1] as Double,
                it[0] as Double
            ) else null
        }

        if (points.isEmpty()) throw Exception("Points argument must be a list of list double")

        val data = (optionsArgs["data"] as? Map<*, *>)?.mapKeys { it.key.toString() }
        val draggable = (optionsArgs["draggable"] as Boolean?) ?: false

        val annotation = AnnotationArgsParser.parseArgs<LineLayer>(args = args).copy(
            data = data ?: emptyMap(),
            geometry = LineString.fromLngLats(points),
            draggable = draggable
        )

        if (libreMap.style?.getLayer(annotation.layer.id) != null) {
            libreMap.style?.removeLayer(annotation.layer.id)
        }

        if (libreMap.style?.getSource(annotation.layer.sourceId) != null) {
            libreMap.style?.removeSource(annotation.layer.sourceId)
        }

        libreMap.style?.addSource(
            GeoJsonSource(
                annotation.layer.sourceId,
                annotation.geometry
            )
        ).also {
            libreMap.style?.addLayer(annotation.layer)
        }

        polylineAnnotations.add(annotation)
    }

    private fun addPolygonAnnotation(args: Map<*, *>?) {
        val optionsArgs = args?.get("annotationOptions") as? Map<*, *>

        val pointsArg =
            optionsArgs?.get("points") as? List<*> ?: throw Exception("Points argument is required")

        val points =
            pointsArg.mapNotNull { l1 -> (l1 as? List<*>)?.mapNotNull { l2 -> l2 as? List<*> } }
                .map { l1 ->
                    l1.mapNotNull { l2 ->
                        if (l2.size >= 2 && l2.first() is Double) Point.fromLngLat(
                            l2[1] as Double,
                            l2[0] as Double
                        ) else null
                    }
                }

        if (points.isEmpty()) throw Exception("Points argument must be a list of list double")

        val data = (optionsArgs["data"] as? Map<*, *>)?.mapKeys { it.key.toString() }
        val draggable = (optionsArgs["draggable"] as Boolean?) ?: false

        val annotation = AnnotationArgsParser.parseArgs<FillLayer>(args = args).copy(
            data = data ?: emptyMap(),
            geometry = Polygon.fromLngLats(points),
            draggable = draggable
        )

        if (libreMap.style?.getLayer(annotation.layer.id) != null) {
            libreMap.style?.removeLayer(annotation.layer.id)
        }

        if (libreMap.style?.getSource(annotation.layer.sourceId) != null) {
            libreMap.style?.removeSource(annotation.layer.sourceId)
        }

        libreMap.style?.addSource(
            GeoJsonSource(
                annotation.layer.sourceId,
                annotation.geometry
            )
        ).also {
            libreMap.style?.addLayer(annotation.layer)
        }

        polygonAnnotations.add(annotation)
    }

    private fun addSymbolAnnotation(args: Map<*, *>?) {
        val optionsArgs = args?.get("annotationOptions") as? Map<*, *>

        val pointArg =
            optionsArgs?.get("point") as? List<*> ?: throw Exception("Point argument is required")

        val point = pointArg.mapNotNull { it.toString().toDoubleOrNull() }
        if (point.size < 2) throw Exception("Point argument must be a list of two numbers")

        val data = (optionsArgs["data"] as? Map<*, *>)?.mapKeys { it.key.toString() }
        val draggable = (optionsArgs["draggable"] as Boolean?) ?: false

        val annotation = AnnotationArgsParser.parseArgs<SymbolLayer>(args = args).copy(
            data = data ?: emptyMap(),
            geometry = Point.fromLngLat(point.last(), point.first()),
            draggable = draggable
        )

        if (libreMap.style?.getLayer(annotation.layer.id) != null) {
            libreMap.style?.removeLayer(annotation.layer.id)
        }

        if (libreMap.style?.getSource(annotation.layer.sourceId) != null) {
            libreMap.style?.removeSource(annotation.layer.sourceId)
        }

        libreMap.style?.addSource(
            GeoJsonSource(
                annotation.layer.sourceId,
                annotation.geometry
            )
        ).also {
            libreMap.style?.addLayer(annotation.layer)
        }

        symbolAnnotations.add(annotation)
    }

}