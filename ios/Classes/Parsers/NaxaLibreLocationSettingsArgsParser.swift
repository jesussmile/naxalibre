//
//  NaxaLibreLocationSettingsParser.swift
//  naxalibre
//
//  Created by Amit on 28/02/2025.
//

import Foundation
import MapLibre

/// Object responsible for parsing arguments provided to configure a MapLibre map.
///
/// This struct provides a utility function `parseArgs` that takes a dictionary of arguments
/// and constructs a `NaxaLibreLocationSettings` object based on these arguments. It handles parsing various
/// location settings related values, including user location annotation styling.
struct NaxaLibreLocationSettingsArgsParser {
    
    /// Parses a dictionary of arguments to create a `NaxaLibreLocationSettings` object.
    ///
    /// - Parameters:
    ///   - args: An optional dictionary containing key-value pairs representing the map's configuration.
    ///           If nil, default options are created.
    ///           The supported keys and their types are:
    ///
    /// - Returns: A `MapLibreMapOptions` object configured with the provided arguments or default values.
    static func parseArgs(_ args: [String: Any?]?) -> NaxaLibreLocationSettings {
        return NaxaLibreLocationSettings.fromArgs(args ?? [:])
    }
}


/// An extension to `MLNUserLocationAnnotationViewStyle` that applies custom styling
/// based on the provided `NaxaLibreLocationComponentOptions` options.
///
extension MLNUserLocationAnnotationViewStyle {
    
    /// Applies the specified style settings to the user location annotation view.
    ///
    /// - Parameter styleOptions: A `NaxaLibreLocationComponentOptions` instance containing style options.
    func applyStyle(_ styleOptions: NaxaLibreLocationComponentOptions) {
        
        // Set the halo (pulsing circle) fill color if specified.
        if let pulseColor = UIColor.from(value: styleOptions.pulseColor) {
            self.haloFillColor = pulseColor
        }
        
        // Set the foreground tint color (e.g., the main puck fill color).
        if let foregroundTintColor = UIColor.from(value: styleOptions.foregroundTintColor) {
            self.puckFillColor = foregroundTintColor
        }
        
        // Set the background tint color, often used for the puck's shadow.
        if let backgroundTintColor = UIColor.from(value: styleOptions.backgroundTintColor) {
            self.puckShadowColor = backgroundTintColor
        }
        
        // Set the bearing indicator color (used for directional indicators).
        if let bearingTintColor = UIColor.from(value: styleOptions.bearingTintColor) {
            self.puckArrowFillColor = bearingTintColor
        }
        
        // iOS 14+ exclusive styling options.
        if #available(iOS 14, *) {
            
            // Set the approximate location accuracy halo color if specified.
            if let accuracyColor = UIColor.from(value: styleOptions.accuracyColor) {
                self.approximateHaloFillColor = accuracyColor
            }
            
            // Set the opacity of the approximate location accuracy halo if specified.
            if let accuracyAlpha = styleOptions.accuracyAlpha {
                self.approximateHaloOpacity = accuracyAlpha
            }
        }
    }
}

