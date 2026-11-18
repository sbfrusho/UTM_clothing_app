import '../../core/utils/json_parsing.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String imageUrl;

  factory CategoryModel.fromMap(Map<String, dynamic> map, {String? id}) =>
      CategoryModel(
        id: asString(map['categoryId'], fallback: id ?? ''),
        name: asString(map['categoryName']),
        imageUrl: asString(map['categoryImg']),
      );
}
