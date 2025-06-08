import 'dart:convert';
import 'package:http/http.dart' as http;


///'http://localhost:8080'
const String BASE_URL = 'http://localhost:8080';

class AuthService {
  /// REGISTER
  static Future<http.Response> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String confirmationPassword,
  }) async {
    final uri = Uri.parse('$BASE_URL/api/users');
    final body = jsonEncode({
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'password': password,
      'confirmation_password': confirmationPassword,
    });
    final headers = <String, String>{'Content-Type': 'application/json'};
    return await http.post(uri, headers: headers, body: body);
  }

  /// LOGIN
  static Future<http.Response> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$BASE_URL/api/auth/login');
    final body = jsonEncode({'email': email, 'password': password});
    final headers = <String, String>{'Content-Type': 'application/json'};
    return await http.post(uri, headers: headers, body: body);
  }

  /// FETCH SEMUA STUDIO
  static Future<List<dynamic>> fetchStudios({required String token}) async {
    final uri = Uri.parse('$BASE_URL/api/studios');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final bodyJson = jsonDecode(response.body);
      return bodyJson['data'] as List<dynamic>;
    } else {
      throw Exception('Failed to load studios (status ${response.statusCode})');
    }
  }

  /// FETCH DETAIL STUDIO BERDASARKAN ID
  static Future<Map<String, dynamic>> fetchStudioById({
    required String token,
    required int studioId,
  }) async {
    final uri = Uri.parse('$BASE_URL/api/studios/$studioId');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final bodyJson = jsonDecode(response.body);
      return bodyJson['data'] as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load studio detail (status ${response.statusCode})');
    }
  }

  /// CREATE BOOKING  
  /// Endpoint: POST /api/{studioId}/bookings  
  /// Body JSON harus:
  /// {
  ///   "date": "yyyy-MM-dd",
  ///   "time_slot": "<String>",    // contoh: "09:00-12:00"
  ///   "room_name": "<String>",    // contoh: "Standard"
  ///   "price": "<String>"         // contoh: "150000"
  /// }
  static Future<http.Response> createBooking({
    required String token,
    required int studioId,
    required String date,
    required String timeSlot,
    required String roomName,
    required String price,
  }) async {
    final uri = Uri.parse('$BASE_URL/api/$studioId/bookings');
    final body = jsonEncode({
      'date': date,
      'time_slot': timeSlot,
      'room_name': roomName,
      'price': price,
    });

    // Debug print payload
    print('=== Sent Booking Payload ===');
    print(body);

    // Coba dengan Bearer
    var headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var response = await http.post(uri, headers: headers, body: body);

    print('=== Booking Response ===');
    print('Status code: \\${response.statusCode}');
    print('Body: \\${response.body}');

    // Jika 401, coba ulangi tanpa Bearer
    if (response.statusCode == 401) {
      headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': token,
      };
      response = await http.post(uri, headers: headers, body: body);
      print('=== Booking Response (tanpa Bearer) ===');
      print('Status code: \\${response.statusCode}');
      print('Body: \\${response.body}');
    }

    return response;
  }
}
