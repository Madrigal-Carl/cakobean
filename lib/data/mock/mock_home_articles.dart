import 'package:flutter/material.dart';

import 'package:cakobean/domain/models/home_article.dart';

/// Temporary mock data until this is wired to a real data source.
const mockHomeArticles = [
  HomeArticleModel(
    title: 'Shade Tree Management for Sustainable Cacao Farming',
    imageUrl: 'https://picsum.photos/seed/shade-tree-cacao/800/600',
    color: Color(0xFF3B6E91),
  ),
  HomeArticleModel(
    title: 'Post-Harvest Fermentation Techniques',
    imageUrl: 'https://picsum.photos/seed/cacao-fermentation/800/600',
    color: Color(0xFF6E4B3B),
  ),
  HomeArticleModel(
    title: 'Improving Yield with Proper Pruning',
    imageUrl: 'https://picsum.photos/seed/cacao-pruning/800/600',
    color: Color(0xFF3B914E),
  ),
];
