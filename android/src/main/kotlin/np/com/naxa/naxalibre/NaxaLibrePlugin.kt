package np.com.naxa.naxalibre

import android.app.Activity
import android.content.Context
import android.os.Bundle
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.TextView
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec
import org.maplibre.android.MapLibre
import org.maplibre.android.maps.AttributionDialogManager
import org.maplibre.android.maps.MapView

class NaxaLibrePlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var pluginBinding: FlutterPlugin.FlutterPluginBinding? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        pluginBinding = binding
        channel = MethodChannel(binding.binaryMessenger, "naxalibre")
        channel.setMethodCallHandler(this)

        // Register the platform view factory
        binding.platformViewRegistry.registerViewFactory(
            "naxalibre/mapview",
            MapLibreViewFactory(activity)
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        pluginBinding = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            else -> result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }
}

class MapLibreViewFactory(private val activity: Activity?) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as? Map<*, *>
        return MapLibreView(context, creationParams, activity)
    }
}


class MapLibreView(context: Context, creationParams: Map<*, *>?, private val activity: Activity?) :
    PlatformView {
    private var mapView: MapView
    private val mapContainer: FrameLayout = FrameLayout(context)

    init {
        MapLibre.getInstance(context)

        mapView = MapView(context)

        val text = TextView(context)

        text.text = "NAXA HO YO"
        text.layoutParams = FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        ).apply {
            gravity = Gravity.CENTER
        }
        mapView.addView(text)

        mapView.onCreate(null)
        mapView.getMapAsync { libre ->
            val styleUrl = creationParams?.get("styleURL") as? String
            libre.setStyle(styleUrl)

            libre.uiSettings.apply {
//                isAttributionEnabled = false
                setAttributionDialogManager(NaxaLibreAttributionDialogManager(context, libre))
            }
        }

        // Attach lifecycle listeners if needed
        activity?.application?.registerActivityLifecycleCallbacks(object :
            android.app.Application.ActivityLifecycleCallbacks {
            override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}
            override fun onActivityStarted(activity: Activity) {
                if (activity == this@MapLibreView.activity) mapView.onStart()
            }

            override fun onActivityResumed(activity: Activity) {
                if (activity == this@MapLibreView.activity) mapView.onResume()
            }

            override fun onActivityPaused(activity: Activity) {
                if (activity == this@MapLibreView.activity) mapView.onPause()
            }

            override fun onActivityStopped(activity: Activity) {
                if (activity == this@MapLibreView.activity) mapView.onStop()
            }

            override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
            override fun onActivityDestroyed(activity: Activity) {
                if (activity == this@MapLibreView.activity) mapView.onDestroy()
            }
        })
    }

    override fun getView(): View {
        return mapView
    }

    override fun dispose() {
        mapView.onPause()
        mapView.onDestroy()
    }
}
