import 'package:flutter/foundation.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:macos_ui/src/library.dart';

/// A macOS style navigation-list item intended for use in a [Sidebar]
///
/// See also:
///
///  * [Sidebar], a side bar used alongside [MacosScaffold]
///  * [SidebarItems], the widget that displays [SidebarItem]s vertically
class SidebarItem with Diagnosticable {
  /// Creates a sidebar item.
  const SidebarItem({
    this.leading,
    required this.label,
    required this.identifier,
    this.selectedColor,
    this.unselectedColor,
    this.shape,
    this.focusNode,
    this.semanticLabel,
    this.disclosureItems,
    this.trailing,
    this.builder,
    this.onWillAccept,
    this.dragBehavior = SidebarItemDragBehavior.dragAndDrop,
  });

  /// A builder that will be used to wrap the sidebar item widget if provided.
  final Function(BuildContext, Widget)? builder;

  /// Arbitrary identifier for this sidebar item. Must be unique among all
  /// sidebar items, including nested disclosure items.
  final String identifier;

  /// The widget before [label].
  ///
  /// Typically an [Icon]
  final Widget? leading;

  /// Indicates what content this widget represents.
  ///
  /// Typically a [Text]
  final Widget label;

  /// The color to paint this widget as when selected.
  ///
  /// If null, [MacosThemeData.primaryColor] is used.
  final Color? selectedColor;

  /// The color to paint this widget as when unselected.
  ///
  /// Defaults to transparent.
  final Color? unselectedColor;

  /// The [shape] property specifies the outline (border) of the
  /// decoration. The shape must not be null. It's used alonside
  /// [selectedColor].
  final ShapeBorder? shape;

  /// The focus node used by this item.
  final FocusNode? focusNode;

  /// The semantic label used by screen readers.
  final String? semanticLabel;

  /// The disclosure items. If null, there will be no disclosure items.
  ///
  /// If non-null and [leading] is null, a local animated icon is created
  final List<SidebarItem>? disclosureItems;

  /// An optional trailing widget.
  ///
  /// Typically a text indicator of a count of items, like in this
  /// screenshots from the Apple Notes app:
  /// {@image <img src="https://imgur.com/REpW9f9.png" height="88" width="219" />}
  final Widget? trailing;

  /// Defines if the sidebar item will accept incoming dragged sidebar items and if
  /// itself will be draggable, defaults to SidebarItemDragBehavior.dragAndDrop.
  final SidebarItemDragBehavior dragBehavior;

  /// Callback to accept reorder change.
  final bool Function(String? identifier, DropAffinity dropAffinity)? onWillAccept;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('selectedColor', selectedColor));
    properties.add(ColorProperty('unselectedColor', unselectedColor));
    properties.add(StringProperty('semanticLabel', semanticLabel));
    properties.add(DiagnosticsProperty<ShapeBorder>('shape', shape));
    properties.add(DiagnosticsProperty<FocusNode>('focusNode', focusNode));
    properties.add(IterableProperty<SidebarItem>(
      'disclosure items',
      disclosureItems,
    ));
    properties.add(DiagnosticsProperty<Widget?>('trailing', trailing));
    properties.add(DiagnosticsProperty<SidebarItemDragBehavior>('dragBehavior', dragBehavior));
  }
}

enum SidebarItemDragBehavior { dragAndDrop, dragOnly, dropOnly, none }
