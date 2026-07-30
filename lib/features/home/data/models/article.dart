import 'package:flutter/material.dart';

/// Model backing a single card in the "Newest Article" carousel
/// on the home page.
class ArticleModel {
  final String label;
  final String title;
  final Color color;

  const ArticleModel({
    required this.label,
    required this.title,
    required this.color,
  });
}

/// Temporary mock data until this is wired to a real data source.
const mockCarouselArticles = [
  ArticleModel(
    label: 'ARTICLE',
    title: 'Shade Tree Management for Sustainable Cacao Farming',
    color: Color(0xFF3B6E91),
  ),
  ArticleModel(
    label: 'ARTICLE',
    title: 'Post-Harvest Fermentation Techniques',
    color: Color(0xFF6E4B3B),
  ),
  ArticleModel(
    label: 'ARTICLE',
    title: 'Improving Yield with Proper Pruning',
    color: Color(0xFF3B914E),
  ),
];
