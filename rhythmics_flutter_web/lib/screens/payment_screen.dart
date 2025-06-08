import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> studio;
  final String room;
  final String date;
  final String time;
  final int price; // dalam integer, misal 150000

  const PaymentScreen({
    Key? key,
    required this.token,
    required this.studio,
    required this.room,
    required this.date,
    required this.time,
    required this.price,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  String _paymentCategory = ""; // “Virtual Account” / “E-Wallet” / “Credit Card”
  String _paymentMethod = "";   // ex: “BCA”, “BNI”, etc.

  double _taxPrice = 0;
  double _totalPrice = 0;
  double _progress = 0; // 0–100

  @override
  void initState() {
    super.initState();
    // Hitung taxPrice & totalPrice
    _taxPrice = widget.price * 0.12;
    _totalPrice = widget.price + _taxPrice;
    _calculateProgress();
  }

  void _calculateProgress() {
    double value = 0;
    if (_nameCtrl.text.trim().isNotEmpty &&
        _phoneCtrl.text.trim().isNotEmpty &&
        _emailCtrl.text.trim().isNotEmpty) {
      value += 50;
    }
    if (_paymentCategory.isNotEmpty && _paymentMethod.isNotEmpty) {
      value += 50;
    }
    setState(() {
      _progress = value;
    });
  }

  void _handlePaymentMethod(String category, String method) {
    setState(() {
      _paymentCategory = category;
      _paymentMethod = method;
    });
    _calculateProgress();
  }

  bool _isFormValid() {
    if (_formKey.currentState == null) return false;
    if (!_formKey.currentState!.validate()) return false;
    if (_paymentMethod.isEmpty) return false;
    return true;
  }

  void _handleNext() {
    if (!_isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Harap lengkapi data & pilih metode pembayaran terlebih dahulu."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prepare data form untuk di-kirim ke ConfirmPayment
    final Map<String, String> formData = {
      'customerName': _nameCtrl.text.trim(),
      'phoneNumber': _phoneCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
    };

    final selectedPaymentMethod = {
      'category': _paymentCategory,
      'method': _paymentMethod,
    };

    Navigator.pushNamed(
      context,
      '/confirm-payment',
      arguments: {
        'token': widget.token,
        'studio': widget.studio,
        'room': widget.room,
        'date': widget.date,
        'time': widget.time,
        'price': widget.price,
        'taxPrice': _taxPrice,
        'totalPrice': _totalPrice,
        'selectedPaymentMethod': selectedPaymentMethod,
        'formData': formData,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedPrice =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
            .format(widget.price);
    final formattedTaxPrice =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
            .format(_taxPrice);
    final formattedTotalPrice =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
            .format(_totalPrice);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          children: [
            // === Progress Bar + Step Title ===
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "1. Customer Detail and Payment Option",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _progress / 100,
                  backgroundColor: Colors.grey.shade300,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.green.shade600),
                  minHeight: 8,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // === Form Customer Detail ===
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.indigo.shade700,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                onChanged: _calculateProgress,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Customer Detail",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    // Customer Name
                    TextFormField(
                      controller: _nameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Customer Name",
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Phone Number
                    TextFormField(
                      controller: _phoneCtrl,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Phone number tidak boleh kosong';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(val.trim())) {
                          return 'Phone number harus angka';
                        }
                        if (val.trim().length > 15) {
                          return 'Phone number maksimal 15 digit';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                            .hasMatch(val.trim())) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Notes
                    TextFormField(
                      controller: _notesCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Notes (opsional)",
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // === Review Price ===
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.indigo.shade700,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Price",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        formattedPrice,
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
                        "Service Fee 12%",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        formattedTaxPrice,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white54, height: 24),
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
                        formattedTotalPrice,
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

            const SizedBox(height: 16),

            // === Payment Options (pilih kategori & icon) ===
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select Payment Option",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Virtual Account Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: const Text(
                    "Virtual Account",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildPaymentIcon("BCA", Colors.white),
                    const SizedBox(width: 12),
                    _buildPaymentIcon("BNI", Colors.white),
                    const SizedBox(width: 12),
                    _buildPaymentIcon("Mandiri", Colors.white),
                  ],
                ),

                const SizedBox(height: 12),

                // E-Wallet Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: const Text(
                    "E-Wallet",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildPaymentIcon("GoPay", Colors.white),
                    const SizedBox(width: 12),
                    _buildPaymentIcon("BSI", Colors.white),
                  ],
                ),

                const SizedBox(height: 12),

                // Credit Card Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: const Text(
                    "Credit Card",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildPaymentIcon("Visa", Colors.white),
                    const SizedBox(width: 12),
                    _buildPaymentIcon("MasterCard", Colors.white),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // === Tombol Next ===
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _isFormValid() ? _handleNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormValid() ? Colors.green.shade400 : Colors.grey,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
                child: Text(
                  "Next",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentIcon(String method, Color bg) {
    final isSelected = (_paymentMethod == method);
    return GestureDetector(
      onTap: () => _handlePaymentMethod(
          method == "BCA" || method == "BNI" || method == "Mandiri"
              ? "Virtual Account"
              : (method == "GoPay" || method == "BSI"
                  ? "E-Wallet"
                  : "Credit Card"),
          method),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Colors.blue.shade700, width: 2)
              : Border.all(color: Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: Text(
          method,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue.shade700 : Colors.black54,
          ),
        ),
      ),
    );
  }
}
