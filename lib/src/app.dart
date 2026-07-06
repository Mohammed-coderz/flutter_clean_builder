import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/generator/presentation/generator_cubit.dart';
import 'features/generator/presentation/generator_screen.dart';

class CleanBuilderApp extends StatelessWidget {
  const CleanBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GeneratorCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Clean Builder',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2563EB),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF7F9FC),
          useMaterial3: true,
        ),
        home: const GeneratorScreen(),
      ),
    );
  }
}
