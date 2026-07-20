import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamgo/presentation/pages/recipe_library_screen.dart';
import 'package:mamgo/presentation/widgets/recipe_card.dart';
import 'package:mamgo/presentation/pages/recipe_detail_screen.dart';

void main() {
  group('RecipeLibraryScreen Widget Tests', () {
    testWidgets('Hiển thị danh sách các món ăn mặc định', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: RecipeLibraryScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('📖 Cẩm nang nấu ăn'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(RecipeCard), findsWidgets);
    });

    testWidgets('Tìm kiếm món ăn thành công', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: RecipeLibraryScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.enterText(find.byType(TextField), 'Bún');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(RecipeCard), findsWidgets);
    });

    testWidgets('Tìm kiếm món ăn không có kết quả hiển thị empty state', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RecipeLibraryScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.enterText(
        find.byType(TextField),
        'Món ăn không thể nào tồn tại 123456',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Không tìm thấy công thức phù hợp'), findsOneWidget);
      expect(find.byType(RecipeCard), findsNothing);
    });

    testWidgets('Lọc theo kiểu ẩm thực', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: RecipeLibraryScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Hàn Quốc'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Chuyển sang RecipeDetailScreen khi bấm vào RecipeCard', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RecipeLibraryScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.byType(RecipeCard).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(RecipeDetailScreen), findsOneWidget);
    });

    testWidgets('Nút xóa (X) trong ô tìm kiếm hoạt động và reset danh sách', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: RecipeLibraryScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Nhập từ khóa
      await tester.enterText(find.byType(TextField), 'Món ăn không thể nào tồn tại 123456');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      
      // Đảm bảo list trống
      expect(find.byType(RecipeCard), findsNothing);

      // Bấm nút X (Clear)
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      
      // Đảm bảo list đã reset về ban đầu
      expect(find.byType(RecipeCard), findsWidgets);
    });

    testWidgets('Tìm kiếm với toàn khoảng trắng (whitespace) không làm crash và trả về toàn bộ danh sách', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: RecipeLibraryScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Nhập khoảng trắng
      await tester.enterText(find.byType(TextField), '     ');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Vì .trim() được gọi, từ khóa thành rỗng -> danh sách mặc định
      expect(find.byType(RecipeCard), findsWidgets);
    });
  });
}
