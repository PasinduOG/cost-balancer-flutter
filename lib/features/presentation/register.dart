import 'package:cost_balancer_app/services/api_service.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _familyDataController = TextEditingController();

  bool isCreatingNewFamily = true;
  bool _isLoading = false; // ලෝඩින් පෙන්නන්න

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _familyDataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 30,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[800],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'COST BALANCER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Register to Cost Balancer',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // 2. Controllers ටික TextFields වලට පාස් කරනවා
                    _buildTextField(
                      'USERNAME',
                      controller: _usernameController,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      'FULL NAME',
                      controller: _fullNameController,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField('EMAIL', controller: _emailController),
                    const SizedBox(height: 10),
                    _buildTextField(
                      'PASSWORD',
                      isPassword: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.shade800),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text(
                              'Create a New Family?',
                              style: TextStyle(fontSize: 14),
                            ),
                            activeThumbColor: Colors.green[800],
                            value: isCreatingNewFamily,
                            onChanged: (bool value) {
                              setState(() {
                                isCreatingNewFamily = value;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          isCreatingNewFamily
                              ? _buildTextField(
                                  'FAMILY NAME (e.g. Perera Wallet)',
                                  controller: _familyDataController,
                                )
                              : _buildTextField(
                                  'JOIN FAMILY ID (e.g. 1)',
                                  controller: _familyDataController,
                                ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        // 3. Register Button ලොජික් එක
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() => _isLoading = true);

                                String username = _usernameController.text;
                                String fullName = _fullNameController.text;
                                String email = _emailController.text;
                                String password = _passwordController.text;
                                String familyOrJoinId =
                                    _familyDataController.text;

                                bool success = await ApiService.register(
                                  username: username,
                                  fullName: fullName,
                                  email: email,
                                  password: password,
                                  isCreatingNewFamily: isCreatingNewFamily,
                                  familyName: isCreatingNewFamily
                                      ? familyOrJoinId
                                      : null,
                                  joinFamilyId: !isCreatingNewFamily
                                      ? int.tryParse(familyOrJoinId)
                                      : null,
                                );

                                setState(() => _isLoading = false);

                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Registration Successful! Please Login.',
                                      ),
                                    ),
                                  );
                                  Navigator.pop(context); // ආපහු Login එකට
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Registration Failed. Try again.',
                                      ),
                                    ),
                                  );
                                }
                              },
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Register',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 30,
                  ),
                ),
                child: const Text(
                  'Already have an account? Login here',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 4. Helper method එක Update කළා Controller එක භාරගන්න
  Widget _buildTextField(
    String hint, {
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
