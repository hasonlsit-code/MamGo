import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamgo/domain/entities/food_entity.dart';
import 'package:mamgo/presentation/pages/food_detail_screen.dart';

void main() {
  group("Food Details", () {
    testWidgets("Display correct food information", (
      WidgetTester tester,
    ) async {
      const testFood = Food(
        id: 'test_food_123',
        name: 'Bún Chả Test',
        description: 'Món ăn đặc sản của Hà Nội',
        tags: ['Đặc sản', 'Thơm ngon'],
        cuisines: ['Món Việt', 'Món nướng'],
        calories: 550,
        prepTime: '30 phút',
        difficulty: 'Trung bình',
        emoji: '🍢',
        mealType: 'lunch',
        imageUrl: '',
      );

      await tester.pumpWidget(
        const MaterialApp(home: FoodDetailScreen(food: testFood)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Bún Chả Test'), findsWidgets);

      expect(find.text('Món ăn đặc sản của Hà Nội'), findsOneWidget);

      expect(find.text('🍢'), findsWidgets);

      expect(find.text('#Đặc sản'), findsOneWidget);
      expect(find.text('#Thơm ngon'), findsOneWidget);

      expect(find.text('550'), findsOneWidget);
      expect(find.text('30 phút'), findsOneWidget);
      expect(find.text('Trung bình'), findsWidgets);

      expect(find.text('Món Việt · Món nướng'), findsOneWidget);

      expect(find.text('Xem công thức đầy đủ'), findsOneWidget);
    });
  });
}
