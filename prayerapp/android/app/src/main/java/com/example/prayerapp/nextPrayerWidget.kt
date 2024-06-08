package com.example.prayerapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.os.Build
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.time.Duration
import android.util.Log

import com.example.prayerapp.R
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
                Log.d("tag","updated")
                    val fajr = data.getString("Isha'a","No data")

                    setTextViewText(R.id.name, "Isha'a")
                    setTextViewText(R.id.time, fajr)

            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

}

