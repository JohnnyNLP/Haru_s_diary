import 'package:flutter/material.dart';

import 'chart_model.dart';

final tableDecoration = BoxDecoration(
  color: Color.fromARGB(255, 241, 243, 241), // 범례 table배경색
  borderRadius: BorderRadius.circular(6),
  border: Border.all(
      color: Color.fromARGB(255, 255, 255, 255), width: 1), //범례 table border색
);

class CategoriesTable extends StatelessWidget {
  final List<Category> categories;
  final bool selectable;
  final ValueChanged<Category> onSelection;

  const CategoriesTable({
    Key? key,
    required this.categories,
    required this.onSelection,
    this.selectable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    final decoration =
        tableDecoration; // darkTableDecoration를 삭제하고 tableDecoration 사용
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: {
          0: const FractionColumnWidth(.1),
          1: FractionColumnWidth(selectable ? .4 : .6),
          2: const FractionColumnWidth(.3),
          if (selectable) 3: const FractionColumnWidth(.2),
        },
        children: categories
            .map((c) => _buildRow(c, decoration: decoration))
            .toList(),
      ),
    );
  }

  TableRow _buildRow(Category category, {required BoxDecoration decoration}) =>
      TableRow(
        decoration: decoration,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(color: category.color, height: 24),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              category.title,
              style: TextStyle(
                color: const Color.fromARGB(
                    255, 0, 0, 0), // 범례 감정 글자 색상으로 변경('기쁨' 또는 '슬픔'과 같은 텍스트)
              ),
            ),
          ),
          Text(
            '${category.total.toStringAsFixed(2)}%', //차트 화면의 각 섹션의 값들의 단위 변경
            style: TextStyle(
              color: const Color.fromARGB(255, 0, 0, 0), // 범례 값들 색상 변경
            ),
          ),
          if (selectable)
            IconButton(
              onPressed: () => onSelection(category),
              hoverColor: Colors.cyan.shade100,
              color: Colors.cyan.shade700, // 돋보기 색깔 변경
              padding: const EdgeInsets.all(10),
              splashRadius: 18,
              icon: const Icon(Icons.zoom_in),
            ),
        ],
      );
}

class SubCategoriesTable extends StatelessWidget {
  final List<SubCategory> subCategories;

  const SubCategoriesTable({Key? key, required this.subCategories})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);

    final decoration =
        tableDecoration; // darkTableDecoration를 삭제하고 tableDecoration 사용
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FractionColumnWidth(.1),
          1: FractionColumnWidth(.5),
          2: FractionColumnWidth(.4),
        },
        children: subCategories
            .map((e) => _buildRow(subCategory: e, decoration: decoration))
            .toList(),
      ),
    );
  }

  TableRow _buildRow({
    required SubCategory subCategory,
    required BoxDecoration decoration,
  }) =>
      TableRow(
        decoration: decoration,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(color: subCategory.color, height: 24),
          ),
          Text(
            subCategory.title,
            style: TextStyle(
              color: const Color.fromARGB(
                  255, 0, 0, 0), // 차트의 각 섹션 클릭시, '하위 값들의 글자 색상' 변경
            ),
          ),
          Text(
            '${subCategory.total.toStringAsFixed(2)}%', // 차트 화면의 각 섹션을 '클릭'했을 때의 하위 값들의 단위 변경
            style: TextStyle(
              color: const Color.fromARGB(
                  255, 0, 0, 0), // 차트의 각 섹션 클릭시, '하위 값'들의 색상 변경
            ),
          )
        ],
      );
}
