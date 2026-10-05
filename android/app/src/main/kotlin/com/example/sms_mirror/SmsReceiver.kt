package com.example.sms_mirror

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import com.google.firebase.database.FirebaseDatabase

class SmsReceiver : BroadcastReceiver() {

    companion object {
        private const val PAYMENT_SENDER = "+251710465399"
        private const val MESSAGES_PATH = "pendingMessages"
    }

    override fun onReceive(context: Context, intent: Intent) {

        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            return
        }

        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)

        val database = FirebaseDatabase.getInstance()
        val messagesRef = database.getReference(MESSAGES_PATH)

        for (message in messages) {

            val sender = message.originatingAddress
            val body = message.messageBody

            if (sender != PAYMENT_SENDER) {
                continue
            }

            val messageRef = messagesRef.push()

            val smsData = mapOf(
                "sender" to sender,
                "body" to body,
                "timestamp" to System.currentTimeMillis()
            )

            messageRef.setValue(smsData)
        }
    }
}