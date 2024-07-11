// Package yang digunakan dalam program
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// Akhir dari package yang digunakan

// List data menu
const List<String> list = <String>['Nama', 'Harga', 'Ulasan', 'Pembelian'];
// Akhir dari list data menu


// Fungsi untuk menampilkan widget
void main() {
  runApp(const MyApp());
}
// Akhir dari fungsi untuk menampilkan widget


// Widget MaterialTheme 3
// MaterialTheme 3 adalah tema atau tampilan standar flutter
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
// Akhir dari widget MaterialTheme 3


// Membuat widget FoodPage
//
// Widget ini dibuat sebagai StatefulWidget
class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  _FoodPageState createState() => _FoodPageState();
}

// Mengatur Widget FoodPageState
//
// Widget ini akan memuat tampilan aplikasi
class _FoodPageState extends State<FoodPage> {
  // Urutan default data diatur bedasarkan nama menu
  String? selectedCategory = 'Nama';
  // Urutan default data diatur ascending
  bool isAscending = true;
  // Kolom pencarian data
  String searchText = '';
  // List data yang ditampilkan
  List<Food> foodList = [
    Food('Ayam Bakar', 22000, 4.7, 420, 'images/ayam_bakar.jpg'),
    Food('Ayam Penyet', 23000, 4.5, 314, 'images/ayam_cabe_ijo.jpg'),
    Food('Ayam Geprek', 22000, 4.8, 98, 'images/ayam_geprek.jpg'),
    Food('Bakso', 15000, 4.7, 570, 'images/bakso.jpg'),
    Food('Es Teh Manis', 6000, 4.9, 900, 'images/es_teh_manis.jpg'),
    Food('Ikan Bakar', 23000, 4.1, 230, 'images/ikan_bakar.jpg'),
    Food('Jus Alpukat', 12000, 4.6, 490, 'images/jus_alpukat.jpg'),
    Food('Jus Jeruk', 10000, 4.7, 890, 'images/jus_jeruk.jpg'),
    Food('Kopi', 6000, 4.9, 1300, 'images/kopi.jpeg'),
    Food('Nasi Goreng', 14000, 4.8, 1400, 'images/nasi_goreng.jpg'),
  ];
  // Akhir dati list data yang dtampilkan

  // Data yang telah diurutkan atau dicari
  List<Food> filteredFoodList = [];

  // Variabel yang akan menyimpan data baru yang ditambahkan
  final TextEditingController nameController = TextEditingController(); // Nama
  final TextEditingController priceController = TextEditingController(); // Harga
  final TextEditingController ratingController = TextEditingController(); // Rating
  final TextEditingController purchasesController = TextEditingController(); // Harga
  final ImagePicker picker = ImagePicker(); // Gambar
  String? pickedImagePath; // Direktori gambar yang diupload

  // Keadaan awal data ditampilkan / diinisialisasikan
  // Urutan default berdasarkan nama
  @override
  void initState() {
    super.initState();
    filteredFoodList = foodList;
    sortFoodList();
  }

  // Tampilan Aplikasi
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Appbar
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        title: const Text(
          'DAFTAR MENU',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      // Tampilan data menu
      // Ditampilkan dalam bentuk list
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 8.0),

          // Kolom pencarian
          //
          // Digunakan untuk mencari data makanan yang ditampilkan
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
          // Akhir dari kolom pencarian

          const SizedBox(height: 8.0),

          // Kategori Menu
          // Kategori menu berbentuk dropdown, nantinya data bisa urutkan berdasarkan kategori
          // Terdapat kategori nama, harga, ulasan, dan banyaknya pembelian
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
                // Akhir dari kategori menu

                // Tombol Ascending/Descending
                // Berfungsi untuk menentukan urutan yang ditampilkan
                // Ditampilkan secara ascending atau descending
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
                // Akhir dari tombol ascending/descending
              ],
            ),
          ),
          const SizedBox(height: 8.0),

          // Menampilkan data yang sudah diurutkan atau dicari
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
          // Akhir dari tampilan data
        ],
      ),

      // Tombol untuk menambah data baru
      // User dapat menambahkan data baru
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        onPressed: () {
          _showAddFoodDialog(context);
        },
        child: const Icon(Icons.add),
      ),
      // Akhir dari tombol tambah data
    );
  }
  // Akhir dari tampilan aplikasi


  // Fungsi untuk melakukan pencarian data
  // Mencari data dengan metode SEQUENTIAL SEARCH
  // User dapat melakukan pencarian data hanya BERDASARKAN NAMA menu
  void searchFoodList() {
    // Pengkondisian
    // Jika kolom pencarian kosong, ditampilkan data sudah ada
    if (searchText.isEmpty) {
      filteredFoodList = foodList;
      // Jika mengetikkan huruf, maka ditampilkan data yang terdapat huruf tersebut
    } else {
      filteredFoodList = foodList
          .where((food) =>
          food.name.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    }
    // Jika kategori tidak dipilih, ditampilkan data yang ada
    if (selectedCategory != null) {
      sortFoodList();
    }
  }
  // Akhir dari fungsi pencarian data


  // Fungsi untuk mengurutkan data
  //
  // Fungsi sortFoodList akan menampilkan data yang sudah diurutkan atau belum diurutkan
  void sortFoodList() {
    if (selectedCategory == null) return;
    setState(() {
      quickSort(
          filteredFoodList, 0, filteredFoodList.length - 1, selectedCategory!);
    });
  }
  // Akhir dari fungsi sortFoodList

  // Fungsi Quick Sort
  // Mengurutkan data dengan metode QUICK SORT
  void quickSort(List<Food> list, int low, int high, String category) {
    if (low < high) {
      int pi = partition(list, low, high, category);
      quickSort(list, low, pi - 1, category);
      quickSort(list, pi + 1, high, category);
    }
  }

  // Partisi array / list
  int partition(List<Food> list, int low, int high, String category) {
    Food pivot = list[high];
    int i = low - 1;

    // Pengulangan untuk pengecekan setiap data
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

      // Pengkondisian untuk mengurutkan data
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
  // Akhir dari fungsi pengurutan data


  // Fungsi untuk menambah data menu baru
  void addFood(String name, int price, double rating, int purchases, String imagePicker) {
    setState(() {
      foodList.add(Food(name, price, rating, purchases, imagePicker));
      searchFoodList(); // Refresh the filtered list
    });
  }
  // Akhir dari fungsi menambah data menu baru


  // Fungsi untuk mengubah harga menu
  void editFoodPrice(int index, int newPrice) {
    setState(() {
      foodList[index].price = newPrice;
      searchFoodList(); // Refresh the filtered list
    });
  }
  // Akhir dari fungsi untuk mengubah harga menu

  // Fungsi untuk menghapus data menu
  void removeFood(int index) {
    setState(() {
      foodList.removeAt(index);
      searchFoodList(); // Refresh the filtered list
    });
  }
  // Akhir dari fungsi untuk menghapus data menu


  // Dialog Box untuk menambah data baru
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
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        pickedImagePath = pickedFile.path;
                      });
                    }
                  },
                  child: const Text('Pilih Gambar'),
                ),

                // Menggunakan gambar dummy jika tidak memilih gambar
                if (pickedImagePath != null)
                  Image.network(
                    pickedImagePath!,
                    width: 100,
                    height: 100,
                  ),
              ],
            ),
          ),

          // Validasi untuk menambah data
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
  // Akhir dari dialog box
}

// Class Food
// Class yang digunakan untuk data makanan
class Food {
  String name;
  int price;
  double rating;
  int purchases;
  String imagePicker;

  Food(this.name, this.price, this.rating, this.purchases, this.imagePicker);
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
  // Akhir dari Class Food

  // Widget Food Card
  // untuk menampilkan menu dalam bentuk card
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 100,
            height: 100,
            child: Image.network(
              food.imagePicker,
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
                        const Icon(
                          Icons.shopping_bag,
                          size: 16.0,
                        ),
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
    // Akhir dari widget food card
  }

  // Dialog Box untuk mengubah harga
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
          // Validasi
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
  // Akhir dari dialog box ubah harga


  // Validasi untuk menghapus data
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
  // Akhir dari validasi untuk menghapus data
}
