import 'package:flutter/material.dart';
import 'package:nina_remote/views/equipment/camera.dart';
import 'package:nina_remote/util.dart';
import 'package:nina_remote/views/equipment/telescope.dart';

class EquipmentView extends StatefulWidget {
  const EquipmentView({super.key});

  @override
  State<EquipmentView> createState() => _EquipmentViewState();
}

class _EquipmentViewState extends State<EquipmentView> with TickerProviderStateMixin {

  late final List<Widget> equipmentViews;

  late PageController pageController;
  late TabController tabController;
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();

    equipmentViews = [
      const CameraView(),
      const TelescopeView(),
    ];

    pageController = PageController();
    tabController = TabController(length: equipmentViews.length, vsync: this);
    // TODO: init EquipmentViews
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView(
          controller: pageController,
          onPageChanged: _handlePageChanged,
          children: equipmentViews,
        ),
        PageIndicator(
          tabController: tabController,
          currentPageIndex: currentPageIndex,
          onUpdateCurrentPageIndex: _updateCurrentPageIndex,
          isOnDesktopAndWeb: isOnDesktopAndWeb,
        ),
      ],
    );
  }

  void _handlePageChanged(int newIndex) {
    if (!isOnDesktopAndWeb) {
      return;
    }
    tabController.index = newIndex;
    setState(() {
      currentPageIndex = newIndex;
    });
  }

  void _updateCurrentPageIndex(int index) {
    tabController.index = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.tabController,
    required this.currentPageIndex,
    required this.onUpdateCurrentPageIndex,
    required this.isOnDesktopAndWeb,
  });

  final int currentPageIndex;
  final TabController tabController;
  final void Function(int) onUpdateCurrentPageIndex;
  final bool isOnDesktopAndWeb;

  @override
  Widget build(BuildContext context) {
    if (!isOnDesktopAndWeb) {
      return const SizedBox.shrink();
    }
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            splashRadius: 16.0,
            padding: EdgeInsets.zero,
            onPressed: () {
              if (currentPageIndex == 0) {
                return;
              }
              onUpdateCurrentPageIndex(currentPageIndex - 1);
            },
            icon: const Icon(
              Icons.arrow_left_rounded,
              size: 32.0,
            ),
          ),
          TabPageSelector(
            controller: tabController,
            color: colorScheme.surface,
            selectedColor: colorScheme.primary,
          ),
          IconButton(
            splashRadius: 16.0,
            padding: EdgeInsets.zero,
            onPressed: () {
              if (currentPageIndex == tabController.length - 1) {
                return;
              }
              onUpdateCurrentPageIndex(currentPageIndex + 1);
            },
            icon: const Icon(
              Icons.arrow_right_rounded,
              size: 32.0,
            ),
          ),
        ],
      ),
    );
  }
}
