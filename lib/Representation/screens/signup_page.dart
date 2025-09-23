import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_bloc.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_event.dart';
import 'package:sonique/Representation/Bloc/auth_bloc/auth_state.dart';
import 'package:sonique/Representation/widgets/CustomButton.dart';
import 'package:sonique/Representation/widgets/CustomTextFormField.dart';
import 'package:sonique/core/services/routes/routes.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool obscure1 = true;
  bool obscure2 = true;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
            body: BlocListener<AuthBloc,AuthState>(listener: (context,state){
              if(state is AuthSuccessState){
                context.go(Routes.home);
              }

              if(state is AuthErrorState){
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ));
              }
            },
            child: BlocBuilder<AuthBloc,AuthState>(builder: (contex,state){
              return  SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                      ),
                    ),
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () {
                            context.pop();
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            "Create an account",
                            style: Theme.of(context).textTheme.displayMedium!
                                .copyWith(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: CustomTextFormField(
                                  label: "First Name",
                                  hintText: "First Name",
                                  controller: _firstNameController,
                                  prefixIcon: Icon(Icons.person),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your first name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: CustomTextFormField(
                                  label: "Last Name",
                                  hintText: "Last Name",
                                  controller: _lastNameController,
                                  prefixIcon: Icon(Icons.person),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your first name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          CustomTextFormField(
                            label: "Email",
                            hintText: "Enter your email",
                            prefixIcon: Icon(Icons.email),
                            controller: _emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(
                                r'^[^@]+@[^@]+\.[^@]+',
                              ).hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          CustomTextFormField(
                            label: "Username",
                            hintText: "Enter your username",
                            controller: _usernameController,
                            prefixIcon: Icon(Icons.person),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          CustomTextFormField(
                            label: "Password",
                            hintText: "Enter your password",
                            controller: _passwordController,
                            obscureText: obscure1,
                            prefixIcon: Icon(Icons.lock),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters long';
                              }
                              return null;
                            },
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  obscure1 = !obscure1;
                                });
                              },
                              child:
                                  obscure1
                                      ? Icon(Icons.visibility_off)
                                      : Icon(Icons.visibility),
                            ),
                          ),
                          SizedBox(height: 20),
                          CustomTextFormField(
                            label: "Confirm Password",
                            hintText: "Confirm your password",
                            controller: _confirmPasswordController,
                            obscureText: obscure2,
                            prefixIcon: Icon(Icons.lock),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  obscure2 = !obscure2;
                                });
                              },
                              child:
                                  obscure2
                                      ? Icon(Icons.visibility_off)
                                      : Icon(Icons.visibility),
                            ),
                          ),
                          SizedBox(height: 20),
                          CustomElevatedButton(
                            child:
                                state is AuthLoadingState
                                    ? SpinKitWave(
                                      color: Colors.white,
                                      size: 20.0,
                                    )
                                    : Text(
                                      "Sign Up",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(
                                  RegisterEvent(
                                    email: _emailController.text,
                                    firstName: _firstNameController.text,
                                    lastName: _lastNameController.text,
                                    password: _passwordController.text,
                                    username: _usernameController.text,
                                  ),
                                  
                                  
                                );
                              }
                            },
                          ),
                          SizedBox(height: 10),
                          Divider(),
                          GestureDetector(
                            onTap: () {
                              context.push('/login');
                            },
                            child: Text(
                              "Already have an account? Login",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
            }),
            )
          
      ),
    );
  }
}
