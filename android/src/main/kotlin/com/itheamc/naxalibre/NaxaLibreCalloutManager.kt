package com.itheamc.naxalibre

import android.content.Context
import android.graphics.Color
import android.view.Gravity
import android.view.View
import android.widget.LinearLayout
import android.widget.TextView
import org.maplibre.android.annotations.Marker
import org.maplibre.android.annotations.MarkerOptions
import org.maplibre.android.geometry.LatLng
import org.maplibre.android.maps.MapLibreMap
import org.maplibre.android.maps.MapView

/**
 * Manages callouts (popups) for annotations on the map.
 */
class NaxaLibreCalloutManager(
    private val context: Context,
    private val mapView: MapView,
    private val map: MapLibreMap
) {
    private val callouts = mutableMapOf<Long, Marker>()

    /**
     * Creates a callout view with the given title and subtitle.
     */
    private fun createCalloutView(title: String, subtitle: String?): View {
        return LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.WHITE)
            setPadding(16, 8, 16, 8)
            gravity = Gravity.CENTER

            addView(TextView(context).apply {
                text = title
                textSize = 16f
                setTextColor(Color.BLACK)
            })

            if (subtitle != null) {
                addView(TextView(context).apply {
                    text = subtitle
                    textSize = 14f
                    setTextColor(Color.GRAY)
                })
            }
        }
    }

    /**
     * Shows a callout for a specific annotation.
     */
    fun showCallout(annotationId: Long, title: String, subtitle: String?, position: LatLng) {
        // Remove existing callout if any
        hideCallout(annotationId)

        // Create and show new callout
        val calloutView = createCalloutView(title, subtitle)
        val marker = map.addMarker(
            MarkerOptions()
                .position(position)
                .setSnippet(subtitle)
                .setTitle(title)
        )
        callouts[annotationId] = marker
    }

    /**
     * Hides the callout for a specific annotation.
     */
    fun hideCallout(annotationId: Long) {
        callouts[annotationId]?.let { marker ->
            map.removeMarker(marker)
            callouts.remove(annotationId)
        }
    }

    /**
     * Updates the content of a callout for a specific annotation.
     */
    fun updateCallout(annotationId: Long, title: String, subtitle: String?) {
        callouts[annotationId]?.let { marker ->
            marker.title = title
            marker.snippet = subtitle
        }
    }

    /**
     * Hides all callouts currently displayed on the map.
     */
    fun hideAllCallouts() {
        callouts.values.forEach { marker ->
            map.removeMarker(marker)
        }
        callouts.clear()
    }
} 