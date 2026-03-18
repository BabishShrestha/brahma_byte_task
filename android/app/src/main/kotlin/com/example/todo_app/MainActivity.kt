package com.example.todo_app

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.view.View
import android.widget.Button
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

class MainActivity : FlutterActivity() {
	private lateinit var methodChannel: MethodChannel

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		methodChannel = MethodChannel(
			flutterEngine.dartExecutor.binaryMessenger,
			CHANNEL_NAME,
		)

		methodChannel.setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
			when (call.method) {
				"getDeviceInfo" -> result.success(getDeviceInfo())
				else -> result.notImplemented()
			}
		}

		flutterEngine
			.platformViewsController
			.registry
			.registerViewFactory(
				PLATFORM_VIEW_TYPE,
				NativeRefreshButtonViewFactory(this, methodChannel),
			)
	}

	private fun getDeviceInfo(): Map<String, Any> {
		val batteryIntent: Intent? = registerReceiver(
			null,
			IntentFilter(Intent.ACTION_BATTERY_CHANGED),
		)

		val level = batteryIntent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
		val scale = batteryIntent?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
		val batteryLevel = if (level >= 0 && scale > 0) {
			(level * 100) / scale
		} else {
			-1
		}

		val status = batteryIntent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
		val isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING ||
			status == BatteryManager.BATTERY_STATUS_FULL

		val formatter = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US)
		formatter.timeZone = TimeZone.getTimeZone("UTC")
		val systemTime = formatter.format(Date())

		return mapOf(
			"batteryLevel" to batteryLevel,
			"deviceModel" to Build.MODEL,
			"isCharging" to isCharging,
			"systemTime" to systemTime,
		)
	}

	companion object {
		private const val CHANNEL_NAME = "com.example.todo_app/device_info"
		private const val PLATFORM_VIEW_TYPE = "com.example.todo_app/native_refresh_button"
	}
}

private class NativeRefreshButtonViewFactory(
	private val context: Context,
	private val channel: MethodChannel,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
	override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
		return NativeRefreshButtonPlatformView(this.context, channel)
	}
}

private class NativeRefreshButtonPlatformView(
	context: Context,
	private val channel: MethodChannel,
) : PlatformView {
	private val button: Button = Button(context).apply {
		text = "Native Refresh Battery"
		setOnClickListener {
			channel.invokeMethod("nativeButtonPressed", null)
		}
	}

	override fun getView(): View = button

	override fun dispose() {
		button.setOnClickListener(null)
	}
}
