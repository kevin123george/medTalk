// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
