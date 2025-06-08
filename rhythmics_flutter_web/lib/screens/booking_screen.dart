import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rhythmics_flutter_web/services/auth_service.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  final String token;
  final int studioId;

  const BookingScreen({
    Key? key,
    required this.token,
    required this.studioId,
  }) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDate;
  final TextEditingController _timeSlotCtrl = TextEditingController();
  final TextEditingController _roomNameCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _timeSlotCtrl.dispose();
    _roomNameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      setState(() {
        _errorMessage = 'Silakan pilih tanggal booking.';
      });
      return;
    }

    final timeSlot = _timeSlotCtrl.text.trim();
    final roomName = _roomNameCtrl.text.trim();
    final price = _priceCtrl.text.trim();

    if (timeSlot.isEmpty || roomName.isEmpty || price.isEmpty) {
      setState(() {
        _errorMessage = 'Semua field harus diisi.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Format tanggal: yyyy-MM-dd
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    try {
      final response = await AuthService.createBooking(
        token: widget.token,
        studioId: widget.studioId,
        date: formattedDate,
        timeSlot: timeSlot,
        roomName: roomName,
        price: price,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking berhasil!'),
            backgroundColor: Colors.green,
          ),
        );
        // Kembali ke Home setelah 500ms
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
            arguments: {'token': widget.token},
          );
        });
      } else if (response.statusCode == 401) {
        // Token expired or invalid, force re-login
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sesi Habis'),
            content: const Text('Sesi Anda telah habis. Silakan login kembali.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        final bodyJson = jsonDecode(response.body);
        final errorMsg = bodyJson['errors'] ??
            (bodyJson['data'] == null ? 'Booking gagal, silakan coba lagi.' : null);
        setState(() {
          _errorMessage = errorMsg ?? 'Booking gagal.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Kesalahan koneksi: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _selectedDate == null
        ? 'Pilih Tanggal'
        : DateFormat('yyyy-MM-dd').format(_selectedDate!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Booking'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.red.shade100,
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pilih Tanggal
                  TextButton(
                    onPressed: _pickDate,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      backgroundColor: Colors.indigo.shade50,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(dateText, style: const TextStyle(fontSize: 16)),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Time Slot (user harus mengetik string persis seperti '09:00-12:00')
                  TextFormField(
                    controller: _timeSlotCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Time Slot (misal: 09:00-12:00)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Time Slot tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Room Name (harus sesuai Room.type di database, misal: "Standard" atau "VIP")
                  TextFormField(
                    controller: _roomNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Room Name (misal: Standard)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Room Name tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Price (user input string harga, misal: "150000")
                  TextFormField(
                    controller: _priceCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Harga (dalam rupiah, misal: 150000)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Harga tidak boleh kosong';
                      }
                      if (int.tryParse(val) == null) {
                        return 'Harga harus angka valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Tombol Submit
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitBooking,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: Text(
                                'Submit Booking',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
