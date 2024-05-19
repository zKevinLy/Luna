import 'package:flutter/material.dart';
import 'package:luna/models/content_info.dart';
import 'package:luna/components/pages/content_layout.dart';

class CardLayout extends StatelessWidget {
  final List<ContentData> cardItems;

  const CardLayout({super.key, required this.cardItems});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _buildGridView(context, constraints);
      },
    );
  }

  Widget _buildGridView(BuildContext context, BoxConstraints constraints) {
    int crossAxisCount = (_calculateMaxWidth(constraints) / 200).floor();
    if (crossAxisCount < 1) crossAxisCount = 1;

    double cardWidth = (_calculateMaxWidth(constraints) - ((crossAxisCount - 1) * 10)) / crossAxisCount;
    double cardHeight = cardWidth * 1.33;

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: cardWidth / cardHeight,
      ),
      itemCount: cardItems.length,
      itemBuilder: (context, index) {
        return _buildCard(context, cardWidth, cardHeight, index);
      },
    );
  }

  double _calculateMaxWidth(BoxConstraints constraints) {
    return constraints.maxWidth;
  }

  Widget _buildCard(BuildContext context, double cardWidth, double cardHeight, int index) {
    return GestureDetector(
      onTap: () {
        _navigateToContentLayout(context, index);
      },
      child: Center(
        child: SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              children: [
                Expanded(
                  child: _buildCardImage(index),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    cardItems[index].title,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardImage(int index) {
    return Image.network(
      cardItems[index].imageURI,
      fit: BoxFit.cover,
      width: double.infinity,
    );
  }

  void _navigateToContentLayout(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContentLayout(cardItem: cardItems[index]),
      ),
    );
  }
}
