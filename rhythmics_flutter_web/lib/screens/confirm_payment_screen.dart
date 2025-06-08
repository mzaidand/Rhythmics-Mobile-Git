import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rhythmics_flutter_web/services/auth_service.dart';

class ConfirmPaymentScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> studio;
  final String room;
  final String date;
  final String time;
  final int price;
  final double taxPrice;
  final double totalPrice;
  final Map<String, String> selectedPaymentMethod;
  final Map<String, String> formData;

  const ConfirmPaymentScreen({
    Key? key,
    required this.token,
    required this.studio,
    required this.room,
    required this.date,
    required this.time,
    required this.price,
    required this.taxPrice,
    required this.totalPrice,
    required this.selectedPaymentMethod,
    required this.formData,
  }) : super(key: key);

  @override
  State<ConfirmPaymentScreen> createState() => _ConfirmPaymentScreenState();
}

class _ConfirmPaymentScreenState extends State<ConfirmPaymentScreen> {
  bool _isChecked = false;
  bool _isSubmitting = false;
  String _vaNumber = "";

  @override
  void initState() {
    super.initState();
    _vaNumber = _getVirtualAccountNumber(widget.selectedPaymentMethod);
  }

  // Fungsi untuk generate nomor virtual account berdasarkan method
  String _getVirtualAccountNumber(Map<String, String> pm) {
    final method = pm['method'] ?? "";
    const virtualAccounts = {
      "BCA": "VA-BCA-123456",
      "BNI": "VA-BNI-789012",
      "Mandiri": "VA-Mandiri-345678",
      "BSI": "VA-BSI-567890",
      "GoPay": "EW-GoPay-123456",
      "OVO": "EW-OVO-789012",
      "ShopeePay": "EW-ShopeePay-345678",
      "Visa": "CC-Visa-123456",
      "MasterCard": "CC-Mastercard-789012",
    };
    return virtualAccounts[method] ?? "Not available";
  }

  Future<void> _handleNext() async {
    if (!_isChecked) {
      _showAlert("Harap menyetujui syarat dan ketentuan sebelum melanjutkan.");
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Prepare payload untuk backend:
    final bookingData = {
      'date': widget.date, // "yyyy-MM-dd"
      'time_slot': widget.time, // ex: "09:00-12:00"
      'room_name': widget.room, // ex: "Standard"
      'price': widget.totalPrice.toString(), // total (string)
    };

    try {
      final response = await AuthService.createBooking(
        token: widget.token,
        studioId: widget.studio['id'] as int,
        date: widget.date,
        timeSlot: widget.time,
        roomName: widget.room,
        price: widget.totalPrice.toString(),
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/booking-success');
      } else if (response.statusCode == 401) {
        // Token expired or invalid, force re-login
        _showAlert('Sesi Anda telah habis. Silakan login kembali.');
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        });
      } else {
        final bodyJson = jsonDecode(response.body);
        final errorMsg = bodyJson['errors'] ??
            (bodyJson['data'] == null ? 'Booking gagal, coba lagi.' : null);
        _showAlert(errorMsg ?? 'Booking gagal, coba lagi.');
      }
    } catch (e) {
      _showAlert("Kesalahan koneksi: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Peringatan"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  String _formatDateHuman(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('EEEE, d MMMM yyyy', 'en_US').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final studioName = widget.studio['name'] as String? ?? "";
    final formattedTax =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
            .format(widget.taxPrice);
    final formattedTotal =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
            .format(widget.totalPrice);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Payment'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Left Side: Booking Information & Checkbox ===
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "1. Customer Detail and Payment Option",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Booking Information",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Ruangan ${widget.room}",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                        Text(
                          studioName,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _formatDateHuman(widget.date),
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                        Text(
                          widget.time,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _isChecked,
                        onChanged: (val) {
                          setState(() {
                            _isChecked = val ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          "Saya telah membaca dan menyetujui Syarat dan Ketentuan yang berlaku",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Back"),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 24),

            // === Right Side: Payment Details & Next Button ===
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "2. Review and Confirm Payment",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Payment Details",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "${widget.selectedPaymentMethod['category']}  ${widget.selectedPaymentMethod['method']}",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _vaNumber,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const Divider(color: Colors.white54, height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Price",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            Text(
                              formattedTotal, // di React mereka menampilkan price dulu, tapi di ConfirmPayment.jsx Price sudah "price", Tax dan total
                              style:
                                  const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Tax Fee 12%",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            Text(
                              formattedTax,
                              style:
                                  const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              formattedTotal,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Studio Terms and Condition",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      "• Reschedule hanya bisa dilakukan sebelum H-3 Jadwal Main.\n"
                      "• Dilarang merokok dalam studio.\n"
                      "• Wajib menjaga kebersihan lingkungan di dalam area studio.",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSubmitting ? Colors.grey : Colors.green.shade400,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        _isSubmitting ? "Processing..." : "Next",
                        style: TextStyle(fontSize: 16),
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
