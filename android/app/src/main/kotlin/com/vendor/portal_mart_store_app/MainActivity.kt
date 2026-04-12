package com.vendor.portal_mart_store_app

import com.flitt.mobile.GooglePayButton.GooglePayButtonPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        flutterEngine.plugins.add(GooglePayButtonPlugin())
    }
}
