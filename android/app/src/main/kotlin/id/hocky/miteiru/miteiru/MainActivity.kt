package id.hocky.miteiru.miteiru

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.ContextMenu
import android.view.MenuItem
import android.view.View
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "id.hocky.miteiru/clipboard"

    @RequiresApi(Build.VERSION_CODES.M)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(
            flutterEngine!!.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "getProcessedText") {
                if (Intent.ACTION_PROCESS_TEXT == intent.action) {
                    val text = intent.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT).toString()
                    result.success(text)
                } else {
                    result.success("")
                }
            }
        }
    }
}
