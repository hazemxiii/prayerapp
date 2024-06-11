package com.example.prayerapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.net.Uri
import android.os.Build
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.time.Duration
import android.util.Log
import android.widget.ProgressBar

import com.example.prayerapp.R
import es.antonborri.home_widget.HomeWidgetBackgroundIntent

/**
 * Implementation of App Widget functionality.
 */
class nextPrayerWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
    val data = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.next_prayer_widget).apply{
                    val name = data.getString("name","No data")
                    val time = data.getString("time","No data")
                    val progress = data.getInt("progress",25)
                    setTextViewText(R.id.name, name)
                    setTextViewText(R.id.time, time)

                val reloadIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("nextPrayerWidget://reload")
                )
                setOnClickPendingIntent(R.id.reload, reloadIntent)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

}

