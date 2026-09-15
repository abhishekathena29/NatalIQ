package com.example.natal_iq

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.time.Instant
import java.util.Date
import java.util.Locale

/**
 * Home screen widget mirroring [NapTimerService]'s state, written via
 * `HomeWidget.saveWidgetData` from Dart. Tapping the widget opens the app to
 * the nap screen through the `napwidget://nap` deep link (see AanyaApp's
 * `HomeWidget.widgetClicked` listener in main.dart).
 */
class NapWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val isRunning = widgetData.getBoolean("nap_is_running", false)
        val startIso = widgetData.getString("nap_start_iso", null)

        val statusText = if (isRunning && startIso != null) {
            "Napping since ${formatStartTime(startIso)}"
        } else {
            "Not napping"
        }

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.nap_widget)
            views.setTextViewText(R.id.nap_widget_status, statusText)
            views.setOnClickPendingIntent(
                R.id.nap_widget_status,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("napwidget://nap")),
            )
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun formatStartTime(iso: String): String {
        return try {
            val instant = Instant.parse(iso)
            SimpleDateFormat("h:mm a", Locale.getDefault()).format(Date.from(instant))
        } catch (e: Exception) {
            "earlier"
        }
    }
}
