import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

void main() => runApp(const CalendarBookingApp());

class CalendarBookingApp extends StatelessWidget {
  const CalendarBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar Booking',
      home: const BookingHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BookingHomePage extends StatefulWidget {
  const BookingHomePage({super.key});

  @override
  State<BookingHomePage> createState() => _BookingHomePageState();
}

class _BookingHomePageState extends State<BookingHomePage> {
  final String baseUrl = 'https://your-api-hosting.vercel.app/bookings'; // or Railway/Render
  final TextEditingController userIdController = TextEditingController();
  DateTime? startTime;
  DateTime? endTime;
  List bookings = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<List<dynamic>> fetchBookings() async {
  try {
    setState(() => isLoading = true);
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      setState(() {
        bookings = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      print("Fetch failed: ${response.statusCode}");
    }
  } catch (e) {
    print("Error fetching bookings: $e");
  }
  return bookings;
}


  Future<http.Response> createBooking(String userId, String start, String end) {
    return http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "userId": userId,
        "startTime": start,
        "endTime": end
      }),
    );
  }

  Future<void> deleteBooking(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      fetchBookings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking deleted')),
      );
    }
  }

  Future<void> submitBooking() async {
  print("Submitting booking...");

  if (startTime == null || endTime == null || userIdController.text.isEmpty) {
    print("Missing input");
    return;
  }

  try {
    final response = await createBooking(
      userIdController.text,
      startTime!.toUtc().toIso8601String(),
      endTime!.toUtc().toIso8601String(),
    );

    print("Response: ${response.statusCode}");

    if (response.statusCode == 201) {
      await fetchBookings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking successful!')),
      );
    } else {
      final error = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error['error']}')),
      );
    }
  } catch (e) {
    print("Exception occurred: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exception: $e')),
    );
  }
}


  Future<void> pickDateTime(bool isStart) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );
    if (time == null) return;

    final selected = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart) {
        startTime = selected;
      } else {
        endTime = selected;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Booking System')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: userIdController,
              decoration: const InputDecoration(labelText: 'User ID'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => pickDateTime(true),
                    child: Text(
                      startTime == null
                          ? 'Select Start Time'
                          : 'Start: ${dateFormat.format(startTime!)}',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => pickDateTime(false),
                    child: Text(
                      endTime == null
                          ? 'Select End Time'
                          : 'End: ${dateFormat.format(endTime!)}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: submitBooking,
              child: const Text('Book Now'),
            ),
            const Divider(height: 30),
            const Text('Bookings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        return ListTile(
                          title: Text(booking['userId']),
                          subtitle: Text(
                            '${dateFormat.format(DateTime.parse(booking['startTime']))} - ${dateFormat.format(DateTime.parse(booking['endTime']))}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteBooking(booking['_id']),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}