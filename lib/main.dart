import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blog/constants/theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'constants/route_names.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  try {
    await initHiveForFlutter();
  } catch (e) {
    print('Error initializing Hive: $e');
    // Handle initialization error gracefully
    // You may choose to show a dialog to the user or log the error
    return;
  }

  final HttpLink httpLink = HttpLink("https://uat-api.vmodel.app/graphql/");

  ValueNotifier<GraphQLClient> client = ValueNotifier(GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(store: HiveStore()),
  ));

  runApp(ProviderScope(child: MyApp(client: client)));
}

class MyApp extends StatelessWidget {
  final ValueNotifier<GraphQLClient> client;

  MyApp({Key? key, required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
        client: client,
        child: CacheProvider(
            child: MaterialApp(
          theme: appTheme,
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoute.splashScreen,
          onGenerateRoute: AppRoute.generateRoute,
        )));
  }
}
