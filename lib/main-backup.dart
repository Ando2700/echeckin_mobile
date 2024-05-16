// import 'package:flutter/material.dart';
// // import 'package:qr_code_scanner/connexion.dart';
// import 'package:qr_code_scanner/scanner.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// void main() async {
//   await Supabase.initialize(
//     url: 'https://qmdsfldfrwhdfdwukqnz.supabase.co',
//     anonKey:
//         'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFtZHNmbGRmcndoZGZkd3VrcW56Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTM4NTU0OTksImV4cCI6MjAyOTQzMTQ5OX0.SZJuewMx7l6jzfbfqSAdzaJLM-b2Nwt_02qxn_pxT1I',
//   );
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'QR Code Scanner',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'QR Code Scanner'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   String qrResult = "You have not scanned a QR";
//   final _attendee = Supabase.instance.client
//     .from('attendees')
//     .select();

//   _scanQRCode(BuildContext context) async {
//     final result = await Navigator.push<String>(
//         context, MaterialPageRoute(builder: (context) => const ScannerPage()));
//     setState(() {
//       qrResult = result ?? 'No data in QR';
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(qrResult),
//             Text(_attendee),
//           ],
//         ),
//       ),
      
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _scanQRCode(context),
//         tooltip: 'Scan QR',
//         child: const Icon(Icons.qr_code_scanner_outlined),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';


// class ScannerPage extends StatefulWidget {
//   const ScannerPage({super.key});

//   @override
//   State<ScannerPage> createState() => _ScannerPageState();
// }

// class _ScannerPageState extends State<ScannerPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('QR Scanner')),
//       body: SizedBox(
//         height: 400,
//         child: MobileScanner(onDetect: (capture) {
//           final List<Barcode> barcodes = capture.barcodes;
//           for (final barcode in barcodes) {
//             Navigator.canPop(context) ? Navigator.pop<String>(context, barcode.rawValue ?? 'No data in QR') : null;
//           }
//         }),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class ScannerPage extends StatefulWidget {
//   const ScannerPage({super.key});

//   @override
//   State<ScannerPage> createState() => _ScannerPageState();
// }

// class _ScannerPageState extends State<ScannerPage> {
//   final _supabaseClient = Supabase.instance.client;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('QR Scanner')),
//       body: _buildScannerBody(context),
//     );
//   }

//   Widget _buildScannerBody(BuildContext context) {
//     return SizedBox(
//       height: 400,
//       child: MobileScanner(
//         onDetect: _handleQrDetection,
//       ),
//     );
//   }

//   void _handleQrDetection(BarcodeCapture capture) async {
//     final List<Barcode> barcodes = capture.barcodes;
//     for (final barcode in barcodes) {
//       final String? qrData = barcode.rawValue;
//       if (qrData!= null) {
//         final Map<String, dynamic>? data = _parseQrData(qrData);
//         if (data!= null) {
//           await _insertDataIntoDatabase(data);
//           Navigator.pop<String>(context, qrData);
//         } else {
//           _showErrorSnackBar(context, 'Invalid QR data');
//         }
//       } else {
//         _showErrorSnackBar(context, 'No data in QR');
//       }
//     }
//   }

//   Map<String, dynamic>? _parseQrData(String qrData) {
//     const expectedPartsCount = 3;
//     final parts = qrData.split('\n');
//     if (parts.length!= expectedPartsCount) return null;
//     final reference = parts[0].split(': ')[1];
//     final eventId = int.parse(parts[1].split(': ')[1]);
//     final attendeeId = int.parse(parts[2].split(': ')[1]);
//     return {
//       'Reference': reference,
//       'EventID': eventId,
//       'AttendeeID': attendeeId,
//     };
//   }

//   Future<void> _insertDataIntoDatabase(Map<String, dynamic> data) async {
//     final DateTime now = DateTime.now();
//     final response = await _supabaseClient.from('presences').insert({
//       'reference': data['reference'],
//       'eventId': data['eventId'],
//       'attendeeId': data['attendeeId'],
//       'date_heure_presence': now.toIso8601String(),
//     });
//     if (response.error!= null) {
//       _showErrorSnackBar(context, 'Error inserting data: ${response.error}');
//     }
//   }

//   void _showErrorSnackBar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }
// }

// METY _saving
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:qr_code_scanner/scanner.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// void main() async {
//   await Supabase.initialize(
//     url: 'https://qmdsfldfrwhdfdwukqnz.supabase.co',
//     anonKey:
//         'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFtZHNmbGRmcndoZGZkd3VrcW56Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTM4NTU0OTksImV4cCI6MjAyOTQzMTQ5OX0.SZJuewMx7l6jzfbfqSAdzaJLM-b2Nwt_02qxn_pxT1I',
//   );
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'QR Code Scanner',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'QR Code Scanner'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   String qrResult = "You have not scanned a QR";

//   bool _saving = false;

//   Future<void> _scanQRCode(BuildContext context) async {
//     final result = await Navigator.push<String>(
//         context, MaterialPageRoute(builder: (context) => const ScannerPage()));
//     if (result != null) {
//       final qrData = _parseQRResult(result);
//       if (qrData != null) {
//         setState(() {
//           _saving = true;
//           qrResult = 'Saving data...';
//         });
//         await _saveDataToDatabase(qrData);
//         setState(() {
//           _saving = false;
//           qrResult = 'Data saved successfully!';
//         });
//       } else {
//         setState(() {
//           qrResult = 'Invalid QR code data';
//         });
//       }
//     } else {
//       setState(() {
//         qrResult = 'No data in QR';
//       });
//     }
//   }

//   QrData? _parseQRResult(String result) {
//     final parts = result.split('\n');
//     if (parts.length == 3) {
//       final reference = parts[0].split(': ')[1];
//       final eventId = parts[1].split(': ')[1];
//       final attendeeId = parts[2].split(': ')[1];
//       return QrData(reference, eventId, attendeeId);
//     }
//     return null;
//   }

//   Future<void> _saveDataToDatabase(QrData qrData) async {
//     try {
//       final supabaseClient = Supabase.instance.client;
//       final data = {
//         'reference': qrData.reference,
//         'event_id': qrData.eventId,
//         'attendee_id': qrData.attendeeId,
//         'date_heure_presence': DateTime.now().toIso8601String(),
//       };
//       await supabaseClient.from('presences').insert(data);
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error saving data to database: $e');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             _saving ? const CircularProgressIndicator() : Text(qrResult),
//             _saving
//                 ? const SizedBox.shrink()
//                 : qrResult == 'Data saved successfully!'
//                     ? const Icon(Icons.check, color: Colors.green)
//                     : const SizedBox.shrink(),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _scanQRCode(context),
//         tooltip: 'Scan QR',
//         child: const Icon(Icons.qr_code_scanner),
//       ),
//     );
//   }
// }

// class QrData {
//   QrData(this.reference, this.eventId, this.attendeeId);
//   final String reference;
//   final String eventId;
//   final String attendeeId;
// }
