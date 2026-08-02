package com.example.saathi_ai

import android.app.ActivityManager
import android.bluetooth.BluetoothAdapter
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.wifi.WifiManager
import android.os.BatteryManager
import android.os.Build
import android.os.Environment
import android.provider.ContactsContract
import android.provider.Settings
import android.telephony.SmsManager
import android.telephony.TelephonyManager
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class DeviceControl {
    companion object {
        private const val CHANNEL = "com.saathi.device/control"
    }

    fun setupChannel(flutterEngine: FlutterEngine, context: Context) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getBatteryInfo" -> result.success(getBatteryInfo(context))
                    "getStorageInfo" -> result.success(getStorageInfo())
                    "getAppsList" -> result.success(getAppsList(context))
                    "launchApp" -> {
                        val packageName = call.argument<String>("package")
                        launchApp(context, packageName)
                        result.success(true)
                    }
                    "closeApp" -> {
                        val packageName = call.argument<String>("package")
                        closeApp(context, packageName)
                        result.success(true)
                    }
                    "getWiFiStatus" -> result.success(getWiFiStatus(context))
                    "toggleWiFi" -> {
                        val enable = call.argument<Boolean>("enable")
                        toggleWiFi(context, enable ?: true)
                        result.success(true)
                    }
                    "getBluetoothStatus" -> result.success(getBluetoothStatus())
                    "toggleBluetooth" -> {
                        val enable = call.argument<Boolean>("enable")
                        toggleBluetooth(enable ?: true)
                        result.success(true)
                    }
                    "sendSMS" -> {
                        val phoneNumber = call.argument<String>("phoneNumber")
                        val message = call.argument<String>("message")
                        sendSMS(phoneNumber, message)
                        result.success(true)
                    }
                    "getContacts" -> result.success(getContacts(context))
                    "openSettings" -> {
                        openSettings(context)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun getBatteryInfo(context: Context): Map<String, Any> {
        val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        val batteryPercentage = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        
        val ifilter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        val batteryStatus = context.registerReceiver(null, ifilter)
        val health = batteryStatus?.getIntExtra(BatteryManager.EXTRA_HEALTH, 0) ?: 0
        val temperature = batteryStatus?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 0) ?: 0
        val voltage = batteryStatus?.getIntExtra(BatteryManager.EXTRA_VOLTAGE, 0) ?: 0
        
        return mapOf(
            "percentage" to batteryPercentage,
            "health" to health,
            "temperature" to temperature,
            "voltage" to voltage,
            "isCharging" to isCharging(context)
        )
    }

    private fun isCharging(context: Context): Boolean {
        val ifilter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        val batteryStatus = context.registerReceiver(null, ifilter)
        val status = batteryStatus?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
        return status == BatteryManager.BATTERY_STATUS_CHARGING || status == BatteryManager.BATTERY_STATUS_FULL
    }

    private fun getStorageInfo(): Map<String, Any> {
        val stat = android.os.StatFs(Environment.getExternalStorageDirectory().path)
        val bytesAvailable = stat.availableBlocksLong * stat.blockSizeLong
        val totalBytes = stat.blockCountLong * stat.blockSizeLong
        val usedBytes = totalBytes - bytesAvailable

        return mapOf(
            "totalStorage" to (totalBytes / (1024 * 1024 * 1024)), // GB
            "usedStorage" to (usedBytes / (1024 * 1024 * 1024)), // GB
            "availableStorage" to (bytesAvailable / (1024 * 1024 * 1024)), // GB
            "percentageUsed" to ((usedBytes * 100) / totalBytes)
        )
    }

    private fun getAppsList(context: Context): List<Map<String, String>> {
        val pm = context.packageManager
        val apps = mutableListOf<Map<String, String>>()
        
        val installedApps = pm.getInstalledApplications(PackageManager.GET_META_DATA)
        for (app in installedApps) {
            if (app.flags and ApplicationInfo.FLAG_SYSTEM == 0) { // Only user apps
                apps.add(mapOf(
                    "packageName" to (app.packageName ?: ""),
                    "appName" to (pm.getApplicationLabel(app).toString()),
                    "icon" to (app.loadIcon(pm).toString())
                ))
            }
        }
        
        return apps
    }

    private fun launchApp(context: Context, packageName: String?) {
        if (packageName.isNullOrEmpty()) return
        
        val pm = context.packageManager
        val intent = pm.getLaunchIntentForPackage(packageName)
        if (intent != null) {
            context.startActivity(intent)
        }
    }

    private fun closeApp(context: Context, packageName: String?) {
        if (packageName.isNullOrEmpty()) return
        
        val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        am.killBackgroundProcesses(packageName)
    }

    private fun getWiFiStatus(context: Context): Map<String, Any> {
        val wifiManager = context.getSystemService(Context.WIFI_SERVICE) as WifiManager
        val connectionInfo = wifiManager.connectionInfo
        
        return mapOf(
            "isEnabled" to wifiManager.isWifiEnabled,
            "ssid" to (connectionInfo?.ssid?.replace("\"", "") ?: "Not Connected"),
            "linkSpeed" to (connectionInfo?.linkSpeed ?: 0)
        )
    }

    private fun toggleWiFi(context: Context, enable: Boolean) {
        val wifiManager = context.getSystemService(Context.WIFI_SERVICE) as WifiManager
        wifiManager.isWifiEnabled = enable
    }

    private fun getBluetoothStatus(): Map<String, Any> {
        val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
        
        return mapOf(
            "isEnabled" to (bluetoothAdapter?.isEnabled ?: false),
            "deviceName" to (bluetoothAdapter?.name ?: "Unknown"),
            "pairedDevices" to (bluetoothAdapter?.bondedDevices?.size ?: 0)
        )
    }

    private fun toggleBluetooth(enable: Boolean) {
        val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
        if (enable) {
            bluetoothAdapter?.enable()
        } else {
            bluetoothAdapter?.disable()
        }
    }

    private fun sendSMS(phoneNumber: String?, message: String?) {
        if (phoneNumber.isNullOrEmpty() || message.isNullOrEmpty()) return
        
        val smsManager = SmsManager.getDefault()
        smsManager.sendTextMessage(phoneNumber, null, message, null, null)
    }

    private fun getContacts(context: Context): List<Map<String, String>> {
        val contacts = mutableListOf<Map<String, String>>()
        val cursor = context.contentResolver.query(
            ContactsContract.Contacts.CONTENT_URI,
            null,
            null,
            null,
            null
        )

        if (cursor != null && cursor.moveToFirst()) {
            do {
                val id = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts._ID))
                val name = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME))
                
                val phoneCursor = context.contentResolver.query(
                    ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                    null,
                    ContactsContract.CommonDataKinds.Phone.CONTACT_ID + " = ?",
                    arrayOf(id),
                    null
                )

                if (phoneCursor != null && phoneCursor.moveToFirst()) {
                    val phoneNumber = phoneCursor.getString(
                        phoneCursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)
                    )
                    contacts.add(mapOf(
                        "name" to name,
                        "phone" to phoneNumber
                    ))
                    phoneCursor.close()
                }
            } while (cursor.moveToNext())
            cursor.close()
        }

        return contacts
    }

    private fun openSettings(context: Context) {
        val intent = Intent(Settings.ACTION_SETTINGS)
        context.startActivity(intent)
    }
}
