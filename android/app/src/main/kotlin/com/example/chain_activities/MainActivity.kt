package com.promaxbiz.chain_activities

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import android.content.Intent.FLAG_ACTIVITY_NEW_TASK
import android.content.ContentResolver
import android.content.Context
import android.media.RingtoneManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity: FlutterActivity() {
    private val sharedTextChannel = "promaxbiz.com/shared_text"

    // Text (an image address) shared into the app. receive_sharing_intent 1.9.0
    // only forwards media, so shared text is handed over here instead.
    private var sharedText: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "promaxbiz.com/flutter_local_notifications").setMethodCallHandler { call, result ->
            if ("drawableToUri" == call.method) {
                val resourceId = this@MainActivity.resources.getIdentifier(call.arguments as String, "drawable", this@MainActivity.packageName)
                result.success(resourceToUriString(this@MainActivity.applicationContext, resourceId))
            }
            if ("getAlarmUri" == call.method) {
                result.success(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM).toString())
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, sharedTextChannel).setMethodCallHandler { call, result ->
            if ("getSharedText" == call.method) {
                result.success(sharedText)
                sharedText = null
            } else {
                result.notImplemented()
            }
        }
        readSharedText(intent)
    }

    override fun onNewIntent(intent: android.content.Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        readSharedText(intent)
    }

    private fun readSharedText(intent: android.content.Intent?) {
        if (intent?.action != android.content.Intent.ACTION_SEND) {
            return
        }
        sharedText = intent.getStringExtra(android.content.Intent.EXTRA_TEXT) ?: return
    }

    private fun resourceToUriString(context: Context, resId: Int): String? {
        return (ContentResolver.SCHEME_ANDROID_RESOURCE + "://"
                + context.resources.getResourcePackageName(resId)
                + "/"
                + context.resources.getResourceTypeName(resId)
                + "/"
                + context.resources.getResourceEntryName(resId))
    }
}
