// Library atau Package yang digunakan
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Menampilkan widget atau interface di emulator
void main() {
  runApp(const MyApp());
}

// Widget utama aplikasi
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

// Widget FoodPage yang merupakan tampilan utama aplikasi ini
class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  _FoodPageState createState() => _FoodPageState();
}

// State atau kondisi awal data yang ditampilkan
// sebelum ada perubahan
class _FoodPageState extends State<FoodPage> {
  String? selectedCategory = 'Nama'; // kategori awal
  bool isAscending = true; // urutan awal
  String searchText = ''; // pencarian awal = null
  List<Food> foodList = [
    Food('Ayam Bakar', 22000, 4.7, 420, 'assets/images/ayam_bakar.jpg', true),
    Food('Ayam Penyet', 23000, 4.5, 314, 'assets/images/ayam_cabe_ijo.jpg',
        true),
    Food('Ayam Geprek', 22000, 4.8, 98, 'assets/images/ayam_geprek.jpg', true),
    Food('Bakso', 15000, 4.7, 570, 'assets/images/bakso.jpg', true),
    Food(
        'Es Teh Manis', 6000, 4.9, 900, 'assets/images/es_teh_manis.jpg', true),
    Food('Ikan Bakar', 23000, 4.1, 230, 'assets/images/ikan_bakar.jpg', true),
    Food('Jus Alpukat', 12000, 4.6, 490, 'assets/images/jus_alpukat.jpg', true),
    Food('Jus Jeruk', 10000, 4.7, 890, 'assets/images/jus_jeruk.jpg', true),
    Food('Kopi', 6000, 4.9, 1300, 'assets/images/kopi.jpeg', true),
    Food(
        'Nasi Goreng', 14000, 4.8, 1400, 'assets/images/nasi_goreng.jpg', true),
  ]; // List untuk menyimpan data awal yang ditampilkan

  List<Food> filteredFoodList = []; // List untuk menyimpan data yang diubah

  // Dialog dan pengelola input user
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController ratingController = TextEditingController();
  final TextEditingController purchasesController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  String? pickedImagePath;

  @override
  // Fungsi untuk menampilkan data awal
  void initState() {
    super.initState();
    filteredFoodList = foodList;
    sortFoodList();
  }

  // Widget atau tampilan keseluruhan
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

  // Fungsi untuk mencari data berdasarkan teks
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

  // Fungsi untuk mengurutkan data
  void sortFoodList() {
    if (selectedCategory == null) return;
    setState(() {
      quickSort(
          filteredFoodList, 0, filteredFoodList.length - 1, selectedCategory!);
    });
  }

  // Fungsi implementasi pengurutan menggunakan QUICK SORT
  void quickSort(List<Food> list, int low, int high, String category) {
    if (low < high) {
      int pi = partition(list, low, high, category);
      quickSort(list, low, pi - 1, category);
      quickSort(list, pi + 1, high, category);
    }
  }

  // Bagian dari fungsi quick sort yang membagi daftar data
  // menjadi dua bagian pivot
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

  // Fungsi untuk menukar posisi data
  void swap(List<Food> list, int i, int j) {
    Food temp = list[i];
    list[i] = list[j];
    list[j] = temp;
  }

  // Fungsi untuk menambah objek atau data baru
  void addFood(String name, int price, double rating, int purchases,
      String imagePicker) {
    setState(() {
      foodList.add(Food(name, price, rating, purchases, imagePicker, false));
      searchFoodList();
    });
  }

  // Fungsi untuk mengubah harga
  void editFoodPrice(int index, int newPrice) {
    setState(() {
      foodList[index].price = newPrice;
      searchFoodList();
    });
  }

  // Fungsi untuk menghapus objek atau data
  void removeFood(int index) {
    setState(() {
      foodList.removeAt(index);
      searchFoodList();
    });
  }

  Future<void> _showAddFoodDialog(BuildContext context) async {
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
}

// Objek atau Class atau Struct
class Food {
  String name;
  int price;
  double rating;
  int purchases;
  String imagePicker;
  bool isAssetImage;

  Food(this.name, this.price, this.rating, this.purchases, this.imagePicker,
      this.isAssetImage);
}

// Widget untuk mengatur bagaimana data makanan ditampilkan
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
            child: food.isAssetImage
                ? Image.asset(
                    food.imagePicker,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    File(food.imagePicker),
                    fit: BoxFit.cover,
                  ),
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

const List<String> list = <String>['Nama', 'Harga', 'Ulasan', 'Pembelian'];
