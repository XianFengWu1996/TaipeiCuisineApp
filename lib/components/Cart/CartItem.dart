class CartItem {
  int id;
  String foodId;
  String foodName;
  String foodChineseName;
  double price;
  int quantity;

  CartItem({
    this.id,
    this.foodId,
    this.foodName,
    this.foodChineseName,
    this.price,
    this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json['id'],
    foodId: json['food_id'],
    foodName:  json['name'],
    foodChineseName: json['name_chinese'],
    price: json['price'],
    quantity: json['quantity']
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "food_id": foodId,
    "name": foodName,
    "name_chinese": foodChineseName,
    "price": price,
    "quantity": quantity
  };
}
