import 'package:flutter/material.dart';

// Represents a QR Code item with all its metadata
// This model class stores information about a QR code including:
// - Unique identifier
// - User-defined title
// - Actual content (URL, text, contact, etc.)
// - Creation timestamp
// - Visual color for UI differentiation
// - Source of creation (scanned, generated, or manual)

class QRCodeItem {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final Color color;
  final String source;

  QRCodeItem({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.color = Colors.blue,
    this.source = 'manual',
  });

  // Converts the QRCodeItem to a JSON-serializable map
  // 
  // Used for persistent storage with SharedPreferences.
  // Converts DateTime to ISO string and Color to integer value.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'color': color.value,
      'source': source,
    };
  }

  // Creates a QRCodeItem from a JSON map
  //
  // Used for loading saved QR codes from SharedPreferences.
  // Parses ISO string to DateTime and integer to Color.
  
  factory QRCodeItem.fromJson(Map<String, dynamic> json) {
    return QRCodeItem(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      color: Color(json['color']),
      source: json['source'] ?? 'manual',
    );
  }
}