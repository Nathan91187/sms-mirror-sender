import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'model/sms_message.dart';

  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(const SmsMirrorApp());
  }


class SmsMirrorApp extends StatelessWidget {
  const SmsMirrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SmsScreen(),
    );
  }
}

class SmsScreen extends StatefulWidget {
  const SmsScreen({super.key});

  @override
  State<SmsScreen> createState() => _SmsScreenState();
}

class _SmsScreenState extends State<SmsScreen> {
  final DatabaseReference messagesRef =
  FirebaseDatabase.instance.ref('messages');
  static const EventChannel smsChannel =
  EventChannel('sms_mirror/sms');

  final List<SmsMessage> messages = [];

  @override
  void initState() {
    super.initState();

    smsChannel.receiveBroadcastStream().listen((event) {
      final sms = SmsMessage(
        sender: event['sender'],
        body: event['body'],
        receivedAt: DateTime.now(),
      );

      setState(() {
        messages.insert(0, sms);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Mirror'),
      ),
      body: messages.isEmpty
          ? const Center(
        child: Text('Waiting for payment SMS...'),
      )
          : ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final sms = messages[index];

          return ListTile(
            title: Text(sms.sender),
            subtitle: Text(sms.body),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await messagesRef.push().set({
            'sender': '+251710465399',
            'body': 'Test payment message 11',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        },
        child: const Icon(Icons.send),
      ),
    );
  }
}