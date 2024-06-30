import 'package:flutter/material.dart';

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
  String? selectedCategory;
  bool isAscending = true;
  String searchText = '';
  List<Food> foodList = [
    Food('Karedok Bandung', 12000, 4.8, 1000, 'images/karedok.jpg'),
    Food('Nasi Goreng', 15000, 4.5, 2000, 'images/nasi_goreng.jpg'),
    Food('Sate Ayam', 20000, 4.7, 1500, 'images/sate_ayam.jpg'),
    // Tambahkan data lainnya di sini
  ];

  List<Food> filteredFoodList = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController ratingController = TextEditingController();
  final TextEditingController purchasesController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredFoodList = foodList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
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
            children:
                filteredFoodList.map((food) => FoodCard(food: food)).toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
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
      String name, int price, double rating, int purchases, String imageUrl) {
    setState(() {
      foodList.add(Food(name, price, rating, purchases, imageUrl));
      searchFoodList(); // Refresh the filtered list
    });
  }

  void _showAddFoodDialog(BuildContext context) {
    showDialog(
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
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(hintText: 'URL Gambar'),
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
                addFood(
                  nameController.text,
                  int.parse(priceController.text),
                  double.parse(ratingController.text),
                  int.parse(purchasesController.text),
                  imageUrlController.text,
                );
                Navigator.of(context).pop();
                nameController.clear();
                priceController.clear();
                ratingController.clear();
                purchasesController.clear();
                imageUrlController.clear();
              },
            ),
          ],
        );
      },
    );
  }
}

class Food {
  final String name;
  final int price;
  final double rating;
  final int purchases;
  final String imageUrl;

  Food(this.name, this.price, this.rating, this.purchases, this.imageUrl);
}

class FoodCard extends StatelessWidget {
  final Food food;

  const FoodCard({required this.food});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: <Widget>[
          Image.asset(
            food.imageUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                food.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 6.0,
              ),
              Text('Rp. ${food.price}'),
              const SizedBox(
                height: 6.0,
              ),
              Row(
                children: [
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.star,
                        size: 18.0,
                      ),
                      const SizedBox(
                        width: 4.0,
                      ),
                      Text('${food.rating}'),
                    ],
                  ),
                  const SizedBox(
                    width: 12.0,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.shopping_bag,
                        size: 16.0,
                      ),
                      const SizedBox(
                        width: 4.0,
                      ),
                      Text('${food.purchases}'),
                    ],
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}