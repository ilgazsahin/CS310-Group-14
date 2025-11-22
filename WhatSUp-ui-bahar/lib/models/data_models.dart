class EventModel {
  final String title;
  final String location;
  final String date;
  final String host;
  final String imageUrl;

  EventModel({
    required this.title,
    required this.location,
    required this.date,
    required this.host,
    required this.imageUrl,
  });
}

class PostModel {
  final String username;
  final String caption;
  final String imageUrl;
  final int likes;
  final int comments;

  PostModel({
    required this.username,
    required this.caption,
    required this.imageUrl,
    required this.likes,
    required this.comments,
  });
}