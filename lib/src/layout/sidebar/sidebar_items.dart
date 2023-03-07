import 'package:macos_ui/macos_ui.dart';
import 'package:macos_ui/src/library.dart';

const Duration _kExpand = Duration(milliseconds: 200);
const ShapeBorder _defaultShape = RoundedRectangleBorder(
  //TODO: consider changing to 4.0 or 5.0 - App Store, Notes and Mail seem to use 4.0 or 5.0
  borderRadius: BorderRadius.all(Radius.circular(5.0)),
);

/// {@template sidebarItemSize}
/// Enumerates the size specifications of [SidebarItem]s
///
/// Values were adapted from https://developer.apple.com/design/human-interface-guidelines/components/navigation-and-search/sidebars/#platform-considerations
/// and were eyeballed against apps like App Store, Notes, and Mail.
/// {@endtemplate}
enum SidebarItemSize {
  /// A small [SidebarItem]. Has a [height] of 24 and an [iconSize] of 12.
  small(24.0, 12.0),

  /// A medium [SidebarItem]. Has a [height] of 28 and an [iconSize] of 16.
  medium(29.0, 16.0),

  /// A large [SidebarItem]. Has a [height] of 32 and an [iconSize] of 20.0.
  large(36.0, 18.0);

  /// {@macro sidebarItemSize}
  const SidebarItemSize(
    this.height,
    this.iconSize,
  );

  /// The height of the [SidebarItem].
  final double height;

  /// The maximum size of the [SidebarItem]'s leading icon.
  final double iconSize;
}

/// A scrollable widget that renders [SidebarItem]s.
///
/// See also:
///
///  * [SidebarItem], the items used by this sidebar
///  * [Sidebar], a side bar used alongside [MacosScaffold]
class SidebarItems extends StatelessWidget {
  /// Creates a scrollable widget that renders [SidebarItem]s.
  const SidebarItems({
    super.key,
    required this.items,
    required this.currentIdentifier,
    required this.onChanged,
    this.itemSize = SidebarItemSize.medium,
    this.scrollController,
    this.selectedColor,
    this.unselectedColor,
    this.shape,
    this.cursor = SystemMouseCursors.basic,
    this.onReordered,
  });

  /// The [SidebarItem]s used by the sidebar. If no items are provided,
  /// the sidebar is not rendered.
  final List<SidebarItem> items;

  /// The id of the currently selected item. There must be a [SidebarItem] with a matching id in [items].
  final String currentIdentifier;

  /// Called when the current selected identifier should be changed.
  final ValueChanged<String> onChanged;

  /// The size specifications for all [items].
  ///
  /// Defaults to [SidebarItemSize.medium].
  final SidebarItemSize itemSize;

  /// The scroll controller used by this sidebar. If null, a local scroll
  /// controller is created.
  final ScrollController? scrollController;

  /// The color to paint the item when it's selected.
  ///
  /// If null, [MacosThemeData.primaryColor] is used.
  final Color? selectedColor;

  /// The color to paint the item when it's unselected.
  ///
  /// Defaults to transparent.
  final Color? unselectedColor;

  /// The [shape] property specifies the outline (border) of the
  /// decoration. The shape must not be null. It's used alongside
  /// [selectedColor].
  final ShapeBorder? shape;

  /// Specifies the kind of cursor to use for all sidebar items.
  ///
  /// Defaults to [SystemMouseCursors.basic].
  final MouseCursor? cursor;

  /// Callback that runs when a sidebar item is dragged to a new position.
  final void Function(
      String reorderedId, String droppedAt, DropAffinity affinity)? onReordered;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    assert(debugCheckSidebarIdsUnique(items));
    assert(debugCheckHasMacosTheme(context));
    final theme = MacosTheme.of(context);

    return IconTheme.merge(
      data: const IconThemeData(size: 20),
      child: _SidebarItemsConfiguration(
        selectedColor: selectedColor ?? theme.primaryColor,
        unselectedColor: unselectedColor ?? MacosColors.transparent,
        shape: shape ?? _defaultShape,
        itemSize: itemSize,
        child: ListView(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.all(10.0 - theme.visualDensity.horizontal),
          children: List.generate(items.length, (index) {
            final item = items[index];
            if (item.disclosureItems != null) {
              return MouseRegion(
                cursor: cursor!,
                child: _DisclosureSidebarItem(
                  item: item,
                  onReordered: onReordered,
                  currentIdentifier: currentIdentifier,
                  onChanged: (item) {
                    onChanged(item.identifier);
                  },
                ),
              );
            }
            return MouseRegion(
              cursor: cursor!,
              child: _SidebarItem(
                item: item,
                onReordered: onReordered,
                selected: item.identifier == currentIdentifier,
                onClick: () => onChanged(item.identifier),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _SidebarItemsConfiguration extends InheritedWidget {
  // ignore: use_super_parameters
  const _SidebarItemsConfiguration({
    Key? key,
    required super.child,
    this.selectedColor = MacosColors.transparent,
    this.unselectedColor = MacosColors.transparent,
    this.shape = _defaultShape,
    this.itemSize = SidebarItemSize.medium,
  }) : super(key: key);

  final Color selectedColor;
  final Color unselectedColor;
  final ShapeBorder shape;
  final SidebarItemSize itemSize;

  static _SidebarItemsConfiguration? _latestConfig;

  static _SidebarItemsConfiguration of(BuildContext context) {
    final currentConfig = context
        .dependOnInheritedWidgetOfExactType<_SidebarItemsConfiguration>();
    if (currentConfig != null) _latestConfig = currentConfig;
    return _latestConfig!;
  }

  @override
  bool updateShouldNotify(_SidebarItemsConfiguration oldWidget) {
    return true;
  }
}

/// A macOS style navigation-list item intended for use in a [Sidebar]
class _SidebarItem extends StatelessWidget {
  /// Builds a [_SidebarItem].
  // ignore: use_super_parameters
  const _SidebarItem({
    Key? key,
    required this.item,
    required this.onClick,
    required this.selected,
    this.onReordered,
    this.isLastDisclousureItem,
  }) : super(key: key);

  /// The widget to lay out first.
  ///
  /// Typically an [Icon]
  final SidebarItem item;

  /// Whether the item is selected or not
  final bool selected;

  /// A function to perform when the widget is clicked or tapped.
  ///
  /// Typically a [Navigator] call
  final VoidCallback? onClick;

  /// Callback that runs when a sidebar item is dragged to a new position.
  final void Function(
      String reorderedId, String droppedAt, DropAffinity affinity)? onReordered;

  /// Use to render a DropTarget below the item if it is the last on the list of
  /// disclousure items of a _DisclosureSidebarItem.
  final bool? isLastDisclousureItem;

  void _handleActionTap() async {
    onClick?.call();
  }

  Map<Type, Action<Intent>> get _actionMap => <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (ActivateIntent intent) => _handleActionTap(),
        ),
        ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
          onInvoke: (ButtonActivateIntent intent) => _handleActionTap(),
        ),
      };

  bool get hasLeading => item.leading != null;
  bool get hasTrailing => item.trailing != null;

  bool _onWillAccept(String? identifier) {
    final accepted = item.onWillAccept?.call(identifier) ?? true;
    return (identifier != item.identifier && accepted);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMacosTheme(context));
    final theme = MacosTheme.of(context);

    final selectedColor = MacosDynamicColor.resolve(
      item.selectedColor ??
          _SidebarItemsConfiguration.of(context).selectedColor,
      context,
    );
    final unselectedColor = MacosDynamicColor.resolve(
      item.unselectedColor ??
          _SidebarItemsConfiguration.of(context).unselectedColor,
      context,
    );

    final double spacing = 10.0 + theme.visualDensity.horizontal;
    final itemSize = _SidebarItemsConfiguration.of(context).itemSize;
    TextStyle? labelStyle;
    switch (itemSize) {
      case SidebarItemSize.small:
        labelStyle = theme.typography.subheadline;
        break;
      case SidebarItemSize.medium:
        labelStyle = theme.typography.body;
        break;
      case SidebarItemSize.large:
        labelStyle = theme.typography.title3;
        break;
    }

    final baseWidget = Semantics(
      label: item.semanticLabel,
      button: true,
      focusable: true,
      focused: item.focusNode?.hasFocus,
      enabled: onClick != null,
      selected: selected,
      child: GestureDetector(
        onTap: onClick,
        child: FocusableActionDetector(
          focusNode: item.focusNode,
          descendantsAreFocusable: true,
          enabled: onClick != null,
          //mouseCursor: SystemMouseCursors.basic,
          actions: _actionMap,
          child: Container(
            width: 134.0 + theme.visualDensity.horizontal,
            height: itemSize.height + theme.visualDensity.vertical,
            decoration: ShapeDecoration(
              color: selected ? selectedColor : unselectedColor,
              shape: item.shape ?? _SidebarItemsConfiguration.of(context).shape,
            ),
            padding: EdgeInsets.symmetric(
              vertical: 7 + theme.visualDensity.horizontal,
              horizontal: spacing,
            ),
            child: Row(
              children: [
                if (hasLeading)
                  Padding(
                    padding: EdgeInsets.only(right: spacing),
                    child: MacosIconTheme.merge(
                      data: MacosIconThemeData(
                        color: selected
                            ? MacosColors.white
                            : MacosColors.controlAccentColor,
                        size: itemSize.iconSize,
                      ),
                      child: item.leading!,
                    ),
                  ),
                Expanded(
                  child: DefaultTextStyle(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: labelStyle.copyWith(
                      color: selected ? textLuminance(selectedColor) : null,
                    ),
                    child: item.label,
                  ),
                ),
                if (hasTrailing)
                  DefaultTextStyle(
                    style: labelStyle.copyWith(
                      color: selected ? textLuminance(selectedColor) : null,
                    ),
                    child: item.trailing!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    Widget? draggableWidget() {
      if (onReordered == null) return null;

      final feedback = Container(
        width: 134.0 + theme.visualDensity.horizontal,
        height: itemSize.height + theme.visualDensity.vertical,
        decoration: ShapeDecoration(
          shape: item.shape ?? _SidebarItemsConfiguration.of(context).shape,
        ),
        padding: EdgeInsets.symmetric(
          vertical: 7 + theme.visualDensity.horizontal,
          horizontal: spacing,
        ),
        child: Row(
          children: [
            if (hasLeading)
              Padding(
                padding: EdgeInsets.only(right: spacing),
                child: MacosIconTheme.merge(
                  data: MacosIconThemeData(
                    color: selected
                        ? MacosColors.white
                        : MacosColors.controlAccentColor,
                    size: itemSize.iconSize,
                  ),
                  child: item.leading!,
                ),
              ),
            Expanded(
              child: DefaultTextStyle(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: labelStyle!.copyWith(
                  color: selected ? textLuminance(selectedColor) : null,
                ),
                child: item.label,
              ),
            ),
          ],
        ),
      );
      Widget dropTarget({required bool renderDivider}) {
        return Container(
            height: 8,
            color: Colors.transparent,
            child: renderDivider
                ? Center(
                    child: Container(
                        height: 2, color: MacosColors.controlAccentColor),
                  )
                : null);
      }

      final renderDragTarget = [
        SidebarItemDragBehavior.dragAndDrop,
        SidebarItemDragBehavior.dropOnly
      ].contains(item.dragBehavior);
      final renderDraggable = [
        SidebarItemDragBehavior.dragAndDrop,
        SidebarItemDragBehavior.dragOnly
      ].contains(item.dragBehavior);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (renderDragTarget)
            DragTarget<String>(
              onWillAccept: _onWillAccept,
              onAccept: (data) =>
                  onReordered!(data, item.identifier, DropAffinity.above),
              builder: (context, accepted, rejected) =>
                  dropTarget(renderDivider: accepted.isNotEmpty),
            ),
          renderDraggable
              ? Draggable<String>(
                  data: item.identifier,
                  axis: Axis.vertical,
                  feedback: feedback,
                  childWhenDragging: Opacity(opacity: 0.5, child: baseWidget),
                  child: baseWidget,
                )
              : baseWidget,
          if (isLastDisclousureItem == true && renderDragTarget)
            DragTarget<String>(
              onWillAccept: _onWillAccept,
              onAccept: (data) =>
                  onReordered!(data, item.identifier, DropAffinity.below),
              builder: (context, accepted, rejected) =>
                  dropTarget(renderDivider: accepted.isNotEmpty),
            ),
        ],
      );
    }

    final widget = draggableWidget() ?? baseWidget;
    final builder = item.builder;
    if (builder == null) return widget;
    return Builder(builder: (context) => builder(context, widget));
  }
}

class _DisclosureSidebarItem extends StatefulWidget {
  // ignore: use_super_parameters
  _DisclosureSidebarItem({
    Key? key,
    required this.item,
    required this.currentIdentifier,
    this.onChanged,
    this.onReordered,
    this.isLastDisclousureItem,
  })  : assert(item.disclosureItems != null),
        super(key: key);

  final SidebarItem item;

  final String? currentIdentifier;

  /// A function to perform when the widget is clicked or tapped.
  ///
  /// Typically a [Navigator] call
  final ValueChanged<SidebarItem>? onChanged;

  /// Callback that runs when a sidebar item is dragged to a new position.
  final void Function(
      String reorderedId, String droppedAt, DropAffinity affinity)? onReordered;

  /// Use to render a DropTarget below the item if it is the last on the list of
  /// disclousure items of a _DisclosureSidebarItem.
  final bool? isLastDisclousureItem;

  @override
  __DisclosureSidebarItemState createState() => __DisclosureSidebarItemState();
}

class __DisclosureSidebarItemState extends State<_DisclosureSidebarItem>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _halfTween =
      Tween<double>(begin: 0.0, end: 0.25);

  late AnimationController _controller;
  late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;

  bool _isExpanded = false;

  bool get hasLeading => widget.item.leading != null;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _heightFactor = _controller.drive(_easeInTween);
    _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse().then<void>((void value) {
          if (!mounted) return;
          setState(() {
            // Rebuild without widget.children.
          });
        });
      }

      PageStorage.of(context).writeState(context, _isExpanded);
    });
    // widget.onExpansionChanged?.call(_isExpanded);
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    final theme = MacosTheme.of(context);
    final double spacing = 10.0 + theme.visualDensity.horizontal;

    final itemSize = _SidebarItemsConfiguration.of(context).itemSize;
    TextStyle? labelStyle;
    switch (itemSize) {
      case SidebarItemSize.small:
        labelStyle = theme.typography.subheadline;
        break;
      case SidebarItemSize.medium:
        labelStyle = theme.typography.body;
        break;
      case SidebarItemSize.large:
        labelStyle = theme.typography.title3;
        break;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          child: _SidebarItem(
            onReordered: widget.onReordered,
            item: SidebarItem(
              identifier: widget.item.identifier,
              dragBehavior: widget.item.dragBehavior,
              onWillAccept: widget.item.onWillAccept,
              label: widget.item.label,
              leading: Row(
                children: [
                  GestureDetector(
                    onTap: _handleTap,
                    child: Container(
                      color: Colors.transparent,
                      child: RotationTransition(
                        turns: _iconTurns,
                        child: Icon(
                          CupertinoIcons.chevron_right,
                          size: 12.0,
                          color: theme.brightness == Brightness.light
                              ? MacosColors.black
                              : MacosColors.white,
                        ),
                      ),
                    ),
                  ),
                  if (hasLeading)
                    Padding(
                      padding: EdgeInsets.only(left: spacing),
                      child: MacosIconTheme.merge(
                        data: MacosIconThemeData(size: itemSize.iconSize),
                        child: widget.item.leading!,
                      ),
                    ),
                ],
              ),
              unselectedColor: MacosColors.transparent,
              focusNode: widget.item.focusNode,
              semanticLabel: widget.item.semanticLabel,
              shape: widget.item.shape,
              trailing: widget.item.trailing,
            ),
            onClick: () => widget.onChanged?.call(widget.item),
            selected: widget.item.identifier == widget.currentIdentifier,
          ),
        ),
        ClipRect(
          child: DefaultTextStyle(
            style: labelStyle,
            child: Align(
              alignment: Alignment.centerLeft,
              heightFactor: _heightFactor.value,
              child: child,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMacosTheme(context));
    final theme = MacosTheme.of(context);

    final bool closed = !_isExpanded && _controller.isDismissed;

    final Widget result = Offstage(
      offstage: closed,
      child: TickerMode(
        enabled: !closed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.item.disclosureItems!.map((item) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24.0 + theme.visualDensity.horizontal,
              ),
              child: SizedBox(
                width: double.infinity,
                child: item.disclosureItems == null
                    ? _SidebarItem(
                        item: item,
                        onReordered: widget.onReordered,
                        isLastDisclousureItem:
                            widget.item.disclosureItems!.last == item,
                        onClick: () => widget.onChanged?.call(item),
                        selected: item.identifier == widget.currentIdentifier,
                      )
                    : _DisclosureSidebarItem(
                        item: item,
                        currentIdentifier: widget.currentIdentifier,
                        onReordered: widget.onReordered,
                        isLastDisclousureItem:
                            widget.item.disclosureItems!.last == item,
                        onChanged: (item) {
                          widget.onChanged?.call(item);
                        },
                      ),
              ),
            );
          }).toList(),
        ),
      ),
    );

    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: closed ? null : result,
    );
  }
}

bool debugCheckSidebarIdsUnique(List<SidebarItem> items) {
  List<SidebarItem> expand(SidebarItem i) =>
      [i, ...?i.disclosureItems?.expand(expand)].toList();
  final itemIds = items.expand(expand).map((i) => i.identifier);
  return itemIds.length == Set.of(itemIds).length;
}

enum DropAffinity { above, below }
