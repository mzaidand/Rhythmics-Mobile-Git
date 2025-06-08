import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudioDetailScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> studio;

  const StudioDetailScreen({
    Key? key,
    required this.token,
    required this.studio,
  }) : super(key: key);

  @override
  State<StudioDetailScreen> createState() => _StudioDetailScreenState();
}

class _StudioDetailScreenState extends State<StudioDetailScreen> {
  late List<Map<String, String>> _weeklySchedule; // List of { 'date', 'dayName', 'day' }
  final List<String> _timeSlots = [
    "06:00 - 07:00",
    "07:00 - 08:00",
    "08:00 - 09:00",
    "09:00 - 10:00",
    "10:00 - 11:00",
    "11:00 - 12:00",
    "12:00 - 13:00",
    "13:00 - 14:00",
    "14:00 - 15:00",
    "15:00 - 16:00",
    "16:00 - 17:00",
    "17:00 - 18:00",
    "18:00 - 19:00",
    "19:00 - 20:00",
    "20:00 - 21:00",
    "21:00 - 22:00",
    "22:00 - 23:00",
    "23:00 - 00:00",
  ];

  String _selectedRoom = "";
  String _selectedDate = "";
  String _selectedTime = "";

  // Map roomType → list of schedule entries ({ "timeSlot", "date", "status" })
  Map<String, List<Map<String, dynamic>>> _scheduleDetailsByRoom = {};

  @override
  void initState() {
    super.initState();
    _weeklySchedule = generateWeeklySchedule(DateTime.now());
    _processSchedule();
  }

  // Generate 7-day schedule (Sunday → Saturday), with 'date', 'dayName', and 'day' labels
  List<Map<String, String>> generateWeeklySchedule(DateTime date) {
    const List<String> daysOfWeek = [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday"
    ];
    List<Map<String, String>> schedule = [];
    // Move back to Sunday of current week
    int currentWeekday = date.weekday; // Monday = 1, Sunday = 7
    DateTime sunday = date.subtract(Duration(days: currentWeekday % 7));
    for (int i = 0; i < 7; i++) {
      final loopDate = sunday.add(Duration(days: i));
      final year = loopDate.year;
      final month = loopDate.month.toString().padLeft(2, '0');
      final dayOfMonth = loopDate.day.toString().padLeft(2, '0');
      final formattedDate = "$year-$month-$dayOfMonth";
      final dayName = daysOfWeek[loopDate.weekday % 7];

      final monthNames = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
      ];
      final dayLabel = "${loopDate.day} ${monthNames[loopDate.month - 1]}";

      schedule.add({
        'date': formattedDate,
        'dayName': dayName,
        'day': dayLabel,
      });
    }
    return schedule;
  }

  // Build _scheduleDetailsByRoom from widget.studio data
  void _processSchedule() {
    final List<dynamic> rooms = widget.studio['rooms'] as List<dynamic>? ?? [];
    final Map<String, List<Map<String, dynamic>>> temp = {};

    for (var room in rooms) {
      final String roomType = room['type'] as String;
      final List<dynamic> roomSchedules = room['roomSchedules'] as List<dynamic>? ?? [];
      final List<Map<String, dynamic>> schedules = [];

      for (var rs in roomSchedules) {
        final sched = rs['schedule'] as Map<String, dynamic>?;
        if (sched == null) continue;
        final rawDate = sched['date'] as String?;
        final rawTimeSlot = sched['time_slot'] as String?;
        final status = (rs['status'] as String? ?? "").toUpperCase();
        if (rawDate == null || rawTimeSlot == null) continue;
        final normalizedDate = normalizeDate(rawDate);
        if (normalizedDate != null) {
          schedules.add({
            'timeSlot': rawTimeSlot, // e.g. "09:00-12:00"
            'status': status,        // "AVAILABLE" or "NOT_AVAILABLE"
            'date': normalizedDate,  // "2025-06-02"
          });
        }
      }
      temp[roomType] = schedules;
    }

    setState(() {
      _scheduleDetailsByRoom = temp;
    });
  }

  // Normalize a string date to "yyyy-MM-dd"
  String? normalizeDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return DateFormat('yyyy-MM-dd').format(dt);
    } catch (_) {
      return null;
    }
  }

  // Handle "Book Now" button press
  void _handleBooking() {
    if (_selectedRoom.isEmpty) {
      _showAlert("Silakan pilih room terlebih dahulu.");
      return;
    }
    if (_selectedDate.isEmpty) {
      _showAlert("Silakan pilih tanggal terlebih dahulu.");
      return;
    }
    if (_selectedTime.isEmpty) {
      _showAlert("Silakan pilih time slot terlebih dahulu.");
      return;
    }

    final roomData = (widget.studio['rooms'] as List<dynamic>).firstWhere(
      (r) => r['type'] == _selectedRoom,
      orElse: () => null,
    );
    final int price = (roomData != null) ? (roomData['price'] as int) : 0;

    Navigator.pushNamed(
      context,
      '/payment',
      arguments: {
        'token': widget.token,
        'studio': widget.studio,
        'room': _selectedRoom,
        'date': _selectedDate,
        'time': _selectedTime,
        'price': price,
      },
    );
  }

  void _showAlert(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Peringatan"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studio = widget.studio;
    final List<dynamic> rooms = studio['rooms'] as List<dynamic>? ?? [];

    // Determine hero image: first room's first gallery photo or fallback
    String imageUrl = "https://staticg.sportskeeda.com/editor/2022/11/a9ef8-16681658086025-1920.jpg";
    if (rooms.isNotEmpty) {
      final firstRoom = rooms.first as Map<String, dynamic>;
      final gallery = firstRoom['gallery'] as List<dynamic>? ?? [];
      if (gallery.isNotEmpty) {
        final photoUrl = gallery.first['photo_url'] as String?;
        if (photoUrl != null && photoUrl.isNotEmpty) {
          imageUrl = 'http://localhost:8080$photoUrl';
        }
      }
    }

    // Build Google Static Map URL
    final latitude = studio['latitude']?.toString() ?? '0';
    final longitude = studio['longitude']?.toString() ?? '0';
    final mapUrl =
        "https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude"
        "&zoom=15&size=600x300&markers=$latitude,$longitude&key=YOUR_GOOGLE_API_KEY";

    return Scaffold(
      appBar: AppBar(
        title: Text(studio['name'] ?? 'Studio Detail'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ============================
            // Hero Section
            // ============================
            Stack(
              children: [
                Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(0, 0, 0, 0.2),
                        Color.fromRGBO(0, 0, 0, 0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studio['name'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${studio['street'] ?? ''} - ${studio['district'] ?? ''}, "
                        "${studio['city_or_regency'] ?? ''}, ${studio['province'] ?? ''}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: rooms.map<Widget>((room) {
                          final type = room['type'] as String;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              type,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          // Gallery navigation if needed
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text("Gallery"),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ============================
            // Location Section
            // ============================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "LOCATION",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      // Buka Google Maps / URL launcher
                    },
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(mapUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ============================
            // Booking Form: Room, Date, Time, Book Now
            // ============================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room / Date / Time selectors
                  Row(
                    children: [
                      // Select Room
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedRoom.isEmpty ? null : _selectedRoom,
                          decoration: InputDecoration(
                            labelText: "Select Room",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                          ),
                          items: rooms.map<DropdownMenuItem<String>>((r) {
                            return DropdownMenuItem<String>(
                              value: r['type'] as String,
                              child: Text(r['type'] as String),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedRoom = val ?? "";
                              _selectedDate = "";
                              _selectedTime = "";
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Select Date
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedDate.isEmpty ? null : _selectedDate,
                          decoration: InputDecoration(
                            labelText: "Select Date",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                          ),
                          items: (_selectedRoom.isEmpty
                                  ? <DropdownMenuItem<String>>[]
                                  : _weeklySchedule
                                      .where((day) {
                                        final roomSchedules =
                                            _scheduleDetailsByRoom[_selectedRoom] ?? [];
                                        return roomSchedules.any((sched) =>
                                            sched['date'] == day['date'] &&
                                            sched['status'] == "AVAILABLE");
                                      })
                                      .map((day) {
                                        return DropdownMenuItem<String>(
                                          value: day['date'],
                                          child: Text(day['day']!),
                                        );
                                      })
                                      .toList())
                              .cast<DropdownMenuItem<String>>(),
                          onChanged: (val) {
                            setState(() {
                              _selectedDate = val ?? "";
                              _selectedTime = "";
                            });
                          },
                          disabledHint: const Text("Select Room First"),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Select Time Slot
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedTime.isEmpty ? null : _selectedTime,
                          decoration: InputDecoration(
                            labelText: "Select Time",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                          ),
                          items: (_selectedRoom.isEmpty || _selectedDate.isEmpty
                                  ? <DropdownMenuItem<String>>[]
                                  : (_scheduleDetailsByRoom[_selectedRoom] ?? [])
                                      .where((sched) =>
                                          sched['date'] == _selectedDate &&
                                          sched['status'] == "AVAILABLE")
                                      .map((sched) {
                                        return DropdownMenuItem<String>(
                                          value: sched['timeSlot'] as String,
                                          child: Text(sched['timeSlot'] as String),
                                        );
                                      })
                                      .toList())
                              .cast<DropdownMenuItem<String>>(),
                          onChanged: (val) {
                            setState(() {
                              _selectedTime = val ?? "";
                            });
                          },
                          disabledHint: const Text("Select Date First"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: (_selectedRoom.isEmpty ||
                              _selectedDate.isEmpty ||
                              _selectedTime.isEmpty)
                          ? null
                          : _handleBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade500,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Book Now",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // ============================
            // Schedule Grid (7 days × time slots)
            // ============================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: blank + 7 days
                      Row(
                        children: [
                          Container(
                            width: 100,
                            padding: const EdgeInsets.all(8),
                            child: const Text(
                              "Time",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          ..._weeklySchedule.map((day) {
                            return Container(
                              width: 120,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.orange.shade100,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    day['day']!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  Text(
                                    day['dayName']!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),

                      // Rows per TimeSlot
                      ..._timeSlots.map((slot) {
                        return Row(
                          children: [
                            // Time label
                            Container(
                              width: 100,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 12),
                              child: Text(
                                slot,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            // Cells for each day
                            ..._weeklySchedule.map((day) {
                              bool isAvailable = false;
                              final roomSchedules =
                                  _scheduleDetailsByRoom[_selectedRoom] ?? [];
                              for (var sched in roomSchedules) {
                                if (sched['date'] == day['date'] &&
                                    sched['timeSlot'] == slot &&
                                    sched['status'] == "AVAILABLE") {
                                  isAvailable = true;
                                  break;
                                }
                              }
                              int cellPrice = 0;
                              if (_selectedRoom.isNotEmpty) {
                                final roomData = rooms.firstWhere(
                                  (r) => r['type'] == _selectedRoom,
                                  orElse: () => null,
                                );
                                if (roomData != null) {
                                  cellPrice = roomData['price'] as int;
                                }
                              }
                              return Container(
                                width: 120,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 8),
                                decoration: BoxDecoration(
                                  color:
                                      isAvailable ? Colors.white : Colors.red.shade100,
                                  border: Border.all(
                                      color: Colors.orange.shade100),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "Rp$cellPrice",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isAvailable
                                            ? Colors.black
                                            : Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isAvailable ? "Available" : "Not Available",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isAvailable
                                            ? Colors.black
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ============================
            // Reviews Section (Static)
            // ============================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Rating Summary
                    Column(
                      children: [
                        const Text(
                          "4.5",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return Icon(
                              index < 4
                                  ? Icons.star
                                  : Icons.star_half, // 4 full stars + half
                              color: Colors.orange.shade400,
                              size: 24,
                            );
                          }),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "based on 24 reviews",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Rating Breakdown
                    Column(
                      children: [
                        _buildProgressBar("REGULAR", 0.84),
                        const SizedBox(height: 8),
                        _buildProgressBar("VIP", 0.94),
                        const SizedBox(height: 8),
                        _buildProgressBar("VVIP", 0.96),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Review Cards
                    Column(
                      children: [
                        _buildReviewCard(
                          avatarUrl: "https://randomuser.me/api/portraits/women/44.jpg",
                          name: "Sarah Johnson",
                          roomType: "VIP",
                          stars: 5,
                          comment:
                              "Amazing studio with top-notch equipment. The soundproofing is excellent and the staff is very professional. Will definitely book again!",
                        ),
                        const SizedBox(height: 12),
                        _buildReviewCard(
                          avatarUrl: "https://randomuser.me/api/portraits/men/32.jpg",
                          name: "Michael Chen",
                          roomType: "VVIP",
                          stars: 4,
                          comment:
                              "The VVIP room is worth every penny. The equipment is state-of-the-art and the acoustics are perfect. Only minor issue was the air conditioning was a bit loud.",
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Pagination
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Previous"),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          "Page 1 of 5",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade500,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Next"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Write Review Button
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit, size: 20),
                      label: const Text("Write a Review"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Widget untuk rating breakdown bar
  Widget _buildProgressBar(String label, double percent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            Text("${(percent * 5).toStringAsFixed(1)}/5",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.orange.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget untuk review card
  Widget _buildReviewCard({
    required String avatarUrl,
    required String name,
    required String roomType,
    required int stars,
    required String comment,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  roomType,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < stars ? Icons.star : Icons.star_border,
                      color: index < stars ? Colors.orange.shade400 : Colors.grey.shade300,
                      size: 16,
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Text(
                  comment,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
