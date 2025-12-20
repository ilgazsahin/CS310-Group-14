import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

class TicketModel {
  final String? id; // Firestore document ID
  final String eventId; // Reference to the event
  final String eventTitle; // Event title (denormalized for easy display)
  final String eventLocation; // Event location (denormalized)
  final String eventDate; // Event date (denormalized)
  final String eventTime; // Event time (denormalized)
  final String? eventImageUrl; // Event image (denormalized)
  final String? eventCategory; // Event category (denormalized)
  final List<String> eventHosts; // Event hosts (denormalized)
  final String? ticketPrice; // Price paid for ticket (from event)
  final String userId; // User who owns the ticket
  final DateTime createdAt; // When ticket was created
  final bool isFavorite; // User's favorite status

  TicketModel({
    this.id,
    required this.eventId,
    required this.eventTitle,
    required this.eventLocation,
    required this.eventDate,
    required this.eventTime,
    this.eventImageUrl,
    this.eventCategory,
    required this.eventHosts,
    this.ticketPrice,
    required this.userId,
    required this.createdAt,
    this.isFavorite = false,
  });

  // Constructor from Firestore document
  factory TicketModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TicketModel(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      eventTitle: data['eventTitle'] ?? '',
      eventLocation: data['eventLocation'] ?? '',
      eventDate: data['eventDate'] ?? '',
      eventTime: data['eventTime'] ?? '',
      eventImageUrl: data['eventImageUrl'],
      eventCategory: data['eventCategory'],
      eventHosts: List<String>.from(data['eventHosts'] ?? []),
      ticketPrice: data['ticketPrice'],
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isFavorite: data['isFavorite'] ?? false,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'eventTitle': eventTitle,
      'eventLocation': eventLocation,
      'eventDate': eventDate,
      'eventTime': eventTime,
      'eventImageUrl': eventImageUrl,
      'eventCategory': eventCategory,
      'eventHosts': eventHosts,
      'ticketPrice': ticketPrice,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isFavorite': isFavorite,
    };
  }

  // Copy with method for updates
  TicketModel copyWith({
    String? id,
    String? eventId,
    String? eventTitle,
    String? eventLocation,
    String? eventDate,
    String? eventTime,
    String? eventImageUrl,
    String? eventCategory,
    List<String>? eventHosts,
    String? ticketPrice,
    String? userId,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return TicketModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
      eventLocation: eventLocation ?? this.eventLocation,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      eventImageUrl: eventImageUrl ?? this.eventImageUrl,
      eventCategory: eventCategory ?? this.eventCategory,
      eventHosts: eventHosts ?? this.eventHosts,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // Helper getters for display
  String get organizer => eventHosts.isNotEmpty ? eventHosts.first : 'Unknown';
  String get dateTime => '$eventDate · $eventTime';
  
  Color get categoryColor {
    switch (eventCategory) {
      case 'Academic':
        return const Color(0xFF594ABF); // kCreatePurple
      case 'Clubs':
        return Colors.green;
      case 'Social':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  
  String get categoryLabel => eventCategory ?? 'Uncategorized';
}