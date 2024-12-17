import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/l10n/l10n.dart';
import 'package:imela_pos/ui/authentication/workspace_auth/workspace_auth_viewmodel.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class WorkspaceAuth extends StatefulWidget {
  static const routeName = '/workspace-auth';
  const WorkspaceAuth({super.key});

  static void navigate(BuildContext context, {bool replace = false}) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName, replace: replace);
  }

  @override
  State<WorkspaceAuth> createState() => _WorkspaceAuthState();
}

class _WorkspaceAuthState extends State<WorkspaceAuth> {
  final viewmodel = WorkspaceAuthViewmodel.getInstance();
  late WidgetFactory widgetFactory;

  @override
  void initState() {
    super.initState();
    viewmodel.initViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    widgetFactory = AppViewmodel.getWidgetFactory(context);
    final isSmallscreen = Responsive.isSmallScreen(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.homeTitle),
      ),
      body: isSmallscreen ? _buildSmallScreenLayout() : _buildLargeScreenLayout(),
    );
  }

  Widget _buildLargeScreenLayout() {
    return Row(
      children: [
        // Description Column (Left)
        Expanded(
          child: widgetFactory.createCard(
            height: double.infinity,
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.all(16.0),
            child: _buildDescription(),
          ),
        ),
        const SizedBox(width: 16),
        // Input Column (Right)
        Expanded(
          child: _buildInputColumn(),
        ),
      ],
    );
  }

  Widget _buildSmallScreenLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Description Column (Top)
          widgetFactory.createCard(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.zero,
            padding: const EdgeInsets.all(16.0),
            child: _buildDescription(),
          ),
          const SizedBox(height: 16),
          // Input Column (Bottom)
          _buildInputColumn(),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: context.isPhone ? 50 : 150),
        widgetFactory.createText(context, 'IMela POS', style: Theme.of(context).textTheme.displayMedium, color: Colors.white),
        const SizedBox(height: 24),
        widgetFactory.createText(
          context,
          'Please provide details for the workspace. The workspace input will be used to manage resources.',
          style: Theme.of(context).textTheme.titleMedium,
          color: Colors.white,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInputColumn() {
    return widgetFactory.createCard(
      // Remove the fixed width
      padding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            widgetFactory.createTextField(
              controller: viewmodel.workspaceInputController,
              onChanged: viewmodel.onWorkspaceInputChanged,
              hintText: 'Workspace Name',
            ),
            const SizedBox(height: 32),
            Obx(
              () => widgetFactory.createButton(
                context: context,
                content: const Text('Submit'),
                isLoading: viewmodel.isLoading.value,
                onPressed: () {
                  viewmodel.checkBusinessWorkspace(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
