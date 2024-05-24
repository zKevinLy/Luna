import 'package:flutter/material.dart';
import 'package:luna/models/content_info.dart';
import 'package:luna/components/pages/content_layout.dart';
import 'package:luna/Providers/novels/light_novel_pub.dart';
import 'package:luna/Providers/manga/batoto.dart';

class CardLayout extends StatefulWidget {
  final String tabType;

  const CardLayout({super.key, required this.tabType});

  @override
  _CardLayoutState createState() => _CardLayoutState();
}

class _CardLayoutState extends State<CardLayout> {
  late ScrollController _scrollController;
  List<ContentData> cardItems = [];
  int currentPage = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _fetchDataAndThenInit();
  }

  void _fetchDataAndThenInit() {
    _fetchData([currentPage]).then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initialFetchData(context);
      });
    });
  }

  
  void _initialFetchData(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    int crossAxisCount = (size.width / 200).floor();
    if (crossAxisCount < 1) crossAxisCount = 1;

    double cardWidth =
        (size.width - ((crossAxisCount - 1) * 10)) / crossAxisCount;
    double cardHeight = cardWidth * 1.33;
    int rowsCount = (size.height / (cardHeight + 10)).floor();
    int totalCards = crossAxisCount * rowsCount;

    if (cardItems.isNotEmpty && cardItems.length < totalCards) {
      int totalPages = (totalCards / cardItems.length).ceil();
      List<int> pageList = [];
      for (int i = 1; i <= totalPages; i++) {
        pageList.add(i);
      }
      _fetchData(pageList);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData(List<int> pages) async {
    setState(() {
      isLoading = true;
    });
    final List<ContentData> newData = await fetchBrowseList(pages);
    setState(() {
      isLoading = false;
      cardItems.addAll(newData);
      currentPage+= pages.length;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!isLoading) {
        _fetchData([currentPage]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _buildGridView(context, constraints);
      },
    );
  }

  Widget _buildGridView(BuildContext context, BoxConstraints constraints) {
    int crossAxisCount = (constraints.maxWidth / 200).floor();
    if (crossAxisCount < 1) crossAxisCount = 1;

    double cardWidth =
        (constraints.maxWidth - ((crossAxisCount - 1) * 10)) /
            crossAxisCount;
    double cardHeight = cardWidth * 1.33;

    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: cardWidth / cardHeight,
      ),
      itemCount: cardItems.length + 1, // Adding 1 for the load more item
      itemBuilder: (context, index) {
        if (index < cardItems.length) {
          return _buildCard(context, cardWidth, cardHeight, index);
        } else {
          return _buildLoadMoreItem();
        }
      },
    );
  }

  Widget _buildLoadMoreItem() {
    return GestureDetector(
      onTap: () {
        if (!isLoading) {
          _fetchData([currentPage]);
        }
      },
      child: Center(
        child: SizedBox(
          width: 100, // Adjust width as needed
          height: 50, // Adjust height as needed
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Center(
              child: isLoading
                  ? const CircularProgressIndicator() // Show loader if loading
                  : const Text(
                      'Load More',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildCard(BuildContext context, double cardWidth, double cardHeight,
      int index) {
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
                _buildCardImage(cardItems[index].imageURI),
                _buildTitle(cardItems[index].title),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardImage(String imageURI) {
    return Expanded(
      child: Image.network(
        imageURI,
        fit: BoxFit.cover,
        width: double.infinity,
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
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

  Future<List<ContentData>> fetchBrowseList(List<int> pageNumbers) async {
  switch (widget.tabType) {
    case 'novel':
      return await LightNovelPub().fetchBrowseList(pageNumbers);
    case 'manga':
      return await Batoto().fetchBrowseList(pageNumbers);
    default:
      return [];
  }
}
}
