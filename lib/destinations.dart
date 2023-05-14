
import 'package:flutter/material.dart';

class Destination {
  const Destination(this.icon, this.label);
  final IconData icon;
  final String label;
}

const List<Destination> destinations = <Destination>[
  Destination(Icons.translate, 'translate'),
  Destination(Icons.storage, 'records'),
  Destination(Icons.messenger_outline_rounded, 'Messages'),
  Destination(Icons.settings, 'settings'),
];
