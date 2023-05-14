
import 'models.dart';

final User user_0 = User(
    id:0,
    name: const Name(first: 'Me', last: ''),
    avatarUrl: 'assets/avatar_1.png',
    lastActive: DateTime.now());
final User user_1 = User(
    id:1,
    name: const Name(first: '老', last: '强'),
    avatarUrl: 'assets/avatar_2.png',
    lastActive: DateTime.now().subtract(const Duration(minutes: 10)));
final User user_2 = User(
    id:2,
    name: const Name(first: 'So', last: 'Duri'),
    avatarUrl: 'assets/avatar_3.png',
    lastActive: DateTime.now().subtract(const Duration(minutes: 20)));
final User user_3 = User(
    id:3,
    name: const Name(first: 'Lily', last: 'MacDonald'),
    avatarUrl: 'assets/avatar_4.png',
    lastActive: DateTime.now().subtract(const Duration(hours: 2)));
final User user_4 = User(
    id:4,
    name: const Name(first: 'Ziad', last: 'Aouad'),
    avatarUrl: 'assets/avatar_5.png',
    lastActive: DateTime.now().subtract(const Duration(hours: 6)));

final List<Chat> chats = [
  Chat(
    sender: user_1,
    subject: '豆花鱼',
    content: '最近忙吗？昨晚我去了你最爱的那家饭馆，点了他们的特色豆花鱼，吃着吃着就想你了。',
  ),
  Chat(
    sender: user_2,
    subject: 'Dinner Club',
    content:
        'I think it’s time for us to finally try that new noodle shop downtown that doesn’t use menus. Anyone else have other suggestions for dinner club this week? I’m so intrigued by this idea of a noodle restaurant where no one gets to order for themselves - could be fun, or terrible, or both :)\n\nSo',
  ),
  Chat(
      sender: user_3,
      subject: 'This food show is made for you',
      content:
          'Ping– you’d love this new food show I started watching. It’s produced by a Thai drummer who started getting recognized for the amazing vegan food she always brought to shows.',
  ),
  Chat(
    sender: user_4,
    subject: 'Volunteer EMT with me?',
    content:
        'What do you think about training to be volunteer EMTs? We could do it together for moral support. Think about it??',
  ),
];