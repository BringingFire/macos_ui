import 'package:example/pages/buttons_page.dart';
import 'package:example/pages/colors_page.dart';
import 'package:example/pages/dialogs_page.dart';
import 'package:example/pages/fields_page.dart';
import 'package:example/pages/indicators_page.dart';
import 'package:example/pages/selectors_page.dart';
import 'package:example/pages/tabview_page.dart';
import 'package:example/pages/toolbar_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';

import 'theme.dart';

void main() {
  runApp(const MacosUIGalleryApp());
}

class MacosUIGalleryApp extends StatelessWidget {
  const MacosUIGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppTheme(),
      builder: (context, _) {
        final appTheme = context.watch<AppTheme>();
        return MacosApp(
          title: 'macos_ui Widget Gallery',
          theme: MacosThemeData.light(),
          darkTheme: MacosThemeData.dark(),
          themeMode: appTheme.mode,
          debugShowCheckedModeBanner: false,
          home: const WidgetGallery(),
        );
      },
    );
  }
}

class WidgetGallery extends StatefulWidget {
  const WidgetGallery({super.key});

  @override
  State<WidgetGallery> createState() => _WidgetGalleryState();
}

class _WidgetGalleryState extends State<WidgetGallery> {
  double ratingValue = 0;
  double sliderValue = 0;
  bool value = false;

  String currentIdentifier = 'buttons';

  late final searchFieldController = TextEditingController();

  final Map<String, Widget> pages = {
    'buttons': CupertinoTabView(
      builder: (_) => const ButtonsPage(),
    ),
    'indicators': const IndicatorsPage(),
    'fields': const FieldsPage(),
    'colors': const ColorsPage(),
    'disclosure': const SizedBox(),
    'add': const Center(
      child: MacosIcon(
        CupertinoIcons.add,
      ),
    ),
    'dialogs': const DialogsPage(),
    'toolbar': const ToolbarPage(),
    'selectors': const SelectorsPage(),
    'tabview': const TabViewPage(),
  };

  final Map<String, bool> expandedState = {};

  bool isExpanded(String id) => expandedState[id] ?? true;
  void updateExpandedState(String id, bool isExpanded) =>
      expandedState[id] = isExpanded;

  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: const [
        PlatformMenu(
          label: 'macos_ui Widget Gallery',
          menus: [
            PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.about,
            ),
            PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.quit,
            ),
          ],
        ),
        PlatformMenu(
          label: 'View',
          menus: [
            PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.toggleFullScreen,
            ),
          ],
        ),
        PlatformMenu(
          label: 'Window',
          menus: [
            PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.minimizeWindow,
            ),
            PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.zoomWindow,
            ),
          ],
        ),
      ],
      child: MacosWindow(
        sidebar: Sidebar(
          top: MacosSearchField(
            placeholder: 'Search',
            controller: searchFieldController,
            onResultSelected: (result) {
              switch (result.searchKey) {
                case 'Buttons':
                  setState(() {
                    currentIdentifier = 'buttons';
                    searchFieldController.clear();
                  });
                  break;
                case 'Indicators':
                  setState(() {
                    currentIdentifier = 'indicators';
                    searchFieldController.clear();
                  });
                  break;
                case 'Fields':
                  setState(() {
                    currentIdentifier = 'fields';
                    searchFieldController.clear();
                  });
                  break;
                case 'Colors':
                  setState(() {
                    currentIdentifier = 'colors';
                    searchFieldController.clear();
                  });
                  break;
                case 'Dialogs and Sheets':
                  setState(() {
                    currentIdentifier = 'dialogs';
                    searchFieldController.clear();
                  });
                  break;
                case 'Toolbar':
                  setState(() {
                    currentIdentifier = 'toolbar';
                    searchFieldController.clear();
                  });
                  break;
                case 'Selectors':
                  setState(() {
                    currentIdentifier = 'selectors';
                    searchFieldController.clear();
                  });
                  break;
                default:
                  searchFieldController.clear();
              }
            },
            results: const [
              SearchResultItem('Buttons'),
              SearchResultItem('Indicators'),
              SearchResultItem('Fields'),
              SearchResultItem('Colors'),
              SearchResultItem('Dialogs and Sheets'),
              SearchResultItem('Toolbar'),
              SearchResultItem('Selectors'),
            ],
          ),
          minWidth: 200,
          builder: (context, scrollController) {
            return SidebarItems<String>(
              currentIdentifier: currentIdentifier,
              onChanged: (i) => setState(() => currentIdentifier = i),
              scrollController: scrollController,
              itemSize: SidebarItemSize.large,
              items: [
                SidebarItem(
                  identifier: 'buttons',
                  isExpanded: isExpanded('buttons'),
                  onExpanded: (expanded) =>
                      setState(() => updateExpandedState('buttons', expanded)),
                  // leading: MacosIcon(CupertinoIcons.square_on_circle),
                  leading: const MacosImageIcon(
                    AssetImage(
                      'assets/sf_symbols/button_programmable_2x.png',
                    ),
                  ),
                  label: const Text('Buttons'),
                ),
                SidebarItem(
                  identifier: 'indicators',
                  isExpanded: isExpanded('indicators'),
                  onExpanded: (expanded) => setState(
                      () => updateExpandedState('indicators', expanded)),
                  leading: const MacosImageIcon(
                    AssetImage(
                      'assets/sf_symbols/lines_measurement_horizontal_2x.png',
                    ),
                  ),
                  label: const Text('Indicators'),
                ),
                SidebarItem(
                  identifier: 'fields',
                  isExpanded: isExpanded('fields'),
                  onExpanded: (expanded) =>
                      setState(() => updateExpandedState('fields', expanded)),
                  leading: const MacosImageIcon(
                    AssetImage(
                      'assets/sf_symbols/character_cursor_ibeam_2x.png',
                    ),
                  ),
                  label: const Text('Fields'),
                ),
                SidebarItem(
                  identifier: 'disclosure',
                  isExpanded: isExpanded('disclosure'),
                  onExpanded: (expanded) => setState(
                      () => updateExpandedState('disclosure', expanded)),
                  leading: const MacosIcon(CupertinoIcons.folder),
                  label: const Text('Disclosure'),
                  trailing: Text(
                    '',
                    style: TextStyle(
                      color: MacosTheme.brightnessOf(context) == Brightness.dark
                          ? MacosColors.tertiaryLabelColor.darkColor
                          : MacosColors.tertiaryLabelColor,
                    ),
                  ),
                  disclosureItems: [
                    SidebarItem(
                      identifier: 'colors',
                      isExpanded: isExpanded('colors'),
                      onExpanded: (expanded) => setState(
                          () => updateExpandedState('colors', expanded)),
                      leading: const MacosImageIcon(
                        AssetImage(
                          'assets/sf_symbols/rectangle_3_group_2x.png',
                        ),
                      ),
                      label: const Text('Colors'),
                    ),
                    SidebarItem(
                      identifier: 'add',
                      isExpanded: isExpanded('add'),
                      onExpanded: (expanded) =>
                          setState(() => updateExpandedState('add', expanded)),
                      leading: const MacosIcon(CupertinoIcons.infinite),
                      label: const Text('Item 3'),
                    ),
                  ],
                ),
                SidebarItem(
                  identifier: 'dialogs',
                  isExpanded: isExpanded('dialogs'),
                  onExpanded: (expanded) =>
                      setState(() => updateExpandedState('dialogs', expanded)),
                  leading: const MacosIcon(CupertinoIcons.square_on_square),
                  label: const Text('Dialogs & Sheets'),
                ),
                SidebarItem(
                  identifier: 'toolbar',
                  isExpanded: isExpanded('toolbar'),
                  onExpanded: (expanded) =>
                      setState(() => updateExpandedState('toolbar', expanded)),
                  leading: const MacosIcon(CupertinoIcons.macwindow),
                  label: const Text('Toolbar'),
                ),
                SidebarItem(
                  identifier: 'selectors',
                  isExpanded: isExpanded('selectors'),
                  onExpanded: (expanded) => setState(
                      () => updateExpandedState('selectors', expanded)),
                  leading: const MacosImageIcon(
                    AssetImage(
                      'assets/sf_symbols/filemenu_and_selection_2x.png',
                    ),
                  ),
                  label: const Text('Selectors'),
                ),
                SidebarItem(
                  identifier: 'tabview',
                  isExpanded: isExpanded('tabview'),
                  onExpanded: (expanded) =>
                      setState(() => updateExpandedState('tabview', expanded)),
                  leading: const MacosIcon(CupertinoIcons.uiwindow_split_2x1),
                  label: const Text('TabView'),
                ),
              ],
            );
          },
          bottom: const MacosListTile(
            leading: MacosIcon(CupertinoIcons.profile_circled),
            title: Text('Tim Apple'),
            subtitle: Text('tim@apple.com'),
          ),
        ),
        endSidebar: Sidebar(
          startWidth: 200,
          minWidth: 200,
          maxWidth: 300,
          shownByDefault: false,
          builder: (context, _) {
            return const Center(
              child: Text('End Sidebar'),
            );
          },
        ),
        child: pages[currentIdentifier],
      ),
    );
  }
}
