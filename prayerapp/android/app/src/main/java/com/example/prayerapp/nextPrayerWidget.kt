package com.example.prayerapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
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
                val name = data.getString("name","No data")
                val time = data.getString("time","No data")
                setTextViewText(R.id.name, name)
                setTextViewText(R.id.time, time)

            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

}

