package com.example.smart_glyco_ai // MUDA ISTO PARA O TEU PACKAGE REAL

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class GlycoWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            // Apenas carrega o XML estático, sem tentar atualizar os textos
            val views = RemoteViews(context.packageName, R.layout.widget_layout)
            
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}