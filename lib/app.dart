import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class DataF1App extends StatefulWidget {
  const DataF1App({super.key});

  @override
  State<DataF1App> createState() => _DataF1AppState();
}

class _DataF1AppState extends State<DataF1App> {
  final _authBloc = AuthBloc();

  @override
  void initState() {
    super.initState();
    _authBloc.add(AppStarted());
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: MaterialApp.router(
        title: 'DataF1',
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
