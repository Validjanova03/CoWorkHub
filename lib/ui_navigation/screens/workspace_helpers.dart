class WorkspaceHelpers {

  // ── Images ──
  static const Map<String, String> _images = {
    'Hot Desk 1': 'assets/images/hot_desk.jpg',
    'Hot Desk 2': 'assets/images/hot_desk2.png',
    'Hot Desk 3': 'assets/images/hot_desk_3.png',
    'Hot Desk 4': 'assets/images/hot_desk_4.png',
    'Hot Desk 5': 'assets/images/hot_desk_5.png',
    'Dedicated Room 1': 'assets/images/dedicated_desk.jpg',
    'Dedicated Room 2': 'assets/images/dedicated_desk2.png',
    'Dedicated Room 3': 'assets/images/dedicated_room_3.png',
    'Dedicated Room 4': 'assets/images/dedicated_desk_4.png',
    'Meeting Room 1': 'assets/images/meeting_room.jpg',
    'Meeting Room 2': 'assets/images/meeting_room2.png',
    'Meeting Room 3': 'assets/images/meeting_room_3.png',
    'Conference Hall 1': 'assets/images/conference_hall.jpg',
    'Conference Hall 2': 'assets/images/conference_hall2.png',
  };

  // ── Locations ──
  static const Map<String, String> _locations = {
    'Hot Desk 1': 'Levent, Istanbul',
    'Hot Desk 2': 'Moda, Istanbul',
    'Hot Desk 3': 'Kadiköy, Istanbul',
    'Hot Desk 4': 'Ataşehir, Istanbul',
    'Hot Desk 5': 'Maslak, Istanbul',
    'Dedicated Room 1': 'Feneryolu, Istanbul',
    'Dedicated Room 2': 'Beşiktaş, Istanbul',
    'Dedicated Room 3': 'Levent, Istanbul',
    'Dedicated Room 4': 'Bostancı, Istanbul',
    'Meeting Room 1': 'Şişli, Istanbul',
    'Meeting Room 2': 'Beşiktaş, Istanbul',
    'Meeting Room 3': 'Acıbadem, Istanbul',
    'Conference Hall 1': 'Şişli, Istanbul',
    'Conference Hall 2': 'Maslak, Istanbul',
  };

  // ── Methods ──
  static String getImage(String name) =>
      _images[name] ?? 'assets/images/workspace.png';

  static String getLocation(String name) =>
      _locations[name] ?? 'Istanbul';
}