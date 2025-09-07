import 'package:flutter/material.dart';

class TechResource {
  final String title;
  final String type; // e.g., 'youtube', 'article', etc.
  final String url;

  TechResource({
    required this.title,
    required this.type,
    required this.url,
  });
}

class TechCategory {
  final String name;
  final IconData? iconData;
  final String? textIcon;
  
  final Color color;
  final List<TechResource> resources; // <-- add resources
  final String? imagePath;

  TechCategory(
    this.name,
    dynamic icon,
   
    this.color, {
    List<TechResource>? resources,
     this.imagePath,
  })  : iconData = icon is IconData ? icon : null,
        textIcon = icon is String ? icon : null,
        
        resources = resources ?? []; // <-- default to empty list

  bool get isText => textIcon != null;
}
