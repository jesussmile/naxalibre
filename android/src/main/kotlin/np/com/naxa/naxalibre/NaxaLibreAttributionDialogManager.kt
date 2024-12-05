package np.com.naxa.naxalibre

import android.app.Activity
import android.app.AlertDialog
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.DialogInterface
import android.content.Intent
import android.content.Intent.FLAG_ACTIVITY_NEW_TASK
import android.net.Uri
import android.view.View
import android.widget.ArrayAdapter
import android.widget.Toast
import org.maplibre.android.MapStrictMode
import org.maplibre.android.R.layout
import org.maplibre.android.R.string
import org.maplibre.android.maps.AttributionDialogManager
import org.maplibre.android.maps.MapLibreMap

class NaxaLibreAttributionDialogManager(
    private val context: Context,
    maplibreMap: MapLibreMap
) : AttributionDialogManager(context, maplibreMap),
    View.OnClickListener, DialogInterface.OnClickListener {
    private var attributions: Map<String, String> = mapOf(
        "NAXA" to "https://naxa.com.np/",
        "Test" to "https://test.com.np/"
    )
    private var dialog: AlertDialog? = null

    override fun onClick(view: View) {
        var isActivityFinishing = false
        if (context is Activity) {
            isActivityFinishing = context.isFinishing
        }

        if (!isActivityFinishing) {
            this.showAttributionDialog(this.attributionTitles)
        }
    }

    override fun showAttributionDialog(attributionTitles: Array<String?>) {
        val builder = AlertDialog.Builder(this.context)
        builder.setTitle("NaxaLibre by NAXA")
        builder.setAdapter(
            ArrayAdapter<Any?>(
                this.context,
                layout.maplibre_attribution_list_item,
                attributionTitles
            ),
            this
        )
        this.dialog = builder.show()
    }

    private val attributionTitles: Array<String?> = attributions.map { it.key }.toTypedArray()

    override fun onClick(dialog: DialogInterface, which: Int) {
        this.showMapAttributionWebPage(which)
    }

    override fun onStop() {
        if (this.dialog != null && dialog!!.isShowing) {
            dialog!!.dismiss()
        }
    }

    private fun showMapAttributionWebPage(which: Int) {
        val url = attributions[attributions.keys.toTypedArray()[which]]
        url?.let { this.showWebPage(it) }
    }

    private fun showWebPage(url: String) {
        try {
            val intent = Intent("android.intent.action.VIEW")
            intent.setData(Uri.parse(url))
            intent.setFlags(FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
        } catch (var3: ActivityNotFoundException) {
            Toast.makeText(context, string.maplibre_attributionErrorNoBrowser, Toast.LENGTH_LONG)
                .show()
            MapStrictMode.strictModeViolation(var3)
        }
    }

}