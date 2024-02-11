package com.blackstackhub.folderpicker

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.DocumentsContract
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

import android.content.Intent
import androidx.documentfile.provider.DocumentFile


class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.blackstackhub.folderpicker"
    private val PERMISSIONS = arrayOf(android.Manifest.permission.WRITE_EXTERNAL_STORAGE, android.Manifest.permission.READ_EXTERNAL_STORAGE)
    private val TAG = "MainActivity"
    private val PICK_DIRECTORY_REQUEST_CODE = 123
    private var STATUS_DIRECTORY: DocumentFile? = null
    private val BASE_DIRECTORY: Uri = Uri.fromFile(File("/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses/"))

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isPermissionGranted" -> {
                    result.success(isPermissionGranted())
                }
                "requestSpecificFolderAccess" -> {
                    result.success(requestSpecificFolderAccess())
                }
                "fetchFilesFromDirectory" -> {
                    result.success(fetchFilesFromDirectory())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun isPermissionGranted(): Boolean {
        Log.d(TAG, "isPermissionGranted: $STATUS_DIRECTORY")
        return STATUS_DIRECTORY != null && STATUS_DIRECTORY!!.canWrite() && STATUS_DIRECTORY!!.canRead()
    }

    private fun requestSpecificFolderAccess(): Boolean {
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
        intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, BASE_DIRECTORY)
        startActivityForResult(intent, PICK_DIRECTORY_REQUEST_CODE)
        return true
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, resultData: Intent?) {
        super.onActivityResult(requestCode, resultCode, resultData)
        if (requestCode == PICK_DIRECTORY_REQUEST_CODE && resultCode == Activity.RESULT_OK) {
            val treeUri: Uri? = resultData?.data
            treeUri?.let {
                contentResolver.takePersistableUriPermission(
                    it,
                    Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                )
                STATUS_DIRECTORY = DocumentFile.fromTreeUri(this, it)
            }
        }
    }

    private fun fetchFilesFromDirectory(): List<String> {
        val statusFileNames = mutableListOf<String>()
        Log.d(TAG, "STATUS_DIRECTORY: $STATUS_DIRECTORY")
        STATUS_DIRECTORY?.let { rootDirectory ->
            rootDirectory.listFiles()?.forEach { file ->
                if (file.isFile && file.canRead()) {
                    statusFileNames.add(file.uri.toString())
                }
            }
        }

        return statusFileNames
    }
}


// https://github.com/dart-lang/sdk/issues/54878