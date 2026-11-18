package com.sbfrusho.yourshop

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity is required by local_auth (biometrics) and Stripe.
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannels()
    }

    /** "Order updates" channel used by FCM (see AndroidManifest meta-data). */
    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            "orders",
            "Order updates",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "When your order is confirmed, shipped or delivered"
        }
        getSystemService(NotificationManager::class.java)
            .createNotificationChannel(channel)
    }
}
