// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:medTalk/screens/record_screen.dart';
import 'package:medTalk/screens/speech_to_text_screen.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import 'profile_screen.dart';
import '../components.dart';
import '../constants.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
    required this.useLightMode,
    required this.useMaterial3,
    required this.colorSelected,
    required this.handleBrightnessChange,
    required this.handleMaterialVersionChange,
    required this.handleColorSelect,
    required this.handleImageSelect,
    required this.colorSelectionMethod,
    required this.imageSelected,
  });

  final bool useLightMode;
  final bool useMaterial3;
  final ColorSeed colorSelected;
  final ColorImageProvider imageSelected;
  final ColorSelectionMethod colorSelectionMethod;

  final void Function(bool useLightMode) handleBrightnessChange;
  final void Function() handleMaterialVersionChange;
  final void Function(int value) handleColorSelect;
  final void Function(int value) handleImageSelect;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late final AnimationController controller;
  late final CurvedAnimation railAnimation;
  bool controllerInitialized = false;
  bool showMediumSizeLayout = false;
  bool showLargeSizeLayout = false;

  int screenIndex = ScreenSelected.speechToText.value;

  @override
  initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: transitionLength.toInt() * 2),
      value: 0,
      vsync: this,
    );
    railAnimation = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.5, 1.0),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final double width = MediaQuery.of(context).size.width;
    final AnimationStatus status = controller.status;
    if (width > mediumWidthBreakpoint) {
      if (width > largeWidthBreakpoint) {
        showMediumSizeLayout = false;
        showLargeSizeLayout = true;
      } else {
        showMediumSizeLayout = true;
        showLargeSizeLayout = false;
      }
      if (status != AnimationStatus.forward &&
          status != AnimationStatus.completed) {
        controller.forward();
      }
    } else {
      showMediumSizeLayout = false;
      showLargeSizeLayout = false;
      if (status != AnimationStatus.reverse &&
          status != AnimationStatus.dismissed) {
        controller.reverse();
      }
    }
    if (!controllerInitialized) {
      controllerInitialized = true;
      controller.value = width > mediumWidthBreakpoint ? 1 : 0;
    }
  }

  void handleScreenChanged(int screenSelected) {
    setState(() {
      screenIndex = screenSelected;
    });
  }

  Widget createScreenFor(
      ScreenSelected screenSelected, bool showNavBarExample) {
    switch (screenSelected) {
      case ScreenSelected.speechToText:
        return const SpeechToTextScreen();
      case ScreenSelected.profile:
        return const ProfileScreen();
      case ScreenSelected.records:
        return const RecordsScreen();
    }
  }

  PreferredSizeWidget createAppBar() {
    return AppBar(
      title: Text('MedTalk'),

      actions: !showMediumSizeLayout && !showLargeSizeLayout
          ? [
              _BrightnessButton(
                handleBrightnessChange: widget.handleBrightnessChange,
                showLabels: false,
              ),
              _ColorSeedButton(
                handleColorSelect: widget.handleColorSelect,
                colorSelected: widget.colorSelected,
                colorSelectionMethod: widget.colorSelectionMethod,
                showLabels: false,
              ),
              _FontSizeButton(
                showLabels: false,
              ),
              // _ColorImageButton(
              //   handleImageSelect: widget.handleImageSelect,
              //   imageSelected: widget.imageSelected,
              //   colorSelectionMethod: widget.colorSelectionMethod,
              // )
            ]
          : [Container()],
    );
  }

  Widget _trailingActions() => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: _BrightnessButton(
              handleBrightnessChange: widget.handleBrightnessChange,
              showTooltipBelow: false,
              showLabels: true,
            ),
          ),
          Flexible(
            child: _ColorSeedButton(
              handleColorSelect: widget.handleColorSelect,
              colorSelected: widget.colorSelected,
              colorSelectionMethod: widget.colorSelectionMethod,
              showLabels: true,
            ),
          ),
          Flexible(
            child: _FontSizeButton(
              showLabels: true,
            ),
          ),
          // Flexible(
          //   child: _ColorImageButton(
          //     handleImageSelect: widget.handleImageSelect,
          //     imageSelected: widget.imageSelected,
          //     colorSelectionMethod: widget.colorSelectionMethod,
          //   ),
          // ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return NavigationTransition(
          scaffoldKey: scaffoldKey,
          animationController: controller,
          railAnimation: railAnimation,
          appBar: createAppBar(),
          body: createScreenFor(
              ScreenSelected.values[screenIndex], controller.value == 1),
          navigationRail: NavigationRail(
            extended: showLargeSizeLayout,
            destinations: navRailDestinations,
            selectedIndex: screenIndex,
            onDestinationSelected: (index) {
              setState(() {
                screenIndex = index;
                handleScreenChanged(screenIndex);
              });
            },
            trailing: Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: showLargeSizeLayout
                    ? _ExpandedTrailingActions(
                        useLightMode: widget.useLightMode,
                        handleBrightnessChange: widget.handleBrightnessChange,
                        useMaterial3: widget.useMaterial3,
                        handleMaterialVersionChange:
                            widget.handleMaterialVersionChange,
                        handleImageSelect: widget.handleImageSelect,
                        handleColorSelect: widget.handleColorSelect,
                        colorSelectionMethod: widget.colorSelectionMethod,
                        imageSelected: widget.imageSelected,
                        colorSelected: widget.colorSelected,
                      )
                    : _trailingActions(),
              ),
            ),
          ),
          navigationBar: NavigationBars(
            onSelectItem: (index) {
              setState(() {
                screenIndex = index;
                handleScreenChanged(screenIndex);
              });
            },
            selectedIndex: screenIndex,
            isExampleBar: false,
          ),
        );
      },
    );
  }
}

class _BrightnessButton extends StatelessWidget {
  const _BrightnessButton({
    required this.handleBrightnessChange,
    this.showTooltipBelow = true,
    required this.showLabels
  });

  final Function handleBrightnessChange;
  final bool showTooltipBelow;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final isBright = Theme.of(context).brightness == Brightness.light;
    return Tooltip(
      preferBelow: showTooltipBelow,
      message: 'Toggle brightness',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: IconButton(
              icon: isBright
                  ? const Icon(Icons.dark_mode_outlined)
                  : const Icon(Icons.light_mode_outlined),
              onPressed: () => handleBrightnessChange(!isBright),
            ),
          ),
          Visibility(
            visible: showLabels,
              child: Flexible(
                  child: Text("Helligkeit")
              )
          )
        ],
      ),
    );
  }
}


class _ColorSeedButton extends StatelessWidget {
  const _ColorSeedButton({
    required this.handleColorSelect,
    required this.colorSelected,
    required this.colorSelectionMethod,
    required this.showLabels
  });

  final void Function(int) handleColorSelect;
  final ColorSeed colorSelected;
  final ColorSelectionMethod colorSelectionMethod;
  final bool showLabels;


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: PopupMenuButton(
            icon: Icon(
              Icons.palette_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Select a seed color',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            itemBuilder: (context) {
              return List.generate(ColorSeed.values.length, (index) {
                ColorSeed currentColor = ColorSeed.values[index];

                return PopupMenuItem(
                  value: index,
                  enabled: currentColor != colorSelected ||
                      colorSelectionMethod != ColorSelectionMethod.colorSeed,
                  child: Wrap(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Icon(
                          currentColor == colorSelected &&
                                  colorSelectionMethod != ColorSelectionMethod.image
                              ? Icons.color_lens
                              : Icons.color_lens_outlined,
                          color: currentColor.color,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(currentColor.label),
                      ),
                    ],
                  ),
                );
              });
            },
            onSelected: handleColorSelect,
          ),
        ),
        Visibility(
            visible: showLabels,
            child: Flexible(
                child: Text("Farbe")
            )
        )
      ],
    );
  }
}

class _FontSizeButton extends StatefulWidget {
  const _FontSizeButton({
    required this.showLabels
  });
  final bool showLabels;

  @override
  State<_FontSizeButton> createState() => _FontSizeButtonState(showLabels);

}

class _FontSizeButtonState extends State<_FontSizeButton> {

  _FontSizeButtonState(this.showLabels);

  final bool showLabels;
  double _sliderValue = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: PopupMenuButton(
            icon: Icon(
              Icons.text_increase,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Select a seed color',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            itemBuilder: (context){
              return [
                PopupMenuItem(
                    child: Column(
                      children: [
                        Text("Schriftgröße"),
                        StatefulBuilder(
                          builder: (context, state){
                            return SfSlider.vertical(
                              min: 0,
                              max: 2,
                              interval: 1,
                              stepSize: 1,
                              showLabels: true,
                              showDividers: true,
                              value: _sliderValue,
                              labelFormatterCallback:
                                  (dynamic actualValue, String formattedText) {
                                switch (actualValue) {
                                  case 0:
                                    return 'Klein';
                                  case 1:
                                    return 'Mittel';
                                  case 2:
                                    return 'Groß';
                                }
                                return actualValue.toString();
                              },
                              onChanged: (value) {
                                state((){

                                });
                                setState(() {
                                  _sliderValue = value;
                                });
                              },
                            );
                          },
                        )
                      ],
                    ))
              ];
            }
          ),
        ),
        Visibility(
            visible: showLabels,
            child: Flexible(
                child: Text("Schrift")
            )
        )
      ],
    );
  }
}


// class _ColorImageButton extends StatelessWidget {
//   const _ColorImageButton({
//     required this.handleImageSelect,
//     required this.imageSelected,
//     required this.colorSelectionMethod,
//   });
//
//   final void Function(int) handleImageSelect;
//   final ColorImageProvider imageSelected;
//   final ColorSelectionMethod colorSelectionMethod;
//
//   @override
//   Widget build(BuildContext context) {
//     return PopupMenuButton(
//       icon: Icon(
//         Icons.image_outlined,
//         color: Theme.of(context).colorScheme.onSurfaceVariant,
//       ),
//       tooltip: 'Select a color extraction image',
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       itemBuilder: (context) {
//         return List.generate(ColorImageProvider.values.length, (index) {
//           ColorImageProvider currentImageProvider =
//               ColorImageProvider.values[index];
//
//           return PopupMenuItem(
//             value: index,
//             enabled: currentImageProvider != imageSelected ||
//                 colorSelectionMethod != ColorSelectionMethod.image,
//             child: Wrap(
//               crossAxisAlignment: WrapCrossAlignment.center,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(left: 10),
//                   child: ConstrainedBox(
//                     constraints: const BoxConstraints(maxWidth: 48),
//                     child: Padding(
//                       padding: const EdgeInsets.all(4.0),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(8.0),
//                         child: Image(
//                           image: NetworkImage(
//                               ColorImageProvider.values[index].url),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 20),
//                   child: Text(currentImageProvider.label),
//                 ),
//               ],
//             ),
//           );
//         });
//       },
//       onSelected: handleImageSelect,
//     );
//   }
// }

class _ExpandedTrailingActions extends StatefulWidget {
  const _ExpandedTrailingActions({
    required this.useLightMode,
    required this.handleBrightnessChange,
    required this.useMaterial3,
    required this.handleMaterialVersionChange,
    required this.handleColorSelect,
    required this.handleImageSelect,
    required this.imageSelected,
    required this.colorSelected,
    required this.colorSelectionMethod,
  });

  final void Function(bool) handleBrightnessChange;
  final void Function() handleMaterialVersionChange;
  final void Function(int) handleImageSelect;
  final void Function(int) handleColorSelect;

  final bool useLightMode;
  final bool useMaterial3;

  final ColorImageProvider imageSelected;
  final ColorSeed colorSelected;
  final ColorSelectionMethod colorSelectionMethod;

  @override
  State<_ExpandedTrailingActions> createState() => _ExpandedTrailingActionsState();
}

class _ExpandedTrailingActionsState extends State<_ExpandedTrailingActions> {
  double _sliderValue = 1;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final trailingActionsBody = Container(
      constraints: const BoxConstraints.tightFor(width: 250),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('Helligkeit'),
              Expanded(child: Container()),
              Switch(
                  value: widget.useLightMode,
                  onChanged: (value) {
                    widget.handleBrightnessChange(value);
                  })
            ],
          ),
          Row(
            children: [
              widget.useMaterial3
                  ? const Text('Material 3')
                  : const Text('Material 2'),
              Expanded(child: Container()),
              Switch(
                  value: widget.useMaterial3,
                  onChanged: (_) {
                    widget.handleMaterialVersionChange();
                  })
            ],
          ),
          const Divider(),
          const Text('Farbe'),
          _ExpandedColorSeedAction(
            handleColorSelect: widget.handleColorSelect,
            colorSelected: widget.colorSelected,
            colorSelectionMethod: widget.colorSelectionMethod,
          ),
          const Divider(),
          const Text('Schriftgröße'),
          StatefulBuilder(
            builder: (context, state){
              return SfSlider(
              min: 0,
              max: 2,
              interval: 1,
              stepSize: 1,
              showLabels: true,
              showDividers: true,
              value: _sliderValue,
              labelFormatterCallback:
                (dynamic actualValue, String formattedText) {
                  switch (actualValue) {
                    case 0:
                      return 'Klein';
                    case 1:
                      return 'Mittel';
                    case 2:
                      return 'Groß';
                  }
                return actualValue.toString();
              },
              onChanged: (value) {
                state((){

                });
                setState(() {
                _sliderValue = value;
                });
              },
            );
          })
          // const Divider(),
          // _ExpandedImageColorAction(
          //   handleImageSelect: handleImageSelect,
          //   imageSelected: imageSelected,
          //   colorSelectionMethod: colorSelectionMethod,
          // ),
        ],
      ),
    );
    return screenHeight > 740
        ? trailingActionsBody
        : SingleChildScrollView(child: trailingActionsBody);
  }
}

class _ExpandedColorSeedAction extends StatelessWidget {
  const _ExpandedColorSeedAction({
    required this.handleColorSelect,
    required this.colorSelected,
    required this.colorSelectionMethod,
  });

  final void Function(int) handleColorSelect;
  final ColorSeed colorSelected;
  final ColorSelectionMethod colorSelectionMethod;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 200.0),
      child: GridView.count(
        crossAxisCount: 3,
        children: List.generate(
          ColorSeed.values.length,
          (i) => IconButton(
            icon: const Icon(Icons.radio_button_unchecked),
            color: ColorSeed.values[i].color,
            isSelected: colorSelected.color == ColorSeed.values[i].color &&
                colorSelectionMethod == ColorSelectionMethod.colorSeed,
            selectedIcon: const Icon(Icons.circle),
            onPressed: () {
              handleColorSelect(i);
            },
          ),
        ),
      ),
    );
  }
}

// class _ExpandedImageColorAction extends StatelessWidget {
//   const _ExpandedImageColorAction({
//     required this.handleImageSelect,
//     required this.imageSelected,
//     required this.colorSelectionMethod,
//   });
//
//   final void Function(int) handleImageSelect;
//   final ColorImageProvider imageSelected;
//   final ColorSelectionMethod colorSelectionMethod;
//
//   @override
//   Widget build(BuildContext context) {
//     return ConstrainedBox(
//       constraints: const BoxConstraints(maxHeight: 150.0),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: GridView.count(
//           crossAxisCount: 3,
//           children: List.generate(
//             ColorImageProvider.values.length,
//             (i) => InkWell(
//               borderRadius: BorderRadius.circular(4.0),
//               onTap: () => handleImageSelect(i),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Material(
//                   borderRadius: BorderRadius.circular(4.0),
//                   elevation: imageSelected == ColorImageProvider.values[i] &&
//                           colorSelectionMethod == ColorSelectionMethod.image
//                       ? 3
//                       : 0,
//                   child: Padding(
//                     padding: const EdgeInsets.all(4.0),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(4.0),
//                       child: Image(
//                         image: NetworkImage(ColorImageProvider.values[i].url),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class NavigationTransition extends StatefulWidget {
  const NavigationTransition(
      {super.key,
      required this.scaffoldKey,
      required this.animationController,
      required this.railAnimation,
      required this.navigationRail,
      required this.navigationBar,
      required this.appBar,
      required this.body});

  final GlobalKey<ScaffoldState> scaffoldKey;
  final AnimationController animationController;
  final CurvedAnimation railAnimation;
  final Widget navigationRail;
  final Widget navigationBar;
  final PreferredSizeWidget appBar;
  final Widget body;

  @override
  State<NavigationTransition> createState() => _NavigationTransitionState();
}

class _NavigationTransitionState extends State<NavigationTransition> {
  late final AnimationController controller;
  late final CurvedAnimation railAnimation;
  late final ReverseAnimation barAnimation;
  bool controllerInitialized = false;
  bool showDivider = false;

  @override
  void initState() {
    super.initState();

    controller = widget.animationController;
    railAnimation = widget.railAnimation;

    barAnimation = ReverseAnimation(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      key: widget.scaffoldKey,
      appBar: widget.appBar,
      body: Row(
        children: <Widget>[
          RailTransition(
            animation: railAnimation,
            backgroundColor: colorScheme.surface,
            child: widget.navigationRail,
          ),
          widget.body,
        ],
      ),
      bottomNavigationBar: BarTransition(
        animation: barAnimation,
        backgroundColor: colorScheme.surface,
        child: widget.navigationBar,
      ),
      // endDrawer: const NavigationDrawerSection(),
    );
  }
}

final List<NavigationRailDestination> navRailDestinations = appBarDestinations
    .map(
      (destination) => NavigationRailDestination(
        icon: Tooltip(
          message: destination.label,
          child: destination.icon,
        ),
        selectedIcon: Tooltip(
          message: destination.label,
          child: destination.selectedIcon,
        ),
        label: Text(destination.label),
      ),
    )
    .toList();

class SizeAnimation extends CurvedAnimation {
  SizeAnimation(Animation<double> parent)
      : super(
          parent: parent,
          curve: const Interval(
            0.2,
            0.8,
            curve: Curves.easeInOutCubicEmphasized,
          ),
          reverseCurve: Interval(
            0,
            0.2,
            curve: Curves.easeInOutCubicEmphasized.flipped,
          ),
        );
}

class OffsetAnimation extends CurvedAnimation {
  OffsetAnimation(Animation<double> parent)
      : super(
          parent: parent,
          curve: const Interval(
            0.4,
            1.0,
            curve: Curves.easeInOutCubicEmphasized,
          ),
          reverseCurve: Interval(
            0,
            0.2,
            curve: Curves.easeInOutCubicEmphasized.flipped,
          ),
        );
}

class RailTransition extends StatefulWidget {
  const RailTransition(
      {super.key,
      required this.animation,
      required this.backgroundColor,
      required this.child});

  final Animation<double> animation;
  final Widget child;
  final Color backgroundColor;

  @override
  State<RailTransition> createState() => _RailTransition();
}

class _RailTransition extends State<RailTransition> {
  late Animation<Offset> offsetAnimation;
  late Animation<double> widthAnimation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // The animations are only rebuilt by this method when the text
    // direction changes because this widget only depends on Directionality.
    final bool ltr = Directionality.of(context) == TextDirection.ltr;

    widthAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(SizeAnimation(widget.animation));

    offsetAnimation = Tween<Offset>(
      begin: ltr ? const Offset(-1, 0) : const Offset(1, 0),
      end: Offset.zero,
    ).animate(OffsetAnimation(widget.animation));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: DecoratedBox(
        decoration: BoxDecoration(color: widget.backgroundColor),
        child: Align(
          alignment: Alignment.topLeft,
          widthFactor: widthAnimation.value,
          child: FractionalTranslation(
            translation: offsetAnimation.value,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class BarTransition extends StatefulWidget {
  const BarTransition(
      {super.key,
      required this.animation,
      required this.backgroundColor,
      required this.child});

  final Animation<double> animation;
  final Color backgroundColor;
  final Widget child;

  @override
  State<BarTransition> createState() => _BarTransition();
}

class _BarTransition extends State<BarTransition> {
  late final Animation<Offset> offsetAnimation;
  late final Animation<double> heightAnimation;

  @override
  void initState() {
    super.initState();

    offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(OffsetAnimation(widget.animation));

    heightAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(SizeAnimation(widget.animation));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: DecoratedBox(
        decoration: BoxDecoration(color: widget.backgroundColor),
        child: Align(
          alignment: Alignment.topLeft,
          heightFactor: heightAnimation.value,
          child: FractionalTranslation(
            translation: offsetAnimation.value,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class OneTwoTransition extends StatefulWidget {
  const OneTwoTransition({
    super.key,
    required this.animation,
    required this.one,
    required this.two,
  });

  final Animation<double> animation;
  final Widget one;
  final Widget two;

  @override
  State<OneTwoTransition> createState() => _OneTwoTransitionState();
}

class _OneTwoTransitionState extends State<OneTwoTransition> {
  late final Animation<Offset> offsetAnimation;
  late final Animation<double> widthAnimation;

  @override
  void initState() {
    super.initState();

    offsetAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(OffsetAnimation(widget.animation));

    widthAnimation = Tween<double>(
      begin: 0,
      end: mediumWidthBreakpoint,
    ).animate(SizeAnimation(widget.animation));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Flexible(
          flex: mediumWidthBreakpoint.toInt(),
          child: widget.one,
        ),
        if (widthAnimation.value.toInt() > 0) ...[
          Flexible(
            flex: widthAnimation.value.toInt(),
            child: FractionalTranslation(
              translation: offsetAnimation.value,
              child: widget.two,
            ),
          )
        ],
      ],
    );
  }
}
