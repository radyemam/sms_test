import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firestore_service.dart';

class MessagesPage extends StatelessWidget {
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الرسايل'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'بحث عن معاملة',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Add filter logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                  child: Text(
                    'تصفية',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Add export logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                  child: Text(
                    'تصدير',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/new_message');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                  child: Text(
                    'إضافة معاملة',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<Message>>(
                stream: firestoreService.getMessages(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('لا توجد بيانات'));
                  }

                  final messages = snapshot.data!..sort((a, b) => b.timestamp.compareTo(a.timestamp));

                  return SingleChildScrollView(
                    child: Table(
                      border: TableBorder.all(color: Colors.grey),
                      columnWidths: {
                        0: FixedColumnWidth(50.0),
                        1: FixedColumnWidth(150.0),
                        2: FixedColumnWidth(150.0),
                        3: FixedColumnWidth(100.0),
                        4: FixedColumnWidth(100.0),
                        5: FixedColumnWidth(150.0),
                        6: FixedColumnWidth(150.0),
                        7: FixedColumnWidth(150.0),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey[800]),
                          children: [
                            TableCell(child: Padding(padding: const EdgeInsets.all(8.0), child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold)))),
                            TableCell(child: Padding(padding: const EdgeInsets.all(8.0), child: Text('من', style: TextStyle(fontWeight: FontWeight.bold)))),
                            TableCell(child: Padding(padding: const EdgeInsets.all(8.0), child: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold)))),
                            TableCell(child: Padding(padding: const EdgeInsets.all(8.0), child: Text('المبلغ', style: TextStyle(fontWeight: FontWeight.bold)))),
                            TableCell(child: Padding(padding: const EdgeInsets.all(8.0), child: Text('المزود', style: TextStyle(fontWeight: FontWeight.bold)))),
                            TableCell(child: Padding(padding: const EdgeInsets.all(8.0), child: Text('التاريخ', style: TextStyle(fontWeight: FontWeight.bold)))),
                            TableCell(child: Padding(padding: const EdgeInsets.all(8.0), child: Text('الإجراء', style: TextStyle(fontWeight: FontWeight.bold)))),
                          ],
                        ),
                        ...messages.map((message) {
                          return TableRow(
                            children: [
                              TableCell(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(message.id))),
                              TableCell(child: Padding(padding: const EdgeInsets.all(8.0), child: Row(
                                children: [
                                  Text(message.from),
                                  IconButton(
                                    icon: Icon(Icons.copy),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: message.from));
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم النسخ')));
                                    },
                                  ),
                                ],
                              ))),
                              TableCell(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(message.status, style: TextStyle(color: message.status == 'pending' ? Colors.orange : Colors.green)))),
                              TableCell(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(message.amount.toString()))),
                              TableCell(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(message.provider))),
                              TableCell(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(message.timestamp.toDate().toString()))),
                              TableCell(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(message.action))),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
