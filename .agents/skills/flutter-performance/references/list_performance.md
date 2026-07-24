# List Performance

Always use `ListView.builder` or `GridView.builder` for dynamic or long lists. These lazily build only visible items. Use `itemExtent` or `prototypeItem` when items have uniform height so the framework can skip layout calculations. Add `key` to items that can be reordered or removed.

## CORRECT

```dart
class MessageList extends StatelessWidget {
  const MessageList({super.key, required this.messages});

  final List<Message> messages;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: messages.length,
      // Fixed height per item — lets the framework skip measuring.
      itemExtent: 72.0,
      itemBuilder: (context, index) {
        final message = messages[index];
        return MessageTile(
          // Key by stable ID so reorder/remove animates correctly.
          key: ValueKey(message.id),
          message: message,
        );
      },
    );
  }
}

/// When height is not fixed but consistent, use prototypeItem.
class UserList extends StatelessWidget {
  const UserList({super.key, required this.users});

  final List<User> users;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      prototypeItem: const UserTile(user: User.placeholder),
      itemBuilder: (context, index) {
        return UserTile(
          key: ValueKey(users[index].id),
          user: users[index],
        );
      },
    );
  }
}
```

## WRONG

```dart
// BAD: Builds ALL items up front, even offscreen.
class MessageList extends StatelessWidget {
  const MessageList({super.key, required this.messages});

  final List<Message> messages;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: messages.map((m) => MessageTile(message: m)).toList(),
    );
  }
}

// BAD: SingleChildScrollView + Column has the same problem.
class UserList extends StatelessWidget {
  const UserList({super.key, required this.users});

  final List<User> users;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: users.map((u) => UserTile(user: u)).toList(),
      ),
    );
  }
}
```
