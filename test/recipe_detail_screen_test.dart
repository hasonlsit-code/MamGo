import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamgo/presentation/pages/recipe_detail_screen.dart';
import 'package:mamgo/data/models/recipe.dart';

void main() {
  group('RecipeDetailScreen Widget Tests', () {
    final testRecipe = Recipe(
      id: 'test_recipe_1',
      name: 'Món Test Đặc Biệt',
      description: 'Mô tả chi tiết món ăn test',
      ingredients: ['Thịt heo', 'Rau xanh'],
      steps: ['Bước 1: Sơ chế', 'Bước 2: Nấu chín'],
      cuisine: 'Việt Nam',
      tags: ['Thơm ngon', 'Đặc sản'],
      prepTime: '10 phút',
      cookTime: '20 phút',
      servings: 2,
      difficulty: 'Dễ',
      imageUrl: '',
      emoji: '🍲',
    );

    testWidgets('Hiển thị đầy đủ các thông tin của món ăn', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: RecipeDetailScreen(recipe: testRecipe)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Món Test Đặc Biệt'), findsOneWidget);
      expect(find.text('🍲'), findsOneWidget);

      expect(find.text('10 phút'), findsOneWidget);
      expect(find.text('20 phút'), findsOneWidget);
      expect(find.text('2 người'), findsOneWidget);
      expect(find.text('Dễ'), findsOneWidget);

      expect(find.text('Mô tả chi tiết món ăn test'), findsOneWidget);

      expect(find.text('🛒 Nguyên liệu'), findsOneWidget);
      expect(find.text('👨‍🍳 Cách làm'), findsOneWidget);

      expect(find.text('Thịt heo'), findsOneWidget);
      expect(find.text('Rau xanh'), findsOneWidget);

      expect(find.text('Bước 1: Sơ chế'), findsOneWidget);
      expect(find.text('Bước 2: Nấu chín'), findsOneWidget);
    });

    testWidgets('Nút quay lại (Back) hoạt động bình thường', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecipeDetailScreen(recipe: testRecipe),
                      ),
                    );
                  },
                  child: const Text('Mở chi tiết'),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Mở màn hình chi tiết
      await tester.tap(find.text('Mở chi tiết'));
      await tester.pumpAndSettle();

      // Đảm bảo đang ở màn hình chi tiết
      expect(find.byType(RecipeDetailScreen), findsOneWidget);

      // Bấm nút back
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      // Đảm bảo màn hình chi tiết đã đóng
      expect(find.byType(RecipeDetailScreen), findsNothing);
      expect(find.text('Mở chi tiết'), findsOneWidget);
    });
  });
}
