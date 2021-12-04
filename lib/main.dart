import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import 'place.dart';
import 'search_model.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
    ),
  );

  runApp(
    MaterialApp(
      title: 'Material Floating Search Bar Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        iconTheme: const IconThemeData(
          color: Color(0xFF4d4d4d),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),
      ),
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: ChangeNotifierProvider(
          create: (_) => SearchModel(),
          child: const Home(),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final controller = FloatingSearchBarController();

  int _index = 0;
  int get index => _index;
  set index(int value) {
    _index = min(value, 2);
    _index == 2 ? controller.hide() : controller.show();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: Drawer(
        child: Container(
          width: 200,
        ),
      ),
      body: buildSearchBar(),
    );
  }

  Widget buildSearchBar() {
    final actions = [
      FloatingSearchBarAction(
        showIfOpened: false,
        child: CircularButton(
          icon: const Icon(Icons.place),
          onPressed: () {},
        ),
      ),
      FloatingSearchBarAction.searchToClear(
        showIfClosed: false,
      ),
    ];

    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Consumer<SearchModel>(
      builder: (context, model, _) => FloatingSearchBar(
        automaticallyImplyBackButton: false,
        controller: controller,
        clearQueryOnClose: true,
        hint: 'Buscar...',
        iconColor: Colors.grey,
        transitionDuration: const Duration(milliseconds: 800),
        transitionCurve: Curves.easeInOutCubic,
        physics: const BouncingScrollPhysics(),
        axisAlignment: isPortrait ? 0.0 : -1.0,
        openAxisAlignment: 0.0,
        actions: actions,
        progress: model.isLoading,
        debounceDelay: const Duration(milliseconds: 500),
        onQueryChanged: model.onQueryChanged,
        scrollPadding: EdgeInsets.zero,
        transition: CircularFloatingSearchBarTransition(spacing: 16),
        builder: (context, _) => buildExpandableBody(model),
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Column(
      children: [
        Expanded(
          child: IndexedStack(
            index: min(index, 2),
            children: const [
              Map(),
              SomeScrollableContent(),
              FloatingSearchAppBarExample(),
            ],
          ),
        ),
        buildBottomNavigationBar(),
      ],
    );
  }

  Widget buildExpandableBody(SearchModel model) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: ImplicitlyAnimatedList<Place>(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          items: model.suggestions,
          insertDuration: const Duration(milliseconds: 700),
          itemBuilder: (context, animation, item, i) {
            return SizeFadeTransition(
              animation: animation,
              child: buildItem(context, item),
            );
          },
          updateItemBuilder: (context, animation, item) {
            return FadeTransition(
              opacity: animation,
              child: buildItem(context, item),
            );
          },
          areItemsTheSame: (a, b) => a == b,
        ),
      ),
    );
  }

  Widget buildItem(BuildContext context, Place place) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final model = Provider.of<SearchModel>(context, listen: false);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            FloatingSearchBar.of(context).close();
            Future.delayed(
              const Duration(milliseconds: 500),
              () => model.clear(),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: model.suggestions == history
                        ? const Icon(Icons.history, key: Key('history'))
                        : const Icon(Icons.place, key: Key('place')),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: textTheme.subtitle1,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        place.level2Address,
                        style: textTheme.bodyText2
                            .copyWith(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (model.suggestions.isNotEmpty && place != model.suggestions.last)
          const Divider(height: 0),
      ],
    );
  }

  Widget buildBottomNavigationBar() {
    return BottomNavigationBar(
      onTap: (value) => index = value,
      currentIndex: index,
      elevation: 20,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.blue,
      selectedFontSize: 12.5,
      unselectedFontSize: 12.5,
      unselectedItemColor: const Color(0xFF4d4d4d),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.map),
          label: 'Mis Fincas',
        ),
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.leaf),
          label: 'Mis Cultivos',
        ),
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.homeVariantOutline),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.cartOutline),
          label: 'Tienda',
        ),
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.cog),
          label: 'Ajustes',
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

//MIS FINCAS #1
class Map extends StatelessWidget {
  const Map({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        buildMap(),
        buildFabs(),
      ],
    );
  }

  Widget buildFabs() {
    return Align(
      alignment: AlignmentDirectional.bottomEnd,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 16, end: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.white,
              child: const Icon(Icons.gps_fixed, color: Color(0xFF4d4d4d)),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.blue,
              child: const Icon(Icons.directions),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMap() {
    return Image.asset(
      'assets/map.jpg',
      fit: BoxFit.cover,
    );
  }
}

class SomeScrollableContent extends StatelessWidget {
  const SomeScrollableContent({Key key}) : super(key: key);
  //MIS CULTIVOS
  @override
  Widget build(BuildContext context) {
    return FloatingSearchBarScrollNotifier(
      child: ListView.separated(
        padding: const EdgeInsets.only(top: kToolbarHeight),
        itemCount: 100,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Item $index'),
          );
        },
      ),
    );
  }
}

class FloatingSearchAppBarExample extends StatelessWidget {
  const FloatingSearchAppBarExample({Key key}) : super(key: key);
  //INICIO
  @override
  Widget build(BuildContext context) {
    return Stack(
      //fit: StackFit.expand,
      children: [
        Inicio(),
        buildFotosB(),
      ],
    );
  }

  Widget Inicio() {
    return FloatingSearchAppBar(
        title: const Text('Bienvenido a Bioline!'),
        transitionDuration: const Duration(milliseconds: 800),
        color: Colors.greenAccent.shade100,
        colorOnScroll: Colors.greenAccent.shade200,
        body: Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/arandanos_main_menu.jpg"),
                  fit: BoxFit.cover)),
        ));
  }

  Widget buildFotosB() {
    return Align(
      alignment: AlignmentDirectional.bottomEnd,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 16, end: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.white,
              child: const Icon(Icons.camera_alt_outlined,
                  color: Color(0xFF4d4d4d)),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.blue,
              child: const Icon(Icons.photo),
            ),
          ],
        ),
      ),
    );
  }
}
