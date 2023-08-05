import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => const UserInfoApp(),
  ));
}

class UserInfoApp extends StatelessWidget {
  const UserInfoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'Age & BMI Calculator',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF0A0E21),
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
      ),
      debugShowCheckedModeBanner:false,
      home: const UserInfoScreen(),
      routes: {
        ResultScreen.routeName: (context) => const ResultScreen(),
      },
    );
  }
}

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key}) : super(key: key);

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();

  String gender = 'Male';
  DateTime selectedDate = DateTime.now();

  int age = 0;
  double bmi = 0.0;
  String bmiComment = '';

  void calculateAge() {
    final currentDate = DateTime.now();
    age = currentDate.year - selectedDate.year;
    if (currentDate.month < selectedDate.month ||
        (currentDate.month == selectedDate.month &&
            currentDate.day < selectedDate.day)) {
      age--;
    }
  }

  void calculateBMI() {
    double weight = double.tryParse(weightController.text) ?? 0.0;
    double height = double.tryParse(heightController.text) ?? 0.0;

    if (weight != null && height != null && height > 0) {
      bmi = weight / ((height / 100) * (height / 100));
      if (bmi < 18.5) {
        bmiComment = 'Underweight';
      } else if (bmi < 25) {
        bmiComment = 'Normal weight';
      } else if (bmi < 30) {
        bmiComment = 'Overweight';
      } else {
        bmiComment = 'Obese';
      }
    }
  }

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      calculateAge();
      calculateBMI();
      UserInformation userInfo = UserInformation(
        name: nameController.text,
        address: addressController.text,
        gender: gender,
        dateOfBirth: selectedDate,
        weight: double.tryParse(weightController.text) ?? 0.0,
        height: double.tryParse(heightController.text) ?? 0.0,
        bmi: bmi.toStringAsFixed(2),
        age: age.toDouble(),
        bmiComment: bmiComment,
      );
      Navigator.pushNamed(
        context,
        ResultScreen.routeName,
        arguments: userInfo,
      );
    }
  }

  void refreshForm() {
    setState(() {
      nameController.clear();
      addressController.clear();
      weightController.clear();
      heightController.clear();
      gender = 'Male';
      selectedDate = DateTime.now();
      age = 0;
      bmi = 0.0;
      bmiComment = '';
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Age & BMI Calculator'),
        ),

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_2_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    else if(RegExp(r'[0-9]').hasMatch(value)){
                      return 'You cannot enter numbers';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.location_city_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 35),
                const Text('Gender',
                        style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        ),
                      ),
                Column(
                  children: <Widget>[
                    Radio<String>(
                      value: 'Male',
                      groupValue: gender,
                      onChanged: (value) {
                        setState(() {
                          gender = value!;
                        });
                      },
                    ),
                    const Icon(Icons.male_rounded,size:50, color: Colors.blue,),
                    const SizedBox(width: 30),
                    const Text('Male'),
                    Radio<String>(
                      value: 'Female',
                      groupValue: gender,
                      onChanged: (value) {
                        setState(() {
                          gender = value!;
                        });
                      },
                    ),
                    const Icon(Icons.female_rounded,size:50,color: Colors.pink,),
                    const SizedBox(width: 30),
                    const Text('Female'),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('Date of Birth',
                        style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                InkWell(
                  onTap: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          selectedDate = value;
                        });
                      }
                    });
                  },
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: <Widget>[
                        const SizedBox(width: 12),
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(selectedDate),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Weight (in Kgs)',
                    prefixIcon: Icon(Icons.line_weight_rounded, size: 50),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your weight';
                    }
                    double? weight = double.tryParse(value);
                      if (weight != null && weight > 800) {
                           return 'Weight should be less than or equal to 800 kg';
                      }
                    return null;
                  },
                ),
                TextFormField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Height (in CMs)',
                    prefixIcon: Icon(Icons.height_rounded, size: 50),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your height';
                    }
                    double? height= double.tryParse(value);
                      if (height != null && height > 800) {
                           return 'Height should be less than or equal to 800 kg';
                      }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:Colors.pink
                  ),
                  child: const Text('Submit'),
                ),
                const SizedBox(height:5),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: refreshForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:Colors.pinkAccent,
                    ),
                    child: const Text('Refresh'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  static const routeName = '/result';

  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserInformation userInformation =
        ModalRoute.of(context)!.settings.arguments as UserInformation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Age & BMI Calculator'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.pinkAccent,
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              child: Text(
                userInformation.bmi,
                style:const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'BMI Comment: ${userInformation.bmiComment}',
                    style:const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                   Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    const Text(
                      'Age:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      '${userInformation.age} years',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const Text(
                      'Date of Birth:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy').format(userInformation.dateOfBirth),
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const Text(
                      'Weight:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      '${userInformation.weight} kg',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const Text(
                      'Height:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      '${userInformation.height} cm',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const Text(
                      'Name:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      userInformation.name,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const Text(
                      'Address:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      userInformation.address,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const Text(
                      'Gender:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      userInformation.gender,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ]
                ),
              ),
            ],
          ),
        ),
      ],
      ),
      ),
    );
  }
}


class UserInformation {
  final String name;
  final String address;
  final String gender;
  final DateTime dateOfBirth;
  final double weight;
  final double height;
  final String bmi;
  final double age;
  final String bmiComment;

  UserInformation({
    required this.name,
    required this.address,
    required this.gender,
    required this.dateOfBirth,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.age,
    required this.bmiComment,
  });
}
