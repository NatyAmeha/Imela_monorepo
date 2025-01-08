import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

enum AppModalSheetType { DIALOG, SIDESHEET, BOTTOMSHEET }

class ModalContent {
  final String? id;
  final Widget title;
  final Widget content;
  final Map<Widget, Function(BuildContext modalContext)>? actions;
  final Widget? leading;
  final Widget? trailing;
  ModalContent({this.id, required this.title, required this.content, this.actions, this.leading, this.trailing});
}

String? currentPageId;

class AppModalSheet {
  static BuildContext? modalContext;
  static Future<T> showModal<T>(BuildContext context, {required AppModalSheetType type, required List<ModalContent> pages, bool dimissable = true, Function(BuildContext modalContext)? onClose}) async {
    var modalPages = pages.mapIndexed(
      (index, page) {
        return SliverWoltModalSheetPage(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          hasSabGradient: false,
          isTopBarLayerAlwaysVisible: true,
          surfaceTintColor: Colors.transparent,
          useSafeArea: true,
          resizeToAvoidBottomInset: true,
          hasTopBarLayer: false,
          navBarHeight: 40,
          topBarTitle: page.title,
          leadingNavBarWidget: page.leading ??
              (index > 0
                  ? CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.grey,
                      child: InkWell(
                        onTap: () {
                          WoltModalSheet.of(context).showPrevious();
                        },
                        child: page.trailing ?? const Icon(Icons.close),
                      )).withPaddingAll(8)
                  : null),
          trailingNavBarWidget: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.grey,
              child: InkWell(
                onTap: () {
                  if (onClose == null) {
                    AppModalSheet.closeModal();
                  } else {
                    onClose.call(modalContext!);
                  }
                },
                child: page.trailing ?? const Icon(Icons.close),
              )).withPaddingAll(8),
          mainContentSliversBuilder: (context) {
            return [SliverToBoxAdapter(child: page.content)];
          },
          stickyActionBar: page.actions?.isNotEmpty == true
              ? Wrap(
                  children: page.actions!.entries.map((entry) {
                    return InkWell(
                      onTap: () {
                        entry.value(modalContext!);
                      },
                      child: entry.key,
                    );
                  }).toList(),
                )
              : null,
        );
      },
    );
    return await WoltModalSheet.show(
      context: context,
      barrierDismissible: dimissable,
      useSafeArea: false,
      modalTypeBuilder: (context) {
        if (Responsive.isSmallScreen(context)) {
          return WoltModalType.bottomSheet();
        } else if (type == AppModalSheetType.SIDESHEET) {
          return WoltModalType.sideSheet();
        } else {
          return WoltModalType.dialog();
        }
      },
      pageListBuilder: (modContext) {
        modalContext = modContext;
        return modalPages.toList();
      },
    );
  }

  static void nextPage(BuildContext context) {
    if (modalContext != null) {
      WoltModalSheet.of(modalContext!).showNext();
    }
  }

  static void previousPage({BuildContext? context, String? pageIdtoremove}) {
    if (modalContext != null) {
      print('previous page to remove ${pageIdtoremove}');
      if (pageIdtoremove != null) {
        WoltModalSheet.of(context ?? modalContext!).removePage(pageIdtoremove);
      } else {
        WoltModalSheet.of(context ?? modalContext!).showPrevious();
      }
    }
  }

  static void addPageToModal(BuildContext context, ModalContent page) {
    try {
      currentPageId = page.id;
      WoltModalSheet.of(context).addPage(
        SliverWoltModalSheetPage(
          id: page.id,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          hasSabGradient: false,
          isTopBarLayerAlwaysVisible: true,
          surfaceTintColor: Colors.transparent,
          useSafeArea: true,
          resizeToAvoidBottomInset: true,
          hasTopBarLayer: false,
          navBarHeight: 40,
          topBarTitle: page.title,
          leadingNavBarWidget: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey,
            child: InkWell(
              onTap: () {
                print('previous page ${currentPageId}');
                AppModalSheet.previousPage(pageIdtoremove: currentPageId);
              },
              child: page.trailing ?? const Icon(Icons.arrow_back),
            ),
          ).withPaddingAll(8),
          trailingNavBarWidget: page.trailing ??
              CircleAvatar(
                radius: 15,
                backgroundColor: Colors.grey,
                child: InkWell(
                  onTap: () {
                    AppModalSheet.closeModal();
                  },
                  child: page.trailing ?? const Icon(Icons.close),
                ),
              ).withPaddingAll(8),
          mainContentSliversBuilder: (context) {
            return [SliverToBoxAdapter(child: page.content)];
          },
        ),
      );
      WoltModalSheet.of(context).showNext();
    } catch (e) {
      print('Error adding page to modal: ${e.toString()}');
    }
  }

  static closeModal<T>({BuildContext? context, T? result}) {
    try {
      if (modalContext != null) {
        Navigator.of(context ?? modalContext!).pop(result);
      }
    } catch (e) {
      print('Error closing modal: ${e.toString()}');
    }
  }
}
