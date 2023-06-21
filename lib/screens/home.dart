// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:medTalk/dialogs/terms_dialog.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:medTalk/providers/language_provider.dart';
import 'package:medTalk/screens/calender_screen.dart';
import 'package:medTalk/screens/record_screen.dart';
import 'package:medTalk/screens/speech_to_text_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:provider/provider.dart';
import 'package:medTalk/providers/font_provider.dart';
import 'dart:ui';


import '../dialogs/policy_dialog.dart';
import 'profile_screen.dart';
import '../components.dart';
import '../constants.dart';
import 'package:syncfusion_flutter_core/theme.dart';

import 'package:animations/animations.dart';
import 'package:flutter/gestures.dart';

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
  final LocalAuthentication auth = LocalAuthentication();

  @override
  initState() {
    super.initState();
    _printStoredPreference();
    _checkBiometricAuth();
    controller = AnimationController(
      duration: Duration(milliseconds: transitionLength.toInt() * 2),
      value: 0,
      vsync: this,
    );
    railAnimation = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.5, 1.0),
    );

    _landingDialogCheck();
  }

  Future<void> _landingDialogCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? termsPreference = prefs.getBool('termsPreference');
    bool? policyPreference = prefs.getBool('policyPreference');

    if (termsPreference == false || termsPreference == null) {
      _landingTermsPage();
    } else if (policyPreference == false || policyPreference == null) {
      _landingPolicyPage();
    }
  }

  void _landingTermsPage() async {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return TermsDialog(
            mdFileName: 'terms_and_conditions.md',
          );
        },
      );

      RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: "By creating your profile, you are agreeing to our\n",
          style: Theme.of(context).textTheme.bodyText1,
          children: [
            TextSpan(
              text: "Terms & Conditions ",
              style: TextStyle(fontWeight: FontWeight.bold),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  showModal(
                    context: context,
                    configuration: FadeScaleTransitionConfiguration(),
                    builder: (context) {
                      return TermsDialog(
                        mdFileName: 'terms_and_conditions.md',
                      );
                    },
                  );
                },
            ),
          ],
        ),
      );
    });
  }

  void _landingPolicyPage() async {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return PolicyDialog(
            mdFileName: 'privacy_policy.md',
          );
        },
      );

      RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: "By creating your profile, you are agreeing to our\n",
          style: Theme.of(context).textTheme.bodyText1,
          children: [
            TextSpan(
              text: "Privacy Policy",
              style: TextStyle(fontWeight: FontWeight.bold),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  showModal(
                    context: context,
                    configuration: FadeScaleTransitionConfiguration(),
                    builder: (context) {
                      return PolicyDialog(
                        mdFileName: 'privacy_policy.md',
                      );
                    },
                  );
                },
            ),
          ],
        ),
      );
    });

  }
  Future<void> _printStoredPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isBiometricAuth = prefs.getBool('biometricAuth');

    if (isBiometricAuth == null) {
      print("No stored preference found");
    } else if (isBiometricAuth) {
      print("Stored preference: User accepted biometric authentication");
    } else {
      print("Stored preference: User rejected biometric authentication");
    }
  }
  void _checkBiometricAuth() async {
    bool canCheckBiometrics;

    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } catch (e) {
      print("Error checking biometrics: $e");
      canCheckBiometrics = false;
    }
    if(canCheckBiometrics){
      print("Device supports biometric authentication");
      WidgetsBinding.instance?.addPostFrameCallback((_) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool? isBiometricAuth = prefs.getBool('biometricAuth');
        if (isBiometricAuth == true) {
          bool authenticated = await _authenticate();
          if (!authenticated) {
            SystemNavigator.pop(animated: false);
          }
        } else {
          _showBiometricDialog();
        }
      });
    } else {
      print("Device doesn't support biometric authentication");
    }
  }
  Future<bool> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      print("Error authenticating: $e");
    }
    return authenticated;
  }


  void _showBiometricDialog(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Biometrische Authentifizierung'),
          content: const Text('Möchten Sie in dieser App die biometrische Authentifizierung verwenden?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Ablehnen'),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                print("User rejected biometric authentication");
                prefs.setBool('biometricAuth', false);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Akzeptieren'),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                print("User accepted biometric authentication");
                prefs.setBool('biometricAuth', true);
                Navigator.of(context).pop();
                bool authenticated = await _authenticate();
                if (!authenticated) {
                  SystemNavigator.pop(animated: false);
                }
              },
            ),
          ],
        );
      },
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
      case ScreenSelected.calender:
        return const CalenderScreen();
    }
  }

  PreferredSizeWidget createAppBar() {
    return AppBar(
      title: Text('MedTalk - Smart City Bamberg'),
      actions: !showMediumSizeLayout && !showLargeSizeLayout
          ? [
              _LanguageButton(
                showLabels: false,
              ),
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
            ]
          : [Container()],
    );
  }

  Widget _trailingActions() => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: _LanguageButton(
              showLabels: true,
            ),
          ),
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
        ],
      );

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
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
            destinations: navRailDestinations(languageProvider),
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

class _BrightnessButton extends StatefulWidget {
  const _BrightnessButton(
      {required this.handleBrightnessChange,
      this.showTooltipBelow = true,
      required this.showLabels});

  final Function handleBrightnessChange;
  final bool showTooltipBelow;
  final bool showLabels;

  @override
  State<_BrightnessButton> createState() => _BrightnessButtonState();
}

class _BrightnessButtonState extends State<_BrightnessButton> {
  @override
  Widget build(BuildContext context) {
    Map<String, String> language =
        context.watch<LanguageProvider>().languageMap;
    final isBright = Theme.of(context).brightness == Brightness.light;
    return Tooltip(
      preferBelow: widget.showTooltipBelow,
      message: language['brightness_tooltip'],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: IconButton(
              icon: isBright
                  ? const Icon(Icons.dark_mode_outlined)
                  : const Icon(Icons.light_mode_outlined),
              onPressed: () {
                widget.handleBrightnessChange(!isBright);
            }
            ),
          ),
          Visibility(
              visible: widget.showLabels,
              child: Flexible(child: Text(language['brightness']!)))
        ],
      ),
    );
  }
}

class _ColorSeedButton extends StatelessWidget {
  const _ColorSeedButton(
      {required this.handleColorSelect,
      required this.colorSelected,
      required this.colorSelectionMethod,
      required this.showLabels});

  final void Function(int) handleColorSelect;
  final ColorSeed colorSelected;
  final ColorSelectionMethod colorSelectionMethod;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    Map<String, String> language =
        context.watch<LanguageProvider>().languageMap;
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
            tooltip: language['color_tooltip'],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                                  colorSelectionMethod !=
                                      ColorSelectionMethod.image
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
            child: Flexible(child: Text(language['color']!)))
      ],
    );
  }
}

class _LanguageButton extends StatefulWidget {
  const _LanguageButton({required this.showLabels});

  final bool showLabels;

  @override
  State<_LanguageButton> createState() => _LanguageButtonState();
}

class _LanguageButtonState extends State<_LanguageButton> {
  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    Map<String, String> language = languageProvider.languageMap;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: PopupMenuButton(
            icon: Icon(
              Icons.language,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            tooltip: language['language_tooltip'],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            itemBuilder: (context) {
              return List.generate(languageProvider.languageList.length,
                  (index) {
                return PopupMenuItem(
                  value: languageProvider.languageList[index],
                  child: Wrap(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(languageProvider.languageList[index]),
                      ),
                    ],
                  ),
                );
              });
            },
            onSelected: (value) {
              setState(() {
                context.read<LanguageProvider>().change_language(value);
              });
            },
          ),
        ),
        Visibility(
            visible: widget.showLabels,
            child: Flexible(child: Text(language['language_label']!)))
      ],
    );
  }
}

class _FontSizeButton extends StatefulWidget {
  const _FontSizeButton({required this.showLabels});
  final bool showLabels;

  @override
  State<_FontSizeButton> createState() => _FontSizeButtonState(showLabels);
}

class _FontSizeButtonState extends State<_FontSizeButton> {
  _FontSizeButtonState(this.showLabels);

  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    Map<String, String> language =
        context.watch<LanguageProvider>().languageMap;
    final ThemeData theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: PopupMenuButton(
              icon: Icon(
                Icons.format_size,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              tooltip: language['font_tooltip'],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                      child: Column(
                    children: [
                      Text(language['font_size']!),
                      StatefulBuilder(
                        builder: (context, state) {
                          return SfSliderTheme(
                            data: SfSliderThemeData(
                              activeLabelStyle: theme.textTheme.bodySmall,
                              inactiveLabelStyle: theme.textTheme.bodySmall,
                            ),
                            child: SfSlider.vertical(
                              min: 0,
                              max: 2,
                              interval: 1,
                              stepSize: 1,
                              showLabels: true,
                              showDividers: true,
                              value: context.read<FontProvider>().font_size,
                              labelFormatterCallback:
                                  (dynamic actualValue, String formattedText) {
                                switch (actualValue) {
                                  case 0:
                                    return language['font_small']!;
                                  case 1:
                                    return language['font_medium']!;
                                  case 2:
                                    return language['font_large']!;
                                }
                                return actualValue.toString();
                              },
                              onChanged: (value) {
                                context
                                    .read<FontProvider>()
                                    .change_font_size(value);
                                state(() {});
                                setState(() {});
                              },
                            ),
                          );
                        },
                      )
                    ],
                  ))
                ];
              }),
        ),
        Visibility(
            visible: showLabels,
            child: Flexible(child: Text(language['font']!)))
      ],
    );
  }
}

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
  State<_ExpandedTrailingActions> createState() =>
      _ExpandedTrailingActionsState();
}

class _ExpandedTrailingActionsState extends State<_ExpandedTrailingActions> {
  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    Map<String, String> language = languageProvider.languageMap;
    final ThemeData theme = Theme.of(context);
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
              Text(language['brightness']!),
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
              Text(language['language']!),
              Expanded(child: Container()),
              Switch(
                  value: languageProvider.language,
                  onChanged: (value) {
                    languageProvider
                        .change_language(value ? 'German' : 'English');
                  })
            ],
          ),
          const Divider(),
          Text(language['color']!),
          _ExpandedColorSeedAction(
            handleColorSelect: widget.handleColorSelect,
            colorSelected: widget.colorSelected,
            colorSelectionMethod: widget.colorSelectionMethod,
          ),
          const Divider(),
          Text(language['font_size']!),
          StatefulBuilder(builder: (context, state) {
            return SfSliderTheme(
              data: SfSliderThemeData(
                activeLabelStyle: theme.textTheme.bodyMedium,
                inactiveLabelStyle: theme.textTheme.bodyMedium,
              ),
              child: SfSlider(
                min: 0,
                max: 2,
                interval: 1,
                stepSize: 1,
                showLabels: true,
                showDividers: true,
                value: context.read<FontProvider>().font_size,
                labelFormatterCallback:
                    (dynamic actualValue, String formattedText) {
                  switch (actualValue) {
                    case 0:
                      return language['font_small']!;
                    case 1:
                      return language['font_medium']!;
                    case 2:
                      return language['font_large']!;
                  }
                  return actualValue.toString();
                },
                onChanged: (value) {
                  context.read<FontProvider>().change_font_size(value);
                  state(() {});
                  setState(() {});
                },
              ),
            );
          })
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

List<NavigationRailDestination> navRailDestinations(
    LanguageProvider languageProvider) {
  return appBarDestinations
      .map((destination) => NavigationRailDestination(
            icon: Tooltip(
              message: languageProvider.languageMap[destination.label]!,
              child: destination.icon,
            ),
            selectedIcon: Tooltip(
              message: languageProvider.languageMap[destination.label]!,
              child: destination.selectedIcon,
            ),
            label: Text(languageProvider.languageMap[destination.label]!),
          ))
      .toList();
}

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
