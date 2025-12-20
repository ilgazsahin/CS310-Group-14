import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String? id; // Firestore document ID
  final String title;
  final String location;
  final String date;
  final String time;
  final String description;
  final String? ticketPrice;
  final List<String> hosts;
  final String? category;
  final String? imageUrl;
  final String createdBy; // User ID who created the event
  final DateTime createdAt; // Timestamp when event was created
  final DateTime? updatedAt; // Timestamp when event was last updated

  EventModel({
    this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.time,
    required this.description,
    this.ticketPrice,
    required this.hosts,
    this.category,
    this.imageUrl,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });

  // Constructor from Firestore document
  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      location: data['location'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      description: data['description'] ?? '',
      ticketPrice: data['ticketPrice'],
      hosts: List<String>.from(data['hosts'] ?? []),
      category: data['category'],
      imageUrl: data['imageUrl'],
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'location': location,
      'date': date,
      'time': time,
      'description': description,
      'ticketPrice': ticketPrice,
      'hosts': hosts,
      'category': category,
      'imageUrl': imageUrl,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  // Copy with method for updates
  EventModel copyWith({
    String? id,
    String? title,
    String? location,
    String? date,
    String? time,
    String? description,
    String? ticketPrice,
    List<String>? hosts,
    String? category,
    String? imageUrl,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      date: date ?? this.date,
      time: time ?? this.time,
      description: description ?? this.description,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      hosts: hosts ?? this.hosts,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getter for display name (backward compatibility)
  String get host {
    return hosts.isNotEmpty ? hosts.first : 'Unknown';
  }
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