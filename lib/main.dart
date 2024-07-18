import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk membaca file JSON
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<String> list = <String>['Nama', 'Harga', 'Ulasan', 'Pembelian'];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FoodPage(),
    );
  }
}

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  String? selectedCategory = 'Nama';
  bool isAscending = true;
  String searchText = '';
  List<Food> foodList = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController ratingController = TextEditingController();
  final TextEditingController purchasesController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  String? pickedImagePath;

  @override
  void initState() {
    super.initState();
    loadFoodList();
  }

  Future<void> loadFoodList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? foodListString = prefs.getString('foodList');
    if (foodListString != null) {
      List<Food> loadedList = (json.decode(foodListString) as List)
          .map((data) => Food.fromJson(data))
          .toList();
      setState(() {
        foodList = loadedList;
        filteredFoodList = loadedList;
        sortFoodList();
      });
    } else {
      String jsonString = await rootBundle.loadString('assets/data/food_data.json');
      List<dynamic> jsonResponse = json.decode(jsonString);
      foodList = jsonResponse.map((data) => Food.fromJson(data)).toList();
      saveFoodList(); // Save initial list to SharedPreferences
      filteredFoodList = foodList;
      sortFoodList();
    }
  }

  Future<void> saveFoodList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('foodList',
        json.encode(foodList.map((food) => food.toJson()).toList()));
  }

  List<Food> filteredFoodList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        title: const Text(
          'DAFTAR MENU',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                  searchFoodList();
                });
              },
              decoration: const InputDecoration(
                hintText: 'Lagi cari apa...',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                contentPadding:
                EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: DropdownButton<String>(
                    items: list.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    value: selectedCategory,
                    isExpanded: true,
                    hint: const Text('Urut Berdasarkan'),
                    onChanged: (String? value) {
                      setState(() {
                        selectedCategory = value;
                        sortFoodList();
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  ),
                  onPressed: () {
                    setState(() {
                      isAscending = !isAscending;
                      sortFoodList();
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          Column(
            children: filteredFoodList.asMap().entries.map((entry) {
              int index = entry.key;
              Food food = entry.value;
              return FoodCard(
                food: food,
                index: index,
                onEditPrice: editFoodPrice,
                onRemove: removeFood,
              );
            }).toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        onPressed: () {
          _showAddFoodDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void searchFoodList() {
    if (searchText.isEmpty) {
      filteredFoodList = foodList;
    } else {
      filteredFoodList = foodList
          .where((food) =>
          food.name.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    }
    if (selectedCategory != null) {
      sortFoodList();
    }
  }

  void sortFoodList() {
    if (selectedCategory == null) return;
    setState(() {
      quickSort(
          filteredFoodList, 0, filteredFoodList.length - 1, selectedCategory!);
    });
    saveFoodList(); // Save changes to SharedPreferences
  }

  void quickSort(List<Food> list, int low, int high, String category) {
    if (low < high) {
      int pi = partition(list, low, high, category);
      quickSort(list, low, pi - 1, category);
      quickSort(list, pi + 1, high, category);
    }
  }

  int partition(List<Food> list, int low, int high, String category) {
    Food pivot = list[high];
    int i = low - 1;

    for (int j = low; j < high; j++) {
      bool condition = false;
      if (category == 'Nama') {
        condition = isAscending
            ? list[j].name.compareTo(pivot.name) < 0
            : list[j].name.compareTo(pivot.name) > 0;
      } else if (category == 'Harga') {
        condition = isAscending
            ? list[j].price < pivot.price
            : list[j].price > pivot.price;
      } else if (category == 'Ulasan') {
        condition = isAscending
            ? list[j].rating < pivot.rating
            : list[j].rating > pivot.rating;
      } else if (category == 'Pembelian') {
        condition = isAscending
            ? list[j].purchases < pivot.purchases
            : list[j].purchases > pivot.purchases;
      }

      if (condition) {
        i++;
        swap(list, i, j);
      }
    }
    swap(list, i + 1, high);
    return i + 1;
  }

  void swap(List<Food> list, int i, int j) {
    Food temp = list[i];
    list[i] = list[j];
    list[j] = temp;
  }

  void addFood(
      String name, int price, double rating, int purchases, String imagePicker,
      {bool isAsset = false}) {
    setState(() {
      foodList.add(
          Food(name, price, rating, purchases, imagePicker, isAsset: isAsset));
      searchFoodList();
      saveFoodList();
    });
  }

  void editFoodPrice(int index, int newPrice) {
    setState(() {
      foodList[index].price = newPrice;
      searchFoodList();
      saveFoodList();
    });
  }

  void removeFood(int index) {
    setState(() {
      foodList.removeAt(index);
      searchFoodList();
      saveFoodList();
    });
  }

  void _showAddFoodDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tambah Baru'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: 'Nama Makanan'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(hintText: 'Harga'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: ratingController,
                  decoration: const InputDecoration(hintText: 'Ulasan'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: purchasesController,
                  decoration: const InputDecoration(hintText: 'Pembelian'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12.0),
                ElevatedButton(
                  onPressed: () async {
                    final pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        pickedImagePath = pickedFile.path;
                      });
                    }
                  },
                  child: const Text('Pilih Gambar'),
                ),
                if (pickedImagePath != null)
                  Image.file(
                    File(pickedImagePath!),
                    width: 100,
                    height: 100,
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Tambah'),
              onPressed: () {
                if (pickedImagePath != null) {
                  addFood(
                    nameController.text,
                    int.parse(priceController.text),
                    double.parse(ratingController.text),
                    int.parse(purchasesController.text),
                    pickedImagePath!,
                    isAsset: false,
                  );
                  Navigator.of(context).pop();
                  nameController.clear();
                  priceController.clear();
                  ratingController.clear();
                  purchasesController.clear();
                  pickedImagePath = null;
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Data'),
          content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () {
                removeFood(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class Food {
  String name;
  int price;
  double rating;
  int purchases;
  String imagePicker;
  bool isAsset;

  Food(this.name, this.price, this.rating, this.purchases, this.imagePicker,
      {this.isAsset = true});

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'rating': rating,
    'purchases': purchases,
    'imagePicker': imagePicker,
    'isAsset': isAsset,
  };

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      json['name'] ?? '',
      json['price'] ?? 0,
      json['rating'] ?? 0.0,
      json['purchases'] ?? 0,
      json['imagePicker'] ?? '', // Berikan nilai default jika null
      isAsset: json['isAsset'] ?? true,
    );
  }
}

class FoodCard extends StatelessWidget {
  final Food food;
  final int index;
  final Function(int, int) onEditPrice;
  final Function(int) onRemove;

  const FoodCard({
    required this.food,
    required this.index,
    required this.onEditPrice,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 100,
            height: 100,
            child: food.imagePicker.isNotEmpty
                ? (food.isAsset
                ? Image.asset(
              food.imagePicker,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Placeholder();
              },
            )
                : Image.file(
              File(food.imagePicker),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Placeholder();
              },
            ))
                : const Placeholder(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  food.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text('Rp. ${food.price}'),
                const SizedBox(height: 6.0),
                Row(
                  children: [
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.star,
                          size: 18.0,
                        ),
                        const SizedBox(width: 4.0),
                        Text('${food.rating}'),
                      ],
                    ),
                    const SizedBox(width: 12.0),
                    Row(
                      children: [
                        const Icon(Icons.shopping_bag, size: 16.0),
                        const SizedBox(width: 4.0),
                        Text('${food.purchases}'),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditPriceDialog(context, index, food.price);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmationDialog(context, index);
            },
          ),
        ],
      ),
    );
  }

  void _showEditPriceDialog(BuildContext context, int index, int currentPrice) {
    final TextEditingController priceController = TextEditingController();
    priceController.text = currentPrice.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Harga'),
          content: TextField(
            controller: priceController,
            decoration: const InputDecoration(hintText: 'Harga Baru'),
            keyboardType: TextInputType.number,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Simpan'),
              onPressed: () {
                onEditPrice(index, int.parse(priceController.text));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Data'),
          content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () {
                onRemove(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
