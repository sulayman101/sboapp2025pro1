import 'package:flutter/material.dart';
import 'package:sboapp/Components/ads_and_net.dart';
import 'package:sboapp/Constants/text_style.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      appBar: AppBar(
        title: appBarText(text: "About Us"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Text.rich(
            TextSpan(
              text: "Welcome to Somali Books Online (SBO) — ",
              children: [
                TextSpan(
                  text:
                      "your premier digital library and knowledge hub, dedicated to providing unparalleled access to a vast collection of books in Somali, Arabic, and English. "
                      "Our mission is to empower readers by bridging cultural and linguistic gaps through the power of literature and education.\n\n",
                ),
                TextSpan(
                  text:
                      "At SBO, we pride ourselves on offering a meticulously curated selection of books across diverse categories. "
                      "Our platform serves readers of all ages and interests, fostering a love for lifelong learning and intellectual growth.\n\n",
                ),
                TextSpan(
                  text: "Key Features:\n",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                    text:
                        "• Offline Reading: Access your favorite books anytime, anywhere.\n"),
                TextSpan(
                    text:
                        "• Smart Book Progress Tracking: Effortlessly monitor your reading journey.\n"),
                TextSpan(
                    text:
                        "• Personalized Recommendations: Discover books tailored to your preferences.\n"),
                TextSpan(
                    text:
                        "• Interactive User Experience: Enjoy an intuitive and user-friendly interface.\n"),
                TextSpan(
                    text:
                        "• Real-time Notifications: Stay updated on new releases and special content.\n\n"),
                TextSpan(
                  text:
                      "Our vision goes beyond just providing books — we aim to create a vibrant community of readers, thinkers, and learners who are passionate about growth, culture, and knowledge-sharing.\n\n",
                ),
                TextSpan(
                  text:
                      "Join Somali Books Online today and become part of a global movement dedicated to preserving stories, sharing wisdom, and building a brighter future through the power of reading.\n\n",
                ),
                TextSpan(
                  text: "Explore, Learn, and Rise with SBO App!\n\n",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: "This initiative was envisioned and founded by ",
                ),
                TextSpan(
                  text: "Suleman Abdallah Mohamed",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.teal,
                  ),
                ),
                TextSpan(
                  text:
                      ", a passionate advocate for knowledge accessibility, cultural preservation, and educational empowerment in the Somali community and beyond.",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
