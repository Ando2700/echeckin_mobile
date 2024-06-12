import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://qmdsfldfrwhdfdwukqnz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFtZHNmbGRmcndoZGZkd3VrcW56Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTM4NTU0OTksImV4cCI6MjAyOTQzMTQ5OX0.SZJuewMx7l6jzfbfqSAdzaJLM-b2Nwt_02qxn_pxT1I',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Echeck-in QR Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Echeck-in QR Scanner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String qrResult = "Vous n'avez pas scanné de QR";

  bool _isLoading = false;

  Future<void> _scanQRCode(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const ScannerPage()),
    );

    if (result != null) {
      final qrData = _parseQRResult(result);
      if (qrData != null) {
        final supabaseClient = Supabase.instance.client;
        try {
          await supabaseClient
              .from('presences')
              .select('id')
              .eq('attendee_id', qrData.attendeeId)
              .eq('event_id', qrData.eventId)
              .single();

          final attendee = await _getAttendee(qrData.attendeeId);
          setState(() {
            qrResult =
                'Le code QR a déjà été scanné pour ${attendee.firstname} ${attendee.lastname}';
            _isLoading = false;
          });
        } catch (e) {
          setState(() {
            qrResult = 'La sauvegarde des données...';
          });
          await _saveDataToDatabase(qrData);
          final attendee = await _getAttendee(qrData.attendeeId);
          setState(() {
            qrResult =
                'Données enregistrées avec succès : Bienvenue ${attendee.firstname} ${attendee.lastname}!';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          qrResult = 'Données de code QR invalides';
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        qrResult = 'Aucune donnée dans QR';
        _isLoading = false;
      });
    }
  }

  QrData? _parseQRResult(String result) {
    final parts = result.split('\n');
    if (parts.length == 3) {
      final reference = parts[0].split(': ')[1];
      final eventId = parts[1].split(': ')[1];
      final attendeeId = parts[2].split(': ')[1];
      return QrData(reference, eventId, attendeeId);
    }
    return null;
  }

  Future<void> _saveDataToDatabase(QrData qrData) async {
    try {
      final supabaseClient = Supabase.instance.client;
      final data = {
        'reference': qrData.reference,
        'event_id': qrData.eventId,
        'attendee_id': qrData.attendeeId,
        'date_heure_presence': DateTime.now().toIso8601String(),
      };
      await supabaseClient.from('presences').insert(data);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la sauvegarde des données: $e');
      }
    }
  }

  Future<Attendee> _getAttendee(String attendeeId) async {
    final supabaseClient = Supabase.instance.client;
    final response = await supabaseClient
        .from('attendees')
        .select('firstname, lastname')
        .eq('id', attendeeId)
        .single();

    return Attendee(
      firstname: response['firstname'],
      lastname: response['lastname'],
    );
  }

  Widget _buildResultWidget() {
    IconData iconData;
    Color iconColor;

    if (qrResult.contains('Le code QR a déjà été scanné')) {
      iconData = Icons.clear;
      iconColor = Colors.red;
    } else if (qrResult.contains('Données enregistrées avec succès')) {
      iconData = Icons.check;
      iconColor = Colors.green;
    } else {
      iconData = Icons.error;
      iconColor = Colors.grey;
    }

    return Column(
      children: [
        Icon(
          iconData,
          color: iconColor,
          size: 48,
        ),
        Text(
          qrResult,
          style: TextStyle(
            fontSize: 18,
            color: iconColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildResultWidget(),
            _isLoading
                ? const CircularProgressIndicator()
                : const SizedBox.shrink(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _scanQRCode(context),
        tooltip: 'Scan QR',
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}

class Attendee {
  Attendee({required this.firstname, required this.lastname});
  final String firstname;
  final String lastname;
}

class QrData {
  QrData(this.reference, this.eventId, this.attendeeId);
  final String reference;
  final String eventId;
  final String attendeeId;
}
