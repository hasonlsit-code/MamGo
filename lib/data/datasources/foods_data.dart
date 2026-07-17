import 'package:mamgo/domain/entities/food_entity.dart';

class FoodsData {
  static const List<Food> all = [
    Food(
      id: 'pho',
      name: 'Phở Bò',
      description:
          'Phở truyền thống với nước dùng xương bò thơm ngon, bánh phở mềm, thịt bò tươi và rau thơm.',
      tags: ['savory', 'soup', 'warm'],
      cuisines: ['Việt Nam'],
      calories: 450,
      prepTime: '30 phút',
      difficulty: 'Trung bình',
      emoji: '🍜',
      mealType: 'any',
      imageUrl:
          'https://images.unsplash.com/photo-1604579839996-5c35cd7082b9?w=500&h=400&fit=crop&q=80',
    ),
    Food(
      id: 'banh_mi',
      name: 'Bánh Mì',
      description:
          'Bánh mì giòn rụm kẹp thịt nguội, pate, rau thơm, dưa chua và tương ớt đặc trưng Sài Gòn.',
      tags: ['savory', 'crispy', 'quick'],
      cuisines: ['Việt Nam'],
      calories: 380,
      prepTime: '10 phút',
      difficulty: 'Dễ',
      emoji: '🥖',
      mealType: 'breakfast',
      imageUrl:
          'https://images.unsplash.com/photo-1600628421055-4d30de868b8f?w=500&h=400&fit=crop&q=80',
    ),
    Food(
      id: 'com_tam',
      name: 'Cơm Tấm',
      description:
          'Cơm tấm với sườn nướng thơm lừng, bì, chả trứng và nước mắm chua ngọt đặc sản Sài Gòn.',
      tags: ['savory', 'grilled', 'rice'],
      cuisines: ['Việt Nam'],
      calories: 620,
      prepTime: '45 phút',
      difficulty: 'Trung bình',
      emoji: '🍚',
      mealType: 'lunch',
      imageUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&h=400&fit=crop&q=80',
    ),
    Food(
      id: 'bun_bo_hue',
      name: 'Bún Bò Huế',
      description:
          'Bún bò đặc trưng xứ Huế với nước dùng cay nồng, thịt bò giòn và chả cua hấp dẫn.',
      tags: ['spicy', 'soup', 'savory'],
      cuisines: ['Việt Nam'],
      calories: 520,
      prepTime: '60 phút',
      difficulty: 'Khó',
      emoji: '🍲',
      mealType: 'any',
      imageUrl:
          'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=500&h=400&fit=crop&q=80',
    ),
    Food(
      id: 'banh_xeo',
      name: 'Bánh Xèo',
      description:
          'Bánh xèo giòn vàng với nhân tôm, thịt heo, giá đỗ, cuốn rau xanh chấm nước mắm chua ngọt.',
      tags: ['crispy', 'savory', 'seafood'],
      cuisines: ['Việt Nam'],
      calories: 480,
      prepTime: '40 phút',
      difficulty: 'Trung bình',
      emoji: '🥞',
      mealType: 'lunch',
      imageUrl:
          'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=500&h=400&fit=crop&q=80',
    ),
    Food(
      id: 'goi_cuon',
      name: 'Gỏi Cuốn',
      description:
          'Gỏi cuốn tươi với tôm, thịt heo, rau thơm, bún, cuốn bánh tráng chấm tương đậu thơm ngon.',
      tags: ['fresh', 'light', 'seafood', 'healthy'],
      cuisines: ['Việt Nam'],
      calories: 280,
      prepTime: '20 phút',
      difficulty: 'Dễ',
      emoji: '🌯',
      mealType: 'any',
      imageUrl:
          'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=500&h=400&fit=crop&q=80',
    ),
    Food(
      id: 'mi_quang',
      name: 'Mì Quảng',
      description:
          'Mì Quảng đặc sản xứ Quảng với sợi mì vàng, nhân tôm thịt, bánh đa mè giòn hấp dẫn.',
      tags: ['savory', 'noodle'],
      cuisines: ['Việt Nam'],
      calories: 490,
      prepTime: '45 phút',
      difficulty: 'Trung bình',
      emoji: '🍝',
      mealType: 'lunch',
      imageUrl:
          'https://images.unsplash.com/photo-1512003867696-6d5ce6835040?w=500&h=400&fit=crop&q=80',
    ),
    Food(
      id: 'com_ga',
      name: 'Cơm Gà',
      description:
          'Cơm gà thơm dẻo với thịt gà luộc mềm ngọt, hành phi vàng và nước mắm gừng đậm đà.',
      tags: ['savory', 'rice', 'light'],
      cuisines: ['Việt Nam'],
      calories: 540,
      prepTime: '50 phút',
      difficulty: 'Trung bình',
      emoji: '🍗',
      mealType: 'any',
      imageUrl:
          'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=500&h=400&fit=crop&q=80',
    ),
    Food(
      id: 'banh_cuon',
      name: 'Bánh Cuốn',
      description:
          'Bánh cuốn mỏng nhân thịt heo và mộc nhĩ, chan nước mắm chua ngọt với chả lụa thanh ngon.',
      tags: ['savory', 'steamed', 'light'],
      cuisines: ['Việt Nam'],
      calories: 380,
      prepTime: '30 phút',
      difficulty: 'Trung bình',
      emoji: '🥟',
      mealType: 'breakfast',
      imageUrl:
          'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=500&h=400&fit=crop&q=80',
    ),
    Food(
      id: 'chao_ga',
      name: 'Cháo Gà',
      description:
          'Cháo gà bổ dưỡng thơm dẻo, kết hợp gừng thơm, hành lá và tiêu đen ấm lòng buổi sáng.',
      tags: ['savory', 'warm', 'light', 'healthy'],
      cuisines: ['Việt Nam'],
      calories: 320,
      prepTime: '60 phút',
      difficulty: 'Dễ',
      emoji: '🍲',
      mealType: 'breakfast',
      imageUrl:
          'https://images.unsplash.com/photo-1612927601601-6638404737ce?w=500&h=400&fit=crop&q=80',
    ),
    Food(
      id: 'bun_rieu',
      name: 'Bún Riêu',
      description:
          'Bún riêu cua đặc trưng với nước dùng cà chua, gạch cua và đậu hũ chiên thơm ngon chua ngọt.',
      tags: ['sour', 'savory', 'soup'],
      cuisines: ['Việt Nam'],
      calories: 430,
      prepTime: '50 phút',
      difficulty: 'Trung bình',
      emoji: '🍜',
      mealType: 'any',
      imageUrl:
          'https://images.unsplash.com/photo-1569407483866-e60d01b0ee59?w=500&h=400&fit=crop&q=80',
    ),
    Food(
      id: 'bibimbap',
      name: 'Bibimbap',
      description:
          'Cơm trộn Hàn Quốc với rau xào đầy màu sắc, thịt bò, trứng ốp la và tương ớt gochujang cay thơm.',
      tags: ['spicy', 'rice', 'healthy'],
      cuisines: ['Hàn Quốc'],
      calories: 580,
      prepTime: '35 phút',
      difficulty: 'Trung bình',
      emoji: '🍱',
      mealType: 'lunch',
      imageUrl:
          'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=500&h=400&fit=crop&q=80',
    ),
    Food(
      id: 'ramen',
      name: 'Ramen',
      description:
          'Mì ramen Nhật Bản với nước dùng đậm đà, thịt xá xíu, trứng ngâm và rong biển đặc trưng.',
      tags: ['savory', 'soup', 'noodle'],
      cuisines: ['Nhật Bản'],
      calories: 550,
      prepTime: '60 phút',
      difficulty: 'Khó',
      emoji: '🍜',
      mealType: 'dinner',
      imageUrl:
          'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?w=500&h=400&fit=crop&q=80',
    ),
    Food(
      id: 'sushi',
      name: 'Sushi',
      description:
          'Sushi truyền thống Nhật Bản với cá tươi ngon, cơm giấm và wasabi đặc trưng tinh tế.',
      tags: ['fresh', 'seafood', 'light'],
      cuisines: ['Nhật Bản'],
      calories: 350,
      prepTime: '45 phút',
      difficulty: 'Khó',
      emoji: '🍣',
      mealType: 'dinner',
      imageUrl:
          'https://images.unsplash.com/photo-1553621042-f6e147245754?w=500&h=400&fit=crop&q=80',
    ),
    Food(
      id: 'pizza',
      name: 'Pizza',
      description:
          'Pizza Ý truyền thống với đế bánh giòn, sốt cà chua, phô mai mozzarella và topping tươi ngon.',
      tags: ['savory', 'cheese'],
      cuisines: ['Phương Tây'],
      calories: 680,
      prepTime: '50 phút',
      difficulty: 'Trung bình',
      emoji: '🍕',
      mealType: 'dinner',
      imageUrl:
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500&h=400&fit=crop&q=80',
    ),
    Food(
      id: 'salad',
      name: 'Salad Rau Củ',
      description:
          'Salad tươi mát với rau xanh, cà chua bi, dưa leo, ô liu và sốt caesar mát lành.',
      tags: ['fresh', 'healthy', 'light', 'vegetarian'],
      cuisines: ['Phương Tây'],
      calories: 250,
      prepTime: '10 phút',
      difficulty: 'Dễ',
      emoji: '🥗',
      mealType: 'lunch',
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&h=400&fit=crop&q=80',
    ),
    Food(
      id: 'banh_mi_trung',
      name: 'Bánh Mì Trứng',
      description:
          'Bánh mì ốp la trứng chiên vàng thơm, sốt tương đen và rau thơm - bữa sáng nhanh gọn.',
      tags: ['savory', 'quick', 'breakfast'],
      cuisines: ['Việt Nam'],
      calories: 320,
      prepTime: '10 phút',
      difficulty: 'Dễ',
      emoji: '🍳',
      mealType: 'breakfast',
      imageUrl:
          'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?w=500&h=400&fit=crop&q=80',
    ),
    Food(
      id: 'hotpot',
      name: 'Lẩu Thái',
      description:
          'Lẩu Thái chua cay với nước dùng Tom Yum, hải sản tươi và rau củ phong phú đậm đà.',
      tags: ['spicy', 'sour', 'soup', 'seafood'],
      cuisines: ['Thái Lan'],
      calories: 480,
      prepTime: '30 phút',
      difficulty: 'Trung bình',
      emoji: '🫕',
      mealType: 'dinner',
      imageUrl:
          'https://images.unsplash.com/photo-1516714435082-980c3ef4d17f?w=500&h=400&fit=crop&q=80',
    ),
    Food(
      id: 'dim_sum',
      name: 'Dimsum',
      description:
          'Dimsum Hong Kong với há cảo tôm, xíu mại, bánh bao và các món hấp truyền thống thơm ngon.',
      tags: ['savory', 'steamed', 'light', 'seafood'],
      cuisines: ['Trung Quốc'],
      calories: 420,
      prepTime: '45 phút',
      difficulty: 'Trung bình',
      emoji: '🥟',
      mealType: 'breakfast',
      imageUrl:
          'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=500&h=400&fit=crop&q=80',
    ),
    Food(
      id: 'cao_lau',
      name: 'Cao Lầu',
      description:
          'Cao lầu Hội An với sợi mì đặc biệt, thịt xíu, giá trụng và bánh đa giòn đặc sản phố Hội.',
      tags: ['savory', 'noodle'],
      cuisines: ['Việt Nam'],
      calories: 460,
      prepTime: '40 phút',
      difficulty: 'Khó',
      emoji: '🍜',
      mealType: 'lunch',
      imageUrl:
          'https://images.unsplash.com/photo-1551248429-40975aa4de74?w=500&h=400&fit=crop&q=80',
    ),
  ];
}
