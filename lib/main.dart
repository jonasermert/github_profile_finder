import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(GithubProfileFinderApp());
}

class GithubProfileFinderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Github Profile Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
      home: GithubProfileFinder(),
    );
  }
}

class GithubProfileFinder extends StatefulWidget {
  @override
  _GithubProfileFinderState createState() => _GithubProfileFinderState();
}

class _GithubProfileFinderState extends State<GithubProfileFinder> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? userProfile;
  bool isLoading = false;

  Future<void> fetchGithubProfile(String username) async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse('https://api.github.com/users/$username'));

    if (response.statusCode == 200) {
      setState(() {
        userProfile = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        userProfile = null;
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not found! Please try again.')),
      );
    }
  }

  Widget _buildProfileCard() {
    if (userProfile == null) {
      return Center(
        child: Text(
          'No profile found. Enter a username above.',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Card(
      elevation: 5,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(userProfile!['avatar_url']),
              ),
            ),
            SizedBox(height: 16),
            Text(
              userProfile!['name'] ?? 'No name available',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(
                    'Repos: ${userProfile!['public_repos']}',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.blue,
                ),
                SizedBox(width: 8),
                Chip(
                  label: Text(
                    'Gists: ${userProfile!['public_gists']}',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                ),
              ],
            ),
            SizedBox(height: 16),
            if (userProfile!['blog'] != null && userProfile!['blog'].isNotEmpty)
              Text(
                'Website: ${userProfile!['blog']}',
                style: TextStyle(color: Colors.black87),
              ),
            if (userProfile!['email'] != null)
              Text(
                'Email: ${userProfile!['email']}',
                style: TextStyle(color: Colors.black87),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              onPressed: () {
                openUrl(userProfile!['html_url']);
              },
              child: Text('Visit Github Profile'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Github Profile Finder',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Github Username',
                labelStyle: TextStyle(color: Colors.black54),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  fetchGithubProfile(_controller.text);
                }
              },
              child: Text('Fetch Profile'),
            ),
            SizedBox(height: 16),
            isLoading
                ? CircularProgressIndicator(color: Colors.blueAccent)
                : Expanded(child: _buildProfileCard()),
          ],
        ),
      ),
    );
  }

  void openUrl(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}