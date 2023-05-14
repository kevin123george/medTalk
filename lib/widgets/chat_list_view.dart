
import 'package:flutter/material.dart';

import '../models/data.dart' as data;
import '../models/models.dart';
import 'app_bar.dart' as app_bar;
import 'chat_widget.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({
    super.key,
    this.selectedIndex,
    this.onSelected,
    required this.currentUser,
  });

  final int? selectedIndex;
  final ValueChanged<int>? onSelected;
  final User currentUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView(
        children: [
          const SizedBox(height: 8),
          app_bar.AppBarWidget(currentUser: currentUser),
          const SizedBox(height: 8),
          ...List.generate(
            data.chats.length,
            (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ChatWidget(
                  email: data.chats[index],
                  onSelected: onSelected != null
                      ? () {
                          onSelected!(index);
                        }
                      : null,
                  isSelected: selectedIndex == index,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
