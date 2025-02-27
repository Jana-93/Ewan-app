import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'userpage.dart';

class EditChild extends StatefulWidget {
  final String childId;

  const EditChild({Key? key, required this.childId}) : super(key: key);

  @override
  _EditChildState createState() => _EditChildState();
}

class _EditChildState extends State<EditChild> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _childNameController = TextEditingController();
  final TextEditingController _childStatusController = TextEditingController();

  String? _selectedAge;
  final List<String> _ages = List.generate(
    7,
    (index) => (index + 5).toString(),
  );

  @override
  void initState() {
    super.initState();
    _loadChildData();
  }

  Future<void> _loadChildData() async {
    try {
      DocumentSnapshot childDoc =
          await FirebaseFirestore.instance
              .collection("children")
              .doc(widget.childId)
              .get();

      if (childDoc.exists) {
        setState(() {
          _childNameController.text = childDoc['childName'] ?? '';
          _selectedAge = childDoc['childAge'] ?? '';
          _childStatusController.text = childDoc['childStatus'] ?? '';
        });
      } else {
        throw Exception("الطفل غير موجود");
      }
    } catch (e) {
      print("Error loading child data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "حدث خطأ أثناء تحميل بيانات الطفل",
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _updateChildData() async {
    try {
      if (_formKey.currentState!.validate()) {
        await FirebaseFirestore.instance
            .collection("children")
            .doc(widget.childId)
            .update({
              "childName": _childNameController.text.trim(),
              "childAge": _selectedAge,
              "childStatus": _childStatusController.text.trim(),
            });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "تم تحديث بيانات الطفل بنجاح",
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserPage()),
        );
      }
    } catch (e) {
      print("Error updating child data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "حدث خطأ أثناء تحديث بيانات الطفل",
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  colors: const [
                    Color.fromARGB(255, 219, 101, 37),
                    Color.fromRGBO(239, 108, 0, 1),
                    Color.fromRGBO(255, 167, 38, 1),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  const SizedBox(height: 70),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 10),
                        const Text(
                          "تعديل بيانات الطفل",
                          style: TextStyle(color: Colors.white, fontSize: 30),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            const Icon(
                              Icons.account_circle_outlined,
                              size: 100,
                              color: Color.fromARGB(255, 248, 141, 1),
                            ),
                            const SizedBox(height: 5),
                            _buildInputField(
                              "اسم الطفل",
                              controller: _childNameController,
                            ),
                            const SizedBox(height: 20),
                            _buildAgeDropdown(), // Dropdown for child's age
                            const SizedBox(height: 20),
                            _buildInputField(
                              "حالة الطفل",
                              controller: _childStatusController,
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    255,
                                    145,
                                    1,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: _updateChildData,
                                child: const Text(
                                  "حفظ التعديلات",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_circle_right_outlined,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => UserPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, {TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(color: Colors.black, fontSize: 16)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(225, 95, 27, .3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال $label';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAgeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          "عمر الطفل",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(225, 95, 27, .3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedAge,
            items:
                _ages.map((String age) {
                  return DropdownMenuItem<String>(
                    value: age,
                    child: Text(age, textAlign: TextAlign.right),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedAge = newValue; // Update selected age
              });
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء اختيار عمر الطفل';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
