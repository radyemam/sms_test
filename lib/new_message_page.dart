import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';

class NewMessagePage extends StatelessWidget {
  final TextEditingController messageController = TextEditingController();
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة رسالة جديدة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: messageController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'أدخل نص الرسالة هنا',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[800],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String message = messageController.text;
                try {
                  Map<String, dynamic> parsedMessage = parseMessage(message);
                  int lastId = await firestoreService.getLastMessageId(); // الحصول على آخر معرف
                  firestoreService.addMessage(Message(
                    id: (lastId + 1).toString(), // استخدام معرف متسلسل
                    from: parsedMessage['from'],
                    status: 'pending',
                    amount: parsedMessage['amount'],
                    provider: 'VF-Cash',
                    timestamp: parsedMessage['timestamp'],
                    action: parsedMessage['action'],
                  ));
                  firestoreService.setLastMessageId(lastId + 1); // تحديث آخر معرف
                  Navigator.pop(context);
                } catch (e) {
                  print('Error parsing message: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> parseMessage(String message) {
    final RegExp amountRegExp = RegExp(r'تم استلام مبلغ (\d+\.\d+) جنيه');
    final RegExp fromRegExp = RegExp(r'من رقم (\d+)\؛');
    final RegExp timestampRegExp = RegExp(r'تاريخ العملية (.+?) رقم العملية');
    final RegExp idRegExp = RegExp(r'رقم العملية (\d+)\.');

    final amountMatch = amountRegExp.firstMatch(message);
    final fromMatch = fromRegExp.firstMatch(message);
    final timestampMatch = timestampRegExp.firstMatch(message);
    final idMatch = idRegExp.firstMatch(message);

    if (amountMatch == null || fromMatch == null || timestampMatch == null || idMatch == null) {
      throw Exception('Failed to parse message');
    }

    final String amountString = amountMatch.group(1)!;
    final String from = fromMatch.group(1)!;
    final String timestampString = timestampMatch.group(1)!.trim().replaceAll('‎', '');

    final double amount = double.parse(amountString);

    final List<String> dateTimeParts = timestampString.split(' ');
    final List<String> dateParts = dateTimeParts[0].split('-');
    final String formattedDate = '20${dateParts[2]}-${dateParts[1]}-${dateParts[0]}';
    final String formattedTimestamp = '$formattedDate ${dateTimeParts[1]}:00Z';

    final DateTime timestamp = DateTime.parse(formattedTimestamp);

    return {
      'amount': amount,
      'from': from,
      'timestamp': Timestamp.fromDate(timestamp),
      'id': '', // سيُملأ لاحقاً
      'action': 'حذف',
    };
  }
}
