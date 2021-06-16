import 'package:flutter/material.dart';
class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Profile', icon: Icons.assignment_ind),
  const Choice(title: 'Logout', icon: Icons.logout),
];