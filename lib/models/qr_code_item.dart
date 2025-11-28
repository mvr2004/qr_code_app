import 'package:flutter/material.dart';

class QRCodeItem {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final Color color;
  final String source; // 'generated', 'scanned', 'manual'

  QRCodeItem({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.color = Colors.blue,
    this.source = 'manual',
  });

  // Converter para JSON
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

  // Criar do JSON
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