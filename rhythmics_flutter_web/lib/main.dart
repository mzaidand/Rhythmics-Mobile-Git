import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/studio_detail_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/confirm_payment_screen.dart';
import 'screens/booking_success_screen.dart';

void main() {
  runApp(const RhythmicsApp());
}

class RhythmicsApp extends StatelessWidget {
  const RhythmicsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rhythmics Flutter Web',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),

      // initialRoute di‐set ke login
      initialRoute: '/login',

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final String token = args['token'];
          return HomeScreen(token: token);
        },
        '/studio-detail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final String token = args['token'];
          final Map<String, dynamic> studio = args['studio'];
          return StudioDetailScreen(token: token, studio: studio);
        },
        '/payment': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final String token = args['token'];
          final Map<String, dynamic> studio = args['studio'];
          final String room = args['room'];
          final String date = args['date'];
          final String time = args['time'];
          final int price = args['price'];
          return PaymentScreen(
            token: token,
            studio: studio,
            room: room,
            date: date,
            time: time,
            price: price,
          );
        },
        '/confirm-payment': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final String token = args['token'];
          final Map<String, dynamic> studio = args['studio'];
          final String room = args['room'];
          final String date = args['date'];
          final String time = args['time'];
          final int price = args['price'];
          final double taxPrice = args['taxPrice'];
          final double totalPrice = args['totalPrice'];
          final Map<String, String> selectedPaymentMethod = Map<String, String>.from(args['selectedPaymentMethod']);
          final Map<String, String> formData = Map<String, String>.from(args['formData']);
          return ConfirmPaymentScreen(
            token: token,
            studio: studio,
            room: room,
            date: date,
            time: time,
            price: price,
            taxPrice: taxPrice,
            totalPrice: totalPrice,
            selectedPaymentMethod: selectedPaymentMethod,
            formData: formData,
          );
        },
        '/booking-success': (context) => const BookingSuccessScreen(),
      },
    );
  }
}
