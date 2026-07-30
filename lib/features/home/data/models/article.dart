import 'package:flutter/material.dart';

class ArticleModel {
  final String title;
  final String imageUrl;
  final Color color;

  const ArticleModel({
    required this.title,
    required this.imageUrl,
    required this.color,
  });
}

const mockCarouselArticles = [
  ArticleModel(
    title: 'Shade Tree Management for Sustainable Cacao Farming',
    imageUrl: 'https://picsum.photos/seed/shade-tree-cacao/800/600',
    color: Color(0xFF3B6E91),
  ),
  ArticleModel(
    title: 'Post-Harvest Fermentation Techniques',
    imageUrl: 'https://picsum.photos/seed/cacao-fermentation/800/600',
    color: Color(0xFF6E4B3B),
  ),
  ArticleModel(
    title: 'Improving Yield with Proper Pruning',
    imageUrl: 'https://picsum.photos/seed/cacao-pruning/800/600',
    color: Color(0xFF3B914E),
  ),
];
