import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:github_profile_finder/main.dart';

import 'github_profile_finder_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('Github Profile Finder Tests', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
    });

    testWidgets('UI-Rendering Test: App startet mit leeren Feldern', (WidgetTester tester) async {
      await tester.pumpWidget(GithubProfileFinderApp());

      expect(find.text('Github Profile Finder'), findsOneWidget);
      expect(find.text('No profile found. Enter a username above.'), findsOneWidget);
    });

    testWidgets('Benutzerprofil anzeigen', (WidgetTester tester) async {
      const mockResponse = {
        "login": "octocat",
        "name": "The Octocat",
        "avatar_url": "https://avatars.githubusercontent.com/u/583231?v=4",
        "public_repos": 8,
        "public_gists": 8,
        "html_url": "https://github.com/octocat",
        "blog": "https://github.blog/",
        "email": null
      };

      when(mockClient.get(Uri.parse('https://api.github.com/users/octocat')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      await tester.pumpWidget(GithubProfileFinderApp());

      await tester.enterText(find.byType(TextField), 'octocat');
      await tester.tap(find.text('Fetch Profile'));
      await tester.pumpAndSettle();

      expect(find.text('The Octocat'), findsOneWidget);
      expect(find.text('Repos: 8'), findsOneWidget);
      expect(find.text('Gists: 8'), findsOneWidget);
    });

    testWidgets('Fehlermeldung bei nicht vorhandenem Benutzer', (WidgetTester tester) async {
      when(mockClient.get(Uri.parse('https://api.github.com/users/unknownuser')))
          .thenAnswer((_) async => http.Response('{}', 404));

      await tester.pumpWidget(GithubProfileFinderApp());

      await tester.enterText(find.byType(TextField), 'unknownuser');
      await tester.tap(find.text('Fetch Profile'));
      await tester.pumpAndSettle();

      expect(find.text('User not found! Please try again.'), findsOneWidget);
      expect(find.text('No profile found. Enter a username above.'), findsOneWidget);
    });
  });
}