import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart' as intl;
import '../../Widgets/Cards/cardItems_Details.dart';
import '../../Widgets/custom_text.dart';
import '../../const.dart';
import '../../models/suggest_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _items =
      FirebaseFirestore.instance.collection('items');
  String _searchString = '';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String _selectedQuantity = 'كيلو';
  String _selectedSortMethod = 'تاريخ الإضافة';
  bool _sortAscendingDate = false;
  bool _sortAscendingPrice = false;
  final GlobalKey<AutoCompleteTextFieldState<String>> _autoCompleteKey =
      GlobalKey();

  void _setSearchString(String value) {
    setState(() {
      _searchString = value;
    });
  }

  // ignore: unused_element
  void _setSelectedSortMethod(String value) {
    setState(() {
      _selectedSortMethod = value;
    });
  }

  void _toggleSortAscendingDate() {
    setState(() {
      _sortAscendingDate = !_sortAscendingDate;
    });
  }

  void _toggleSortAscendingPrice() {
    setState(() {
      _sortAscendingPrice = !_sortAscendingPrice;
    });
  }

  void _sortItems(List<DocumentSnapshot> items) {
    if (_selectedSortMethod == 'سعر المنتج') {
      items.sort((a, b) {
        final double priceA = a['سعر المنتج'] as double;
        final double priceB = b['سعر المنتج'] as double;
        return _sortAscendingPrice
            ? priceA.compareTo(priceB)
            : priceB.compareTo(priceA);
      });
    } else {
      items.sort((a, b) {
        final Timestamp timestampA = a['تاريخ الإضافة'] as Timestamp;
        final Timestamp timestampB = b['تاريخ الإضافة'] as Timestamp;
        return _sortAscendingDate
            ? timestampA.compareTo(timestampB)
            : timestampB.compareTo(timestampA);
      });
    }
  }

  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter setState /*You can rename this!*/) {
            return Container(
                color: const Color(0xff757575),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0))),
                  child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Scaffold(
                          body: Padding(
                              padding: const EdgeInsets.only(
                                top: 75,
                                right: 10,
                                left: 10,
                              ),
                              child: SingleChildScrollView(
                                child: Column(children: <Widget>[
                                  // ignore: prefer_const_constructors
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    // ignore: prefer_const_constructors
                                    child: customText(
                                        text: 'أضافة منتج جديد',
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: AutoCompleteTextField<String>(
                                      key: _autoCompleteKey,
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                        labelText: 'أسم المنتج',
                                        labelStyle: const TextStyle(
                                            color: primaryColor),
                                        fillColor: Colors.white,
                                        hintText: 'أدخل أسم المنتج',
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: primaryColor, width: 2.0),
                                        ),
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Image.asset(
                                            'assets/images/commodity.png',
                                            width: 25,
                                            height: 25,
                                            color: secondaryColor,
                                          ),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                      ),
                                      suggestions: suggestions,
                                      itemSubmitted: (String suggestion) {
                                        setState(() {
                                          _nameController.text = suggestion;
                                        });
                                      },
                                      textChanged: (String value) {
                                        setState(() {});
                                      },
                                      itemBuilder: (BuildContext context,
                                          String suggestion) {
                                        return ListTile(
                                          title: Text(suggestion),
                                        );
                                      },
                                      itemSorter: (String a, String b) {
                                        return a.compareTo(b);
                                      },
                                      itemFilter:
                                          (String suggestion, String query) {
                                        return suggestion
                                            .toLowerCase()
                                            .contains(query.toLowerCase());
                                      },
                                      clearOnSubmit: false,
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextFormField(
                                          controller: _priceController,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          decoration: InputDecoration(
                                            labelText: 'سعر المنتج',
                                            labelStyle: const TextStyle(
                                                color: primaryColor),
                                            fillColor: Colors.white,
                                            hintText: 'أدخل سعر المنتج',
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: primaryColor,
                                                  width: 2.0),
                                            ),
                                            prefixIcon: Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: Image.asset(
                                                'assets/images/coin.png',
                                                width: 25,
                                                height: 25,
                                                color: secondaryColor,
                                              ),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'من فضلك أدخل سعر المنتج';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: TextFormField(
                                      controller: _quantityController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      decoration: InputDecoration(
                                        labelText: 'كمية المنتج',
                                        labelStyle: const TextStyle(
                                            color: primaryColor),
                                        fillColor: Colors.white,
                                        hintText: 'أدخل كمية المنتج',
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: primaryColor, width: 2.0),
                                        ),
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Image.asset(
                                            'assets/images/boxes.png',
                                            width: 25,
                                            height: 25,
                                            color: secondaryColor,
                                          ),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        suffixIcon: DropdownButton<String>(
                                          style: const TextStyle(
                                              color: secondaryColor),
                                          value: _selectedQuantity,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _selectedQuantity = newValue!;
                                            });
                                          },
                                          items: <String>[
                                            'كيلو',
                                            'لتر',
                                            'كيس',
                                            'كرتونة',
                                            'علبة',
                                            'زجاجة'
                                          ].map<DropdownMenuItem<String>>(
                                              (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'من فضلك أدخل كمية المنتج';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: secondaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                      ),
                                      onPressed: () async {
                                        final String name =
                                            _nameController.text;
                                        final double? price = double.tryParse(
                                            _priceController.text);
                                        final double? quantity =
                                            double.tryParse(
                                                _quantityController.text);
                                        if (price != null) {
                                          await _items.add({
                                            "اسم المنتج": name,
                                            "سعر المنتج": price,
                                            "كمية المنتج": quantity,
                                            "وحدة المنتج": _selectedQuantity,
                                            'تاريخ الإضافة': DateTime.now(),
                                            'تمت الإضافة بواسطة':
                                                _auth.currentUser!.email,
                                          });

                                          _nameController.text = '';
                                          _priceController.text = '';
                                          _quantityController.text = '';
                                          _selectedQuantity = 'كيلو';
                                          // ignore: use_build_context_synchronously
                                          Navigator.of(context).pop();
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(15.0),
                                        decoration: BoxDecoration(
                                          color: secondaryColor,
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'أضافة المنتج',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ]),
                              )))),
                ));
          });
        });
  }


  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _nameController.text = documentSnapshot['اسم المنتج'];
      _priceController.text = documentSnapshot['سعر المنتج'].toString();
      _quantityController.text = documentSnapshot['كمية المنتج'].toString();
      _selectedQuantity = documentSnapshot['وحدة المنتج'];
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Container(
              color: const Color(0xff757575),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0))),
                child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Scaffold(
                        body: Padding(
                            padding: const EdgeInsets.only(
                              top: 75,
                              right: 10,
                              left: 10,
                            ),
                            child: SingleChildScrollView(
                              child: Column(children: <Widget>[
                                // ignore: prefer_const_constructors
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  // ignore: prefer_const_constructors
                                  child: customText(
                                      text: 'أضافة منتج جديد',
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: AutoCompleteTextField<String>(
                                    key: _autoCompleteKey,
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      labelText: 'أسم المنتج',
                                      labelStyle:
                                          const TextStyle(color: primaryColor),
                                      fillColor: Colors.white,
                                      hintText: 'أدخل أسم المنتج',
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: primaryColor, width: 2.0),
                                      ),
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Image.asset(
                                          'assets/images/commodity.png',
                                          width: 25,
                                          height: 25,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                    ),
                                    suggestions: suggestions,
                                    itemSubmitted: (String suggestion) {
                                      setState(() {
                                        _nameController.text = suggestion;
                                      });
                                    },
                                    textChanged: (String value) {
                                      setState(() {});
                                    },
                                    itemBuilder: (BuildContext context,
                                        String suggestion) {
                                      return ListTile(
                                        title: Text(suggestion),
                                      );
                                    },
                                    itemSorter: (String a, String b) {
                                      return a.compareTo(b);
                                    },
                                    itemFilter:
                                        (String suggestion, String query) {
                                      return suggestion
                                          .toLowerCase()
                                          .contains(query.toLowerCase());
                                    },
                                    clearOnSubmit: false,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        controller: _priceController,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        decoration: InputDecoration(
                                          labelText: 'سعر المنتج',
                                          labelStyle: const TextStyle(
                                              color: primaryColor),
                                          fillColor: Colors.white,
                                          hintText: 'أدخل سعر المنتج',
                                          focusedBorder:
                                              const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: primaryColor,
                                                width: 2.0),
                                          ),
                                          prefixIcon: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Image.asset(
                                              'assets/images/coin.png',
                                              width: 25,
                                              height: 25,
                                            ),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: TextFormField(
                                    controller: _quantityController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: InputDecoration(
                                      labelText: 'كمية المنتج',
                                      labelStyle:
                                          const TextStyle(color: primaryColor),
                                      fillColor: Colors.white,
                                      hintText: 'أدخل كمية المنتج',
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: primaryColor, width: 2.0),
                                      ),
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Image.asset(
                                          'assets/images/boxes.png',
                                          width: 25,
                                          height: 25,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      suffixIcon: DropdownButton<String>(
                                        value: _selectedQuantity,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            _selectedQuantity = newValue!;
                                          });
                                        },
                                        items: <String>[
                                          'كيلو',
                                          'لتر',
                                          'كيس',
                                          'كرتونة',
                                          'علبة',
                                          'زجاجة'
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                    ),
                                    onPressed: () async {
                                      final String name = _nameController.text;
                                      final double? price = double.tryParse(
                                          _priceController.text);
                                      final double? quantity = double.tryParse(
                                          _quantityController.text);
                                      if (price != null) {
                                        await _items
                                            .doc(documentSnapshot!.id)
                                            .update({
                                          "اسم المنتج": name,
                                          "سعر المنتج": price,
                                          "كمية المنتج": quantity,
                                          "وحدة المنتج": _selectedQuantity,
                                        });

                                        _nameController.text = '';
                                        _priceController.text = '';
                                        _quantityController.text = '';
                                        _selectedQuantity = 'كيلو';
                                        // ignore: use_build_context_synchronously
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(15.0),
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'تحديث المنتج',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ]),
                            )))),
              ));
        });
  }

  Future<void> _delete(String itemId) async {
    await _items.doc(itemId).delete();

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('تم حذف المنتج بنجاح')));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: secondaryColor,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              color: primaryColor,
              icon: Icon(
                _sortAscendingDate ? Icons.arrow_upward : Icons.arrow_downward,
                color: secondaryColor,
              ),
              onPressed: _toggleSortAscendingDate,
            ),
           
            if (_selectedSortMethod == 'سعر المنتج')
              IconButton(
                icon: Icon(
                  _sortAscendingPrice
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  color: secondaryColor,
                ),
                onPressed: _toggleSortAscendingPrice,
              ),
          ],
          title: Container(
            padding: const EdgeInsets.only(right: 16.0),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search,
                  color: secondaryColor,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'ابحث عن منتج',
                      hintStyle: TextStyle(color: primaryColor),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      _setSearchString(value);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8.0),
          ),
         
         
          child: StreamBuilder(
            stream: _items.snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
              if (streamSnapshot.hasData) {
                final filteredItems =
                    streamSnapshot.data!.docs.where((documentSnapshot) {
                  final name = documentSnapshot['اسم المنتج'] as String;
                  return name.contains(_searchString);
                }).toList();

                _sortItems(filteredItems);

                return ListView.builder(
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot =
                        filteredItems[index];
                    final timestamp =
                        documentSnapshot['تاريخ الإضافة'] as Timestamp;
                    final addDate =
                        intl.DateFormat('yyyy-MM-dd  hh:mm a', 'ar_SA')
                            .format(timestamp.toDate());
                    return GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) =>
                                ItemsDetailsScreen(documentSnapshot));
                      },
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                        ),
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(
                            documentSnapshot['اسم المنتج'],
                            style: const TextStyle(
                              fontFamily: 'Lalezar',
                              color: primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'سعر المنتج: ${documentSnapshot['سعر المنتج'].toString()}',
                                  style: const TextStyle(
                                    fontFamily: 'Lalezar',
                                    color: Colors.black54,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  )),
                              const SizedBox(
                                width: 15,
                              ),
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'كمية المنتج: ${documentSnapshot['كمية المنتج'].toString()}',
                                        style: const TextStyle(
                                          fontFamily: 'Lalezar',
                                          color: Colors.black54,
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                        )),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(documentSnapshot['وحدة المنتج'],
                                        style: const TextStyle(
                                          fontFamily: 'Lalezar',
                                          color: Colors.black54,
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                        )),
                                  ]),
                              Text('تاريخ الإضافة:$addDate',
                                  style: const TextStyle(
                                    fontFamily: 'Lalezar',
                                    color: Colors.black54,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  )),
                            ],
                          ),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                    color: Colors.green,
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _update(documentSnapshot)),
                                IconButton(
                                    color: Colors.red,
                                    icon: const Icon(Icons.delete),
                                    onPressed: () =>
                                        _delete(documentSnapshot.id)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        
        
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: secondaryColor,
          onPressed: () {
            _create();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }


}
