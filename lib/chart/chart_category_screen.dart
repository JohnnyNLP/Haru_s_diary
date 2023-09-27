import 'package:flutter/material.dart';

import 'donut/chart_view.dart';
import 'chart_fade_transition.dart';
import 'chart_model.dart';
import 'chart_subcategories_screen.dart';
import 'chart_tables.dart';

/// main screen
/// display the title, the categories donut chart and categories data table
///
class CategoryScreen extends StatelessWidget {
  final List<Category> categories;

  final ValueNotifier<int?> selectedCategoryIndex = ValueNotifier(null);

  CategoryScreen({Key? key, required this.categories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 16, top: 20, right: 60), // 텍스트 위치 조절
            child: Row(
              children: [
                const BackButton(
                    color: Color.fromARGB(255, 83, 78, 78)), // back 버튼 색
                Spacer(), // 버튼과 텍스트 사이 공간을 차지함
                Text(
                  '감정분석',
                  style: TextStyle(
                    color: Color.fromARGB(255, 47, 47, 48), // 차트 화면의 앱바 글자 색상
                    fontSize: 40, // 차트 화면의 앱바 글자 크기 변경
                    fontWeight: FontWeight.bold, // 글자 굵기 조절
                    // 다른 스타일 속성 설정
                  ),
                ),
                Spacer(), // 텍스트와 오른쪽 여백 사이 공간을 차지함
              ],
            ),
          ),
          ValueListenableBuilder<int?>(
            valueListenable: selectedCategoryIndex,
            builder: (context, categoryIndex, _) => CategoryDonutHero(
              categories: categories,
              selectedCategoryIndex: categoryIndex,
            ),
          ),
          CategoriesTable(
            categories: categories,
            onSelection: (category) {
              final selectedIndex = categories.indexOf(category);
              selectedCategoryIndex.value = selectedIndex;
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, anim1, anim2) => SubCategoryScreen(
                    key: ValueKey(category),
                    category: categories[selectedIndex],
                  ),
                  transitionsBuilder: fadeTransitionBuilder,
                  transitionDuration: donutDuration,
                  reverseTransitionDuration: donutDuration,
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

class CategoryDonutHero extends StatefulWidget {
  final List<Category> categories;

  final int? selectedCategoryIndex;

  const CategoryDonutHero({
    required this.categories,
    required this.selectedCategoryIndex,
    super.key,
  });

  @override
  State<CategoryDonutHero> createState() => _CategoryDonutHeroState();
}

class _CategoryDonutHeroState extends State<CategoryDonutHero>
    with TickerProviderStateMixin {
  late final anim = AnimationController(vsync: this, duration: donutDuration);

  int? selectedCategoryIndex;

  @override
  void initState() {
    super.initState();
    anim.forward();
  }

  @override
  void didUpdateWidget(covariant CategoryDonutHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategoryIndex != widget.selectedCategoryIndex) {
      selectedCategoryIndex = widget.selectedCategoryIndex;
    }
  }

  @override
  void dispose() {
    super.dispose();
    anim.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Hero(
            tag: 'donut',
            flightShuttleBuilder: _buildTransitionHero,
            child: ChartView(
              key: ValueKey(widget.categories),
              transitionProgress: 0,
              onSelection: (newIndex) {
                setState(() => selectedCategoryIndex = newIndex);
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, anim1, anim2) => SubCategoryScreen(
                      category: widget.categories[newIndex],
                    ),
                    reverseTransitionDuration: donutDuration,
                    transitionsBuilder: fadeTransitionBuilder,
                    transitionDuration: donutDuration,
                  ),
                );
              },
              categories: widget.categories,
              animation: anim,
            ),
          ),
        ),
      );

  Widget _buildTransitionHero(
    BuildContext context,
    Animation<double> heroAnim,
    HeroFlightDirection direction,
    BuildContext fromContext,
    BuildContext toContext,
  ) =>
      AnimatedBuilder(
        animation: heroAnim,
        builder: (context, _) => AspectRatio(
          aspectRatio: 1,
          child: ChartView(
            key: ValueKey(selectedCategoryIndex),
            selectedIndex: selectedCategoryIndex,
            transitionProgress: heroAnim.value,
            onSelection: (newIndex) {},
            categories: widget.categories,
            animation: const AlwaysStoppedAnimation(1),
          ),
        ),
      );
}
