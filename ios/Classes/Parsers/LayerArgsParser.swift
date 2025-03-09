//
//  LayerArgsParser.swift
//  naxalibre
//
//  Created by Amit on 24/02/2025.
//

import Foundation
import MapLibre

class LayerArgsParser {
    /// Parses a dictionary of arguments to create a MapLibre layer.
    /// - Parameters:
    ///   - args: A dictionary containing layer details.
    ///   - source: The `MLNSource` object to which the layer will be attached. Can be `nil` for background layers.
    /// - Returns: A configured `MLNStyleLayer` object or `nil` if parsing fails.
    ///
    static func parseArgs(_ args: [String: Any?], source: MLNSource?) -> MLNStyleLayer? {
        // Ensure the 'type' key is present and valid
        guard let typeString = args["type"] as? String,
              let type = NaxaLibreLayerType(rawValue: typeString) else {
            return nil
        }
        
        // Ensure 'source' is provided for layers that require it
        if type != .background && source == nil {
            return nil
        }
        
        // Define a dictionary mapping layer types to their respective parser functions
        let parsers: [NaxaLibreLayerType: ([String: Any?], MLNSource) -> MLNStyleLayer?] = [
            .symbol: SymbolLayerArgsParser.parseArgs,
            .fill: FillLayerArgsParser.parseArgs,
            .line: LineLayerArgsParser.parseArgs,
            .circle: CircleLayerArgsParser.parseArgs,
            .raster: RasterLayerArgsParser.parseArgs,
            .fillExtrusion: FillExtrusionLayerArgsParser.parseArgs,
            .heatmap: HeatmapLayerArgsParser.parseArgs,
            .hillshade: HillShadeLayerArgsParser.parseArgs,
            .background: { args, _ in BackgroundLayerArgsParser.parseArgs(args) }
        ]
        
        // Call the appropriate parser function
        if let parser = parsers[type] {
            return parser(args, source!)
        }
        
        return nil
    }
    
    
    /// Extracts a set of arguments from a given Layer object.
    ///
    /// This function examines the provided `Layer` and returns a dictionary containing
    /// key-value pairs representing the layer's properties. The dictionary includes:
    ///
    /// - **Common Properties (for all layer types):**
    ///   - `"id"`: The unique identifier of the layer.
    ///   - `"min_zoom"`: The minimum zoom level at which the layer is visible.
    ///   - `"max_zoom"`: The maximum zoom level at which the layer is visible.
    ///
    /// - **Layer-Specific Properties:**
    ///   - `"type"`: A string describing the layer type (e.g., "fill-layer", "line-layer").
    ///   - `"sourceId"`: The ID of the data source used by the layer. This may be nil for some layers (e.g., BackgroundLayer).
    ///   - `"source_layer"`: The specific layer within the data source that this layer uses. This may be nil for some layers.
    ///
    /// The function uses a switch statement to handle different layer types, adding
    /// type-specific information to the resulting dictionary. If the layer type is unknown,
    /// it defaults to a type of "unknown" and nil source information.
    ///
    /// @param layer The Layer object to extract arguments from.
    /// @return A dictionary containing the extracted arguments as key-value pairs.
    ///
    static func extractArgsFromLayer(layer: MLNStyleLayer) -> [AnyHashable?: Any?] {
        var args: [AnyHashable?: Any?] = [:]
        
        // Common properties for all layers
        args["id"] = layer.identifier
        args["minzoom"] = layer.minimumZoomLevel
        args["maxzoom"] = layer.maximumZoomLevel
        
        // Layer-specific properties
        switch layer {
            case let fillLayer as MLNFillStyleLayer:
                args["type"] = NaxaLibreLayerType.fill.rawValue
                args["sourceId"] = fillLayer.sourceIdentifier
                args["sourceLayer"] = fillLayer.sourceLayerIdentifier
                
            case let lineLayer as MLNLineStyleLayer:
                args["type"] = NaxaLibreLayerType.line.rawValue
                args["sourceId"] = lineLayer.sourceIdentifier
                args["sourceLayer"] = lineLayer.sourceLayerIdentifier
                
            case let circleLayer as MLNCircleStyleLayer:
                args["type"] = NaxaLibreLayerType.circle.rawValue
                args["sourceId"] = circleLayer.sourceIdentifier
                args["sourceLayer"] = circleLayer.sourceLayerIdentifier
                
            case let symbolLayer as MLNSymbolStyleLayer:
                args["type"] = NaxaLibreLayerType.symbol.rawValue
                args["sourceId"] = symbolLayer.sourceIdentifier
                args["sourceLayer"] = symbolLayer.sourceLayerIdentifier
                
            case let fillExtrusionLayer as MLNFillExtrusionStyleLayer:
                args["type"] = NaxaLibreLayerType.fillExtrusion.rawValue
                args["sourceId"] = fillExtrusionLayer.sourceIdentifier
                args["sourceLayer"] = fillExtrusionLayer.sourceLayerIdentifier
                
            case let heatmapLayer as MLNHeatmapStyleLayer:
                args["type"] = NaxaLibreLayerType.heatmap.rawValue
                args["sourceId"] = heatmapLayer.sourceIdentifier
                args["sourceLayer"] = heatmapLayer.sourceLayerIdentifier
                
            case let rasterLayer as MLNRasterStyleLayer:
                args["type"] = NaxaLibreLayerType.raster.rawValue
                args["sourceId"] = rasterLayer.sourceIdentifier
                args["sourceLayer"] = nil
                
            case let hillshadeLayer as MLNHillshadeStyleLayer:
                args["type"] = NaxaLibreLayerType.hillshade.rawValue
                args["sourceId"] = hillshadeLayer.sourceIdentifier
                args["sourceLayer"] = nil
                
            case is MLNBackgroundStyleLayer:
                args["type"] = NaxaLibreLayerType.background.rawValue
                args["sourceId"] = nil
                args["sourceLayer"] = nil
                
            default:
                args["type"] = "unknown"
                args["sourceId"] = nil
                args["sourceLayer"] = nil
        }
        
        return args
    }
}


/// Enum for layer types supported in NaxaLibre
fileprivate enum NaxaLibreLayerType: String {
    case symbol = "symbol-layer"
    case fill = "fill-layer"
    case line = "line-layer"
    case circle = "circle-layer"
    case raster = "raster-layer"
    case fillExtrusion = "fill-extrusion-layer"
    case heatmap = "heatmap-layer"
    case hillshade = "hillshade-layer"
    case background = "background-layer"
}
