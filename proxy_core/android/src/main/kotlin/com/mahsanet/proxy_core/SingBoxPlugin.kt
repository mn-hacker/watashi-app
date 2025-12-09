package com.mahsanet.proxy_core

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Flutter plugin for SingBox core integration.
 * Handles method channel calls from Flutter to start/stop SingBox.
 */
class SingBoxPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private var applicationContext: Context? = null
    private var methodChannel: MethodChannel? = null
    private var singBoxService: SingBoxService? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        methodChannel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        methodChannel?.setMethodCallHandler(this)
        Log.d(TAG, "SingBox plugin attached")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        singBoxService?.stop()
        singBoxService = null
        applicationContext = null
        Log.d(TAG, "SingBox plugin detached")
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> handleStart(call, result)
            "stop" -> handleStop(result)
            "isRunning" -> handleIsRunning(result)
            "getLogs" -> handleGetLogs(result)
            "clearLogs" -> handleClearLogs(result)
            else -> result.notImplemented()
        }
    }

    private fun handleStart(call: MethodCall, result: MethodChannel.Result) {
        try {
            val config = call.argument<String>("config")
            val tunFd = call.argument<Int>("tunFd")

            if (config == null || tunFd == null) {
                result.error("INVALID_ARGS", "config and tunFd are required", null)
                return
            }

            Log.d(TAG, "Starting SingBox with tunFd: $tunFd")
            appendLog("[SingBox] Starting with tunFd: $tunFd")

            // Create service if needed
            if (singBoxService == null) {
                applicationContext?.let {
                    singBoxService = SingBoxService(it)
                } ?: run {
                    result.error("NO_CONTEXT", "Application context not available", null)
                    return
                }
            }

            // Stop existing if running
            if (singBoxService?.isRunning() == true) {
                singBoxService?.stop()
            }

            // Start with new config
            val success = singBoxService?.start(config, tunFd) ?: false
            if (success) {
                appendLog("[SingBox] Started successfully")
            } else {
                appendLog("[SingBox] Failed to start")
            }
            result.success(success)

        } catch (e: Exception) {
            Log.e(TAG, "Failed to start SingBox", e)
            appendLog("[SingBox] Error: ${e.message}")
            result.error("START_FAILED", e.message, null)
        }
    }

    private fun handleStop(result: MethodChannel.Result) {
        try {
            Log.d(TAG, "Stopping SingBox")
            appendLog("[SingBox] Stopping...")
            singBoxService?.stop()
            appendLog("[SingBox] Stopped")
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to stop SingBox", e)
            appendLog("[SingBox] Stop error: ${e.message}")
            result.error("STOP_FAILED", e.message, null)
        }
    }

    private fun handleIsRunning(result: MethodChannel.Result) {
        try {
            val running = singBoxService?.isRunning() ?: false
            result.success(running)
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun handleGetLogs(result: MethodChannel.Result) {
        synchronized(logBuffer) {
            val logs = logBuffer.toString()
            logBuffer.clear() // Clear buffer after reading to prevent duplicates
            result.success(logs)
        }
    }

    private fun handleClearLogs(result: MethodChannel.Result) {
        synchronized(logBuffer) {
            logBuffer.clear()
        }
        result.success(null)
    }

    companion object {
        private const val TAG = "SingBoxPlugin"
        private const val CHANNEL_NAME = "proxy_core/singbox"
        private val logBuffer = StringBuilder()

        fun appendLog(message: String) {
            synchronized(logBuffer) {
                logBuffer.append(message).append("\n")
            }
            Log.d(TAG, message)
        }
    }
}
