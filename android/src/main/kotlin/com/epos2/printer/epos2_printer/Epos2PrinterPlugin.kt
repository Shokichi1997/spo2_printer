package com.epos2.printer.epos2_printer

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import androidx.annotation.NonNull
import com.epson.epos2.Epos2Exception
import com.epson.epos2.printer.Printer
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File


/** Epos2PrinterPlugin */
class Epos2PrinterPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var discoveryStreamHandler: DiscoveryStreamHandler
    private var mPrinter: Printer? = null
    private var mContext: Context? = null
    private var defaultPrinter = Printer.TM_M30
    private var defaultLang = Printer.LANG_JA
    private val DISCONNECT_INTERVAL = 500L //millseconds
    private lateinit var mFlutterPluginBinding: FlutterPlugin.FlutterPluginBinding

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "epos2_printer")
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "epos2_printer_event")
        mContext = flutterPluginBinding.applicationContext
        discoveryStreamHandler = DiscoveryStreamHandler(mContext)
        eventChannel.setStreamHandler(discoveryStreamHandler)
        mFlutterPluginBinding = flutterPluginBinding
        initializeObject()
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "connect" -> connectPrinter(call, result)
            "addText" -> addText(call, result)
            "addImage" -> addImage(call, result)
            "addFeedLine" -> addFeedLine(call, result)
            "disconnect" -> disconnect(call, result)
            "addTextSize" -> addTextSize(call, result)
            "addCut" -> addCut(call, result)
            "addTextAlign" -> addTextAlign(call, result)
            "isConnected" -> isConnected(call, result)
            "printData" -> printData(call, result)
            "addLineSpace" -> addLineSpace(call, result)
            "addTextFont" -> addTextFont(call, result)
            "stopFindPrinter" -> stopFindPrinter(call, result)
            "testPlugin" -> testPlugin(call, result)
            else -> result.notImplemented()
        }
    }

    private fun testPlugin(call: MethodCall, result: Result) {
        result.error("101", "xin chao", 1)
    }

    private fun stopFindPrinter(call: MethodCall, result: Result) {
        discoveryStreamHandler.stop()
    }

    private fun addTextFont(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<*, *> ?: return
        val font = args["font"] as? Int
        if (mPrinter == null) {
            result.error("101", "Printer not init yet.", null)
            return
        }
        try {
            mPrinter!!.addTextFont(font ?: Printer.FONT_A)
        } catch (e: Exception) {
            mPrinter?.clearCommandBuffer()
            ShowMsg.showException(e, "addTextFont", mContext)
            result.error("102", e.message, null)
        }
    }

    private fun addLineSpace(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<*, *> ?: return
        val lineSpace = args["lineSpace"] as? Int
        if (mPrinter == null) {
            result.error("101", "Printer not init yet.", null)
            return
        }
        try {
            mPrinter!!.addLineSpace(lineSpace ?: 1)
        } catch (e: Exception) {
            mPrinter?.clearCommandBuffer()
            ShowMsg.showException(e, "addLineSpace", mContext)
            result.error("102", e.message, null)
        }
    }

    private fun printData(call: MethodCall, result: Result) {
        if (mPrinter == null) {
            result.error("101", "Printer not init yet.", null)
            return
        }
        try {
            mPrinter!!.sendData(Printer.PARAM_DEFAULT)
        } catch (e: Exception) {
            mPrinter!!.clearCommandBuffer()
            ShowMsg.showException(e, "sendData", mContext)
            try {
                mPrinter!!.disconnect()
            } catch (e: Exception) {
            }
            result.error("104", "Can't not print data.", null)
        }
        result.success(true)
    }

    private fun disconnect(call: MethodCall, result: Result) {
        if (mPrinter == null) {
            return
        }
        while (true) {
            try {
                mPrinter!!.disconnect()
                break;
            } catch (e: Exception) {
                if (e is Epos2Exception) {
                    //Note: If printer is processing such as printing and so on, the disconnect API returns ERR_PROCESSING.
                    if (e.errorStatus == Epos2Exception.ERR_PROCESSING) {
                        try {
                            Thread.sleep(DISCONNECT_INTERVAL)
                        } catch (e: Exception) {
                        }
                    } else {
                        result.error("103", e.message, null)
                        break
                    }
                } else {
                    result.error("103", e.message, null)
                    break
                }
            }
        }
        mPrinter!!.clearCommandBuffer()
    }

    private fun isConnected(call: MethodCall, result: Result) {
        if (mPrinter == null) {
            result.error("101", "Printer not init yet.", null)
            return
        }
        val status = mPrinter!!.status
        result.success(status.connection)
    }

    private fun addTextAlign(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<*, *> ?: return
        val align = args["align"] as? Int
        if (mPrinter == null) {
            result.error("101", "Printer not init yet.", null)
            return
        }
        try {
            mPrinter!!.addTextAlign(align ?: Printer.ALIGN_LEFT)
        } catch (e: Exception) {
            mPrinter?.clearCommandBuffer()
            ShowMsg.showException(e, "addTextAlign", mContext)
            result.error("102", e.message, null)
        }
    }

    private fun addCut(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<*, *> ?: return
        val type = args["type"] as? Int
        if (mPrinter == null) {
            result.error("101", "Printer not init yet.", null)
            return
        }
        try {
            mPrinter!!.addCut(type ?: Printer.CUT_FEED)
        } catch (e: Exception) {
            mPrinter?.clearCommandBuffer()
            ShowMsg.showException(e, "addCut", mContext)
            result.error("102", e.message, null)
        }
    }

    private fun addTextSize(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<*, *> ?: return
        val width = args["width"] as? Int
        val height = args["height"] as? Int
        if (mPrinter == null) {
            result.error("101", "Printer not init yet.", null)
            return
        }
        try {
            mPrinter!!.addTextSize(width ?: 1, height ?: 1)
        } catch (e: Exception) {
            mPrinter?.clearCommandBuffer()
            ShowMsg.showException(e, "addTextSize", mContext)
            result.error("102", e.message, null)
        }
    }

    private fun addFeedLine(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<*, *> ?: return
        val line = args["line"] as? Int
        if (mPrinter == null) {
            result.error("101", "Printer not init yet.", null)
            return
        }
        try {
            mPrinter!!.addFeedLine(line ?: 1)
        } catch (e: Exception) {
            mPrinter?.clearCommandBuffer()
            ShowMsg.showException(e, "addFeedLine", mContext)
            result.error("102", e.message, null)
        }
    }

    private fun addImage(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<*, *> ?: return
        val imagePath = args["imagePath"] as String
        val x = args["x"] as? Int
        val y = args["y"] as? Int
        val width = args["width"] as? Int
        val height = args["height"] as? Int
        val color = args["color"] as? Int
        val mode = args["mode"] as? Int
        val halfTone = args["halfTone"] as? Int
        val brightness = args["brightness"] as? Double
        val compress = args["compress"] as? Int

        if (mPrinter == null) {
            result.error("101", "Printer not init yet.", null)
            return
        }
        val filePath = mFlutterPluginBinding.flutterAssets.getAssetFilePathByName(imagePath)
        val imageFile = File(filePath)
        val bmOptions: BitmapFactory.Options = BitmapFactory.Options()
        val bitmap = BitmapFactory.decodeFile(imageFile.absolutePath, bmOptions)
        try {
            mPrinter!!.addImage(
                bitmap,
                x ?: 0,
                y ?: 0,
                width ?: bitmap.width,
                height ?: bitmap.height,
                color ?: Printer.PARAM_DEFAULT,
                mode ?: Printer.PARAM_DEFAULT,
                halfTone ?: Printer.PARAM_DEFAULT,
                brightness ?: Printer.PARAM_DEFAULT.toDouble(),
                compress ?: Printer.PARAM_DEFAULT
            )
        } catch (e: Exception) {
            mPrinter?.clearCommandBuffer()
            ShowMsg.showException(e, "addText", mContext)
            result.error("102", e.message, null)
        }
    }

    private fun addText(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<*, *> ?: return
        val text = args["text"] as String
        if (mPrinter == null) {
            result.error("101", "Printer not init yet.", null)
            return
        }
        try {
            mPrinter!!.addText(text)
        } catch (e: Exception) {
            mPrinter?.clearCommandBuffer()
            ShowMsg.showException(e, "addText", mContext)
            result.error("102", e.message, null)
        }
    }

    private fun initializeObject(): Boolean {
        try {
            mPrinter = Printer(defaultPrinter, defaultLang, mContext)
//            mPrinter!!.setReceiveEventListener(this)
        } catch (e: Exception) {
            ShowMsg.showException(e, "Printer", mContext)
            return false
        }
        return true
    }

    private fun connectPrinter(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<*, *> ?: return
        val printerAddress = args["address"] as String
        if (mPrinter == null) {
            result.error("102", "Printer not init yet", null)
            return
        }
        try {
            mPrinter!!.connect(printerAddress, Printer.PARAM_DEFAULT)
        } catch (e: Exception) {
            ShowMsg.showException(e, "connect", mContext)
            result.error("103", e.message, null)
            return
        }
        result.success("Connect successful")
    }
}
