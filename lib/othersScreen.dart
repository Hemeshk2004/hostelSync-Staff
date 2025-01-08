import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OthersScreenPage extends StatelessWidget {
  final String whatsappNumber =
      '+918870449940'; // Replace with your WhatsApp number
  final String phoneNumber = '+918870449940'; // Replace with your phone number

  const OthersScreenPage({super.key});

  // Function to open WhatsApp with a specific number
  void openWhatsApp(String number) async {
    var whatsappUrl = Uri.parse("https://wa.me/$number");
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else {
      throw 'Could not open WhatsApp';
    }
  }

  // Function to make a call to a specific number
  void makeCall(String number) async {
    var telUrl = Uri.parse("tel:$number");
    if (await canLaunchUrl(telUrl)) {
      await launchUrl(telUrl);
    } else {
      throw 'Could not make a call';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Others'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 90),
            // WhatsApp button
            ElevatedButton.icon(
              onPressed: () => openWhatsApp(whatsappNumber),
              icon: Image.asset(
                'assets/images/whatsapp.png', // Your WhatsApp image path
                width: 24,
                height: 24,
              ),
              label: const Text(
                "Contact Warden (WhatsApp)",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Background color
                minimumSize: const Size(280, 60), // Button size
              ),
            ),

            const SizedBox(height: 20), // Spacing between buttons

            // Call button
            ElevatedButton.icon(
              onPressed: () => makeCall(phoneNumber),
              icon: const Icon(
                Icons.call,
                size: 24,
                color: Colors.white,
              ),
              label: const Text(
                "Call Warden",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color.fromARGB(255, 33, 133, 232), // Background color
                minimumSize: const Size(280, 60), // Button size
              ),
            ),
          ],
        ),
      ),
    );
  }
}
