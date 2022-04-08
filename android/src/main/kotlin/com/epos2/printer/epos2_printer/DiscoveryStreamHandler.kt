package com.epos2.printer.epos2_printer

import android.content.Context
import com.epson.epos2.Epos2Exception
import com.epson.epos2.discovery.Discovery
import com.epson.epos2.discovery.FilterOption
import io.flutter.plugin.common.EventChannel

class DiscoveryStreamHandler(private var mContext: Context?) : EventChannel.StreamHandler {
    private val mPrinterList: ArrayList<HashMap<String, String>> = arrayListOf()
    private var mFilterOption: FilterOption? = null
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        getPrinters(arguments, events)
    }

    override fun onCancel(arguments: Any?) {}

    private fun getPrinters(arguments: Any?, events: EventChannel.EventSink?) {
        if (mFilterOption == null) {
            init()
        }
        Discovery.start(mContext, mFilterOption) {
            val item = java.util.HashMap<String, String>()
            item["PrinterName"] = it.deviceName
            item["Target"] = it.target
            mPrinterList.add(item)
            events?.success(mPrinterList)
        }
    }

    private fun init() {
        mFilterOption = FilterOption()
        mFilterOption!!.deviceType = Discovery.TYPE_PRINTER
        mFilterOption!!.epsonFilter = Discovery.FILTER_NAME
    }

    fun stop() {
        while (true) {
            try {
                Discovery.stop();
                break
            } catch (e: Epos2Exception) {
                if (e.errorStatus != Epos2Exception.ERR_PROCESSING) {
                    break
                }
            }
        }
        mFilterOption = null
    }

}
