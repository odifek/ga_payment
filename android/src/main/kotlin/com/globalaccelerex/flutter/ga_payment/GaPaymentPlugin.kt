package com.globalaccelerex.flutter.ga_payment

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

private const val REQUEST_CODE_PARAMETER = 100
private const val REQUEST_CODE_TRANSACTION = 101
private const val DATA_KEY = "data"
private const val STATUS_KEY = "statusMessage"
private const val REQUEST_CODE_KEY = "requestCode"

/** GaPaymentPlugin */
class GaPaymentPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private var resultListener: Result? = null

    private var pendingResult: Map<String, Any?>? = null

    private fun updateResult(requestCode: Int, result: Map<String, Any?>) {
        val finalResult = result.plus(REQUEST_CODE_KEY to requestCode)
        if (resultListener == null) {
            pendingResult = finalResult
        } else {
            resultListener?.success(finalResult)
        }
    }

    private val activityResultListener = { requestCode: Int, resultCode: Int, data: Intent? ->
        // TODO: Analyse the result and deliver to the caller
        Log.d("GaPaymentPlugin", "ActivityResult: $resultCode")
        var result: Map<String, Any?> = mapOf(STATUS_KEY to "Request failed!")
        if (resultCode == Activity.RESULT_OK) {
            if (requestCode == REQUEST_CODE_PARAMETER) {
                val parameters = data?.getStringExtra("data")
                result = if (parameters != null)
                    mapOf(DATA_KEY to parameters)
                else mapOf(STATUS_KEY to "Failed to get parameters")

            } else if (requestCode == REQUEST_CODE_TRANSACTION) {
                val paymentResult = data?.getStringExtra(DATA_KEY)
                val statusMessage = data?.getStringExtra(STATUS_KEY)
                result = if (paymentResult != null) {
                    mapOf(DATA_KEY to paymentResult, STATUS_KEY to statusMessage)
                } else {
                    mapOf(STATUS_KEY to statusMessage)
                }
            }
        } else {
            result = mapOf(STATUS_KEY to "Request cancelled!")
        }
        updateResult(requestCode, result)
        true
    }

    private var activityBinding: ActivityPluginBinding? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ga_payment")
        channel.setMethodCallHandler(this)
    }


    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (activityBinding == null) {
            result.error("Failure", "Activity not ready yet!", null)
            return
        }
        resultListener = result
        when (call.method) {
            "checkPendingRequest" -> {
                if (pendingResult != null) {
                    result.success(pendingResult).also { pendingResult = null }
                } else {
                    result.error("NoPending", "No Pending activity requests", null)
                }
            }
            "getParameters" -> {
                val intent = Intent("com.globalaccelerex.utility").putExtra("requestData", """{"action": "PARAMETER"}""")
                try {
                    activityBinding?.activity?.startActivityForResult(intent, REQUEST_CODE_PARAMETER)
                } catch (e: ActivityNotFoundException) {
                    result.error("ActivityNotFound", e.message, e)
                }
            }
            "transaction" -> {
                if (call.hasArgument("amount") && call.hasArgument("transType")) {
                    val amount = call.argument<Double>("amount")
                    val transType = call.argument<String>("transType")
                    val print = call.argument<Boolean>("print") ?: false
                    val requestData = """{"transType": "$transType", "amount": $amount, "print": $print}"""
                    val intent = Intent("com.globalaccelerex.transaction")
                            .putExtra("requestData", requestData)
                    try {
                        activityBinding?.activity?.startActivityForResult(intent, REQUEST_CODE_TRANSACTION)
                    } catch (e: ActivityNotFoundException) {
                        result.error("ActivityNotFound", e.message, e)
                    }
                }

            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        activityBinding?.addActivityResultListener(activityResultListener)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityBinding?.removeActivityResultListener(activityResultListener)
        activityBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityBinding = binding
        activityBinding?.addActivityResultListener(activityResultListener)
    }

    override fun onDetachedFromActivity() {
        activityBinding?.removeActivityResultListener(activityResultListener)
        activityBinding = null
    }

}
