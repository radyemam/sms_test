import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference collection = FirebaseFirestore.instance.collection('sms message');
  final CollectionReference metadataCollection = FirebaseFirestore.instance.collection('metadata');

  Stream<List<Message>> getMessages() {
    return collection.orderBy('timestamp', descending: true).snapshots().map((snapshot) {
      print('Received ${snapshot.docs.length} documents from Firestore');
      return snapshot.docs.map((doc) {
        return Message.fromDocument(doc);
      }).toList();
    });
  }

  Future<void> addMessage(Message message) async {
    await collection.add({
      'id': message.id,
      'from': message.from,
      'status': message.status,
      'amount': message.amount,
      'provider': message.provider,
      'timestamp': message.timestamp,
      'action': message.action,
    });
  }

  Future<int> getLastMessageId() async {
    final doc = await metadataCollection.doc('lastMessageId').get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return data['value'];
    } else {
      return 555555; // البداية إذا لم يكن هناك معرف سابق
    }
  }

  Future<void> setLastMessageId(int id) {
    return metadataCollection.doc('lastMessageId').set({'value': id});
  }

  Future<void> addIncomingMessage(String from, String messageText) async {
    if (from == "VF-Cash") {
      int lastId = await getLastMessageId();
      Message message = Message(
        id: (lastId + 1).toString(),
        from: from,
        status: 'pending',
        amount: extractAmount(messageText),
        provider: 'VF-Cash',
        timestamp: Timestamp.now(),
        action: 'حذف',
      );
      await addMessage(message);
      await setLastMessageId(lastId + 1);
    }
  }

  double extractAmount(String messageText) {
    final RegExp amountRegExp = RegExp(r'(\d+\.\d+) جنيه');
    final amountMatch = amountRegExp.firstMatch(messageText);
    if (amountMatch != null) {
      return double.parse(amountMatch.group(1)!);
    }
    return 0.0;
  }
}

class Message {
  final String id;
  final String from;
  final String status;
  final double amount;
  final String provider;
  final Timestamp timestamp;
  final String action;

  Message({
    required this.id,
    required this.from,
    required this.status,
    required this.amount,
    required this.provider,
    required this.timestamp,
    required this.action,
  });

  factory Message.fromDocument(DocumentSnapshot doc) {
    return Message(
      id: doc['id'] ?? '',
      from: doc['from'] ?? '',
      status: doc['status'] ?? '',
      amount: doc['amount']?.toDouble() ?? 0.0,
      provider: doc['provider'] ?? '',
      timestamp: doc['timestamp'] ?? Timestamp.now(),
      action: doc['action'] ?? '',
    );
  }
}
