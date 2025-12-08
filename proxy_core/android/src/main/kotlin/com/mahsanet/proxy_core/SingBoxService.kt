package com.mahsanet.proxy_core

import android.content.Context
import android.os.ParcelFileDescriptor
import android.util.Log
import io.nekohasekai.libbox.*

/**
 * SingBox service wrapper for Android VPN integration.
 * Uses libbox.aar built from sing-box project.
 */
class SingBoxService(private val context: Context) {
    
    companion object {
        private const val TAG = "SingBoxService"
        
        @Volatile
        private var instance: BoxService? = null
    }
    
    private var platformInterface: SingBoxPlatformInterface? = null
    
    /**
     * Start SingBox with the given configuration
     * @param configContent JSON configuration content
     * @param tunFd File descriptor for TUN interface
     * @return true if started successfully
     */
    fun start(configContent: String, tunFd: Int): Boolean {
        try {
            Log.d(TAG, "Starting SingBox service...")
            
            // Create platform interface
            platformInterface = SingBoxPlatformInterface(context, tunFd)
            
            // Create and start service
            instance = Libbox.newService(configContent, platformInterface)
            instance?.start()
            
            Log.d(TAG, "SingBox service started successfully")
            return true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start SingBox: ${e.message}", e)
            return false
        }
    }
    
    /**
     * Stop SingBox service
     */
    fun stop() {
        try {
            Log.d(TAG, "Stopping SingBox service...")
            instance?.close()
            instance = null
            platformInterface = null
            Log.d(TAG, "SingBox service stopped")
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping SingBox: ${e.message}", e)
        }
    }
    
    /**
     * Check if SingBox is running
     */
    fun isRunning(): Boolean {
        return instance != null
    }
}

/**
 * Platform interface implementation for SingBox on Android
 * Matches libbox v1.12.x PlatformInterface
 */
class SingBoxPlatformInterface(
    private val context: Context,
    private val tunFd: Int
) : PlatformInterface {
    
    companion object {
        private const val TAG = "SingBoxPlatform"
    }
    
    // LocalDNSTransport implementation
    override fun localDNSTransport(): LocalDNSTransport {
        return object : LocalDNSTransport {
            override fun raw(): Boolean = false
            
            override fun lookup(ctx: ExchangeContext?, network: String?, domain: String?) {
                // Simple lookup - set empty result
                ctx?.success("")
            }
            
            override fun exchange(ctx: ExchangeContext?, message: ByteArray?) {
                // Not supported in simple mode
                ctx?.errorCode(1, "Not supported")
            }
        }
    }
    
    override fun autoDetectInterfaceControl(fd: Int) {
        // Mark socket to bypass VPN
        try {
            val vpnService = context as? android.net.VpnService
            vpnService?.protect(fd)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to protect socket: ${e.message}")
        }
    }
    
    override fun openTun(options: TunOptions?): Int {
        Log.d(TAG, "OpenTun called, returning fd: $tunFd")
        return tunFd
    }
    
    override fun usePlatformAutoDetectInterfaceControl(): Boolean = true
    
    override fun useProcFS(): Boolean = false
    
    override fun findConnectionOwner(
        ipProtocol: Int,
        sourceAddress: String?,
        sourcePort: Int,
        destinationAddress: String?,
        destinationPort: Int
    ): Int {
        // Return -1 to indicate we don't have this info
        return -1
    }
    
    override fun packageNameByUid(uid: Int): String? {
        return try {
            context.packageManager.getPackagesForUid(uid)?.firstOrNull()
        } catch (e: Exception) {
            null
        }
    }
    
    override fun uidByPackageName(packageName: String?): Int {
        return try {
            packageName?.let {
                context.packageManager.getPackageUid(it, 0)
            } ?: -1
        } catch (e: Exception) {
            -1
        }
    }
    
    override fun writeLog(message: String?) {
        Log.d(TAG, "SingBox: $message")
    }
    
    override fun startDefaultInterfaceMonitor(listener: InterfaceUpdateListener?) {}
    
    override fun closeDefaultInterfaceMonitor(listener: InterfaceUpdateListener?) {}
    
    override fun getInterfaces(): NetworkInterfaceIterator? = null
    
    override fun underNetworkExtension(): Boolean = false
    
    override fun includeAllNetworks(): Boolean = false
    
    override fun clearDNSCache() {}
    
    override fun readWIFIState(): WIFIState? = null
    
    override fun systemCertificates(): StringIterator? = null
    
    override fun sendNotification(notification: Notification?) {}
}
