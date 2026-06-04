// models/cart_model.dart

class CartProductModel {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;

  CartProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  factory CartProductModel.fromJson(Map<String, dynamic> json) {
    // backend pakai 'ID' huruf kapital, fallback ke 'id'
    final int idValue = json['ID'] as int? ?? json['id'] as int? ?? 0;
    return CartProductModel(
      id: idValue,
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String? ?? '',
      category: json['category'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'image_url': imageUrl,
    'category': category,
  };
}

class CartItemModel {
  final int id;
  final int productId;
  final CartProductModel product;
  final int quantity;
  final double subtotal; // sudah dari API atau dihitung ulang

  CartItemModel({
    required this.id,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.subtotal,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final product = CartProductModel.fromJson(
      json['product'] as Map<String, dynamic>? ?? {},
    );
    final quantity = json['quantity'] as int? ?? 0;

    // Prioritas: pakai subtotal dari API jika > 0
    // Fallback: hitung sendiri price * quantity
    final apiSubtotal = (json['subtotal'] as num?)?.toDouble() ?? 0.0;
    final subtotal = apiSubtotal > 0 ? apiSubtotal : product.price * quantity;

    return CartItemModel(
      id: json['id'] as int? ?? 0,
      productId: json['product_id'] as int? ?? 0,
      product: product,
      quantity: quantity,
      subtotal: subtotal,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'product_id': productId,
    'product': product.toJson(),
    'quantity': quantity,
    'subtotal': subtotal,
  };
}

class CartModel {
  final List<CartItemModel> items;
  final double total; // dihitung ulang dari items, tidak percaya API
  final int itemCount; // total quantity (bukan panjang list)

  CartModel({
    required this.items,
    required this.total,
    required this.itemCount,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? [])
        .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Hitung total dari subtotal items
    final double calculatedTotal = items.fold(
      0.0,
      (sum, item) => sum + item.subtotal,
    );

    // Hitung jumlah item (akumulasi quantity)
    final int calculatedItemCount = items.fold(
      0,
      (sum, item) => sum + item.quantity,
    );

    return CartModel(
      items: items,
      total: calculatedTotal,
      itemCount: calculatedItemCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    'total': total,
    'item_count': itemCount,
  };
}
