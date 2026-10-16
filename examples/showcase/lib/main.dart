import 'package:fframe/fframe.dart';
import 'package:fframe_wpf/fframe_wpf.dart';
import 'package:fframe_window/fframe_window.dart';

Future<void> main() async {
  if (FDesktopWindowBootstrap.isSupportedPlatform) {
    await FDesktopWindowBootstrap.run(
      frameless: false,
      mainWindow: const FWindowSpec(
        id: 'main',
        title: 'FFrame Database Studio',
        route: '/',
        size: FSize(1280, 800),
        minimumSize: FSize(900, 600),
      ),
      appBuilder: (manager, currentWindow) => FFrameExampleApp(
        windowManager: manager,
        currentWindow: currentWindow,
      ),
    );
    return;
  }
  runFFrameApp(const FFrameExampleApp());
}

/// Interactive WPF-style database studio used as the package example.
class FFrameExampleApp extends FStatefulWidget {
  /// Creates the example app.
  const FFrameExampleApp({super.key, this.windowManager, this.currentWindow});

  final FWindowManager? windowManager;
  final FWindowSpec? currentWindow;

  @override
  FState<FFrameExampleApp> createState() => _FFrameExampleAppState();
}

class _FFrameExampleAppState extends FState<FFrameExampleApp> {
  bool _isDark = false;
  bool _isCompact = false;

  @override
  FWidget build(FBuildContext context) {
    final brightness = _isDark ? FBrightness.dark : FBrightness.light;
    final designSystem = FWpfDesignSystem(brightness: brightness);
    return FFrameApp(
      title: 'FFrame Database Studio',
      designSystem: designSystem,
      brightness: brightness,
      density: _isCompact ? const FStandardDensityTokens(compact: true) : null,
      color: designSystem.tokens.colors.accent,
      windowManager: widget.windowManager,
      home: widget.currentWindow?.route == '/inspector'
          ? const _InspectorWindow()
          : _DatabaseClientDemo(
              isDark: _isDark,
              isCompact: _isCompact,
              onToggleBrightness: () => setState(() => _isDark = !_isDark),
              onCompactChanged: (value) => setState(() => _isCompact = value),
            ),
    );
  }
}

class _InspectorWindow extends FStatelessWidget {
  const _InspectorWindow();

  @override
  FWidget build(FBuildContext context) => FWindowFrame(
    title: 'Query inspector',
    leading: const FIcon(FIcons.tune),
    child: const FPadding(
      padding: FEdgeInsets.all(24),
      child: FColumn(
        crossAxisAlignment: FCrossAxisAlignment.start,
        children: <FWidget>[
          FText('Inspector window'),
          FSizedBox(height: 8),
          FText('This independent window is hosted entirely with F APIs.'),
        ],
      ),
    ),
  );
}

class _DatabaseClientDemo extends FStatefulWidget {
  const _DatabaseClientDemo({
    required this.isDark,
    required this.isCompact,
    required this.onToggleBrightness,
    required this.onCompactChanged,
  });

  final bool isDark;
  final bool isCompact;
  final FVoidCallback onToggleBrightness;
  final FValueChanged<bool> onCompactChanged;

  @override
  FState<_DatabaseClientDemo> createState() => _DatabaseClientDemoState();
}

class _DatabaseClientDemoState extends FState<_DatabaseClientDemo> {
  int _selectedIndex = 0;
  final FWorkspaceController _workspaceController = FWorkspaceController();

  @override
  void dispose() {
    _workspaceController.dispose();
    super.dispose();
  }

  @override
  FWidget build(FBuildContext context) {
    final titleBar = _buildTitleBar(context);
    if (_selectedIndex == 0) {
      return FDesktopShell(
        titleBar: titleBar,
        commandArea: FCommandArea(
          primary: <FCommandItem>[
            FCommandItem(
              expanded: FButton(
                variant: FButtonVariant.primary,
                onPressed: () {},
                child: const FRow(
                  mainAxisSize: FMainAxisSize.min,
                  children: <FWidget>[
                    FIcon(FIcons.play),
                    FSizedBox(width: 6),
                    FText('Run query'),
                  ],
                ),
              ),
              compact: FIconButton(
                tooltip: 'Run query',
                onPressed: () {},
                icon: const FIcon(FIcons.play),
              ),
              priority: 100,
              preferredWidth: 120,
              compactWidth: 40,
            ),
            FCommandItem(
              expanded: FButton(
                onPressed: () {},
                child: const FRow(
                  mainAxisSize: FMainAxisSize.min,
                  children: <FWidget>[
                    FIcon(FIcons.save),
                    FSizedBox(width: 6),
                    FText('Save'),
                  ],
                ),
              ),
              compact: FIconButton(
                tooltip: 'Save query',
                onPressed: () {},
                icon: const FIcon(FIcons.save),
              ),
              priority: 80,
              preferredWidth: 84,
              compactWidth: 40,
            ),
            FCommandItem(
              expanded: FButton(
                onPressed: () {},
                child: const FRow(
                  mainAxisSize: FMainAxisSize.min,
                  children: <FWidget>[
                    FIcon(FIcons.autoFormat),
                    FSizedBox(width: 6),
                    FText('Format SQL'),
                  ],
                ),
              ),
              compact: FIconButton(
                tooltip: 'Format SQL',
                onPressed: () {},
                icon: const FIcon(FIcons.autoFormat),
              ),
              priority: 40,
              preferredWidth: 124,
              compactWidth: 40,
            ),
          ],
          secondary: <FCommandItem>[
            FCommandItem(
              expanded: FButton(
                onPressed: () {},
                child: const FRow(
                  mainAxisSize: FMainAxisSize.min,
                  children: <FWidget>[
                    FIcon(FIcons.accountTree),
                    FSizedBox(width: 6),
                    FText('Explain'),
                  ],
                ),
              ),
              compact: FIconButton(
                tooltip: 'Explain query',
                onPressed: () {},
                icon: const FIcon(FIcons.accountTree),
              ),
              priority: 10,
              preferredWidth: 100,
              compactWidth: 40,
            ),
          ],
        ),
        navigation: FWorkspacePane(
          collapseBehavior: FPaneCollapseBehavior.overlay,
          child: const _DatabaseTree(),
          compactChild: const _CompactDatabaseTree(),
          preferredSize: 248,
          minSize: 190,
        ),
        body: FGrid(
          columns: const <FTrack>[FTrack.flex()],
          rows: const <FTrack>[FTrack.flex(), FTrack.fixed(220)],
          rowGap: 1,
          children: <FGridItem>[
            FGridItem(row: 0, child: const _QueryEditor()),
            FGridItem(row: 1, child: const _QueryResults()),
          ],
        ),
        inspector: const FWorkspacePane(
          collapseBehavior: FPaneCollapseBehavior.overlay,
          preferredSize: 300,
          minSize: 250,
          child: _Inspector(),
        ),
        workspaceController: _workspaceController,
        statusBar: const _StatusBar(),
      );
    }
    return _SettingsAdminPage(
      titleBar: titleBar,
      isCompact: widget.isCompact,
      onCompactChanged: widget.onCompactChanged,
    );
  }

  FWidget _buildTitleBar(FBuildContext context) => FContainer(
    height: 48,
    padding: const FEdgeInsets.symmetric(horizontal: 12),
    color: FTheme.of(context).tokens.colors.surfaceRaised,
    child: FTitleBarLayout(
      leading: FIcon(
        _selectedIndex == 0 ? FIcons.storage : FIcons.administration,
        color: FTheme.of(context).tokens.colors.accent,
      ),
      title: FText(
        _selectedIndex == 0
            ? 'FFrame Database Studio'
            : 'FFrame Administration',
      ),
      center: const FSizedBox(
        width: 320,
        child: FSearchBox(placeholder: 'Search tables, queries…'),
      ),
      actions: <FWidget>[
        FButton(
          size: FControlSize.compact,
          variant: _selectedIndex == 0
              ? FButtonVariant.primary
              : FButtonVariant.subtle,
          onPressed: () => setState(() => _selectedIndex = 0),
          child: const FText('Databases'),
        ),
        FButton(
          size: FControlSize.compact,
          variant: _selectedIndex == 1
              ? FButtonVariant.primary
              : FButtonVariant.subtle,
          onPressed: () => setState(() => _selectedIndex = 1),
          child: const FText('Administration'),
        ),
        FIconButton(
          tooltip: widget.isDark
              ? 'Switch to light theme'
              : 'Switch to dark theme',
          onPressed: widget.onToggleBrightness,
          icon: FIcon(widget.isDark ? FIcons.lightMode : FIcons.darkMode),
        ),
        FIconButton(
          tooltip: widget.isCompact
              ? 'Use comfortable density'
              : 'Use compact density',
          onPressed: () => widget.onCompactChanged(!widget.isCompact),
          icon: const FIcon(FIcons.lineSpacing),
        ),
        FIconButton(
          tooltip: 'Toggle navigation',
          onPressed: _workspaceController.toggleNavigation,
          icon: const FIcon(FIcons.menu),
        ),
        FIconButton(
          tooltip: 'Toggle inspector',
          onPressed: _workspaceController.toggleInspector,
          icon: const FIcon(FIcons.tune),
        ),
        if (FWindowManager.maybeOf(context) != null)
          FIconButton(
            tooltip: 'Open inspector in a new window',
            onPressed: () async {
              await FWindowManager.of(context).open(
                const FWindowSpec(
                  id: 'inspector',
                  title: 'Query inspector',
                  route: '/inspector',
                  size: FSize(560, 720),
                ),
              );
            },
            icon: const FIcon(FIcons.launch),
          ),
      ],
      spacing: 8,
    ),
  );
}

class _DatabaseTree extends FStatelessWidget {
  const _DatabaseTree();

  @override
  FWidget build(FBuildContext context) => FSidebar(
    width: 248,
    header: FRow(
      children: <FWidget>[
        FExpanded(
          child: FText(
            'EXPLORER',
            style: FTheme.of(context).tokens.typography.sectionTitle.copyWith(
              color: FTheme.of(context).tokens.colors.textSecondary,
            ),
          ),
        ),
        FIconButton(
          tooltip: 'Explorer actions',
          onPressed: () {},
          size: FControlSize.compact,
          icon: const FIcon(FIcons.moreHorizontal),
        ),
      ],
    ),
    children: <FWidget>[
      FSidebarItem(
        label: 'Production',
        icon: const FIcon(FIcons.database),
        trailing: const FIcon(FIcons.expandMore, size: 18),
        onPressed: () {},
      ),
      FPadding(
        padding: const FEdgeInsets.only(left: 16),
        child: FColumn(
          children: <FWidget>[
            FSidebarItem(
              label: 'public',
              icon: const FIcon(FIcons.folderOpen),
              trailing: const FIcon(FIcons.expandMore, size: 18),
              onPressed: () {},
            ),
            FSidebarItem(
              label: 'customers',
              icon: const FIcon(FIcons.table),
              selected: true,
              onPressed: () {},
            ),
            FSidebarItem(
              label: 'orders',
              icon: const FIcon(FIcons.table),
              onPressed: () {},
            ),
            FSidebarItem(
              label: 'products',
              icon: const FIcon(FIcons.table),
              onPressed: () {},
            ),
          ],
        ),
      ),
      FSidebarItem(
        label: 'Functions',
        icon: const FIcon(FIcons.folder),
        onPressed: () {},
      ),
      FSidebarItem(
        label: 'Views',
        icon: const FIcon(FIcons.folder),
        onPressed: () {},
      ),
    ],
  );
}

class _CompactDatabaseTree extends FStatelessWidget {
  const _CompactDatabaseTree();

  @override
  FWidget build(FBuildContext context) => FSidebar(
    collapsed: true,
    children: <FWidget>[
      FSidebarItem(
        label: 'Tables',
        icon: const FIcon(FIcons.table),
        selected: true,
        collapsed: true,
        onPressed: () {},
      ),
      FSidebarItem(
        label: 'Views',
        icon: const FIcon(FIcons.folder),
        collapsed: true,
        onPressed: () {},
      ),
    ],
  );
}

class _QueryEditor extends FStatefulWidget {
  const _QueryEditor();

  @override
  FState<_QueryEditor> createState() => _QueryEditorState();
}

class _QueryEditorState extends FState<_QueryEditor> {
  final FTextEditingController _controller = FTextEditingController(
    text: 'SELECT id, name, email, city\nFROM customers\nORDER BY name;',
  );
  final FFocusNode _focusNode = FFocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  FWidget build(FBuildContext context) {
    final theme = FTheme.of(context);
    final colors = theme.tokens.colors;
    return FColumn(
      crossAxisAlignment: FCrossAxisAlignment.stretch,
      children: <FWidget>[
        FContainer(
          height: 34,
          padding: const FEdgeInsets.symmetric(horizontal: 14),
          color: colors.surfaceSubtle,
          alignment: FAlignment.centerLeft,
          child: const FRow(
            children: <FWidget>[
              FIcon(FIcons.description, size: 16),
              FSizedBox(width: 8),
              FText('customer_overview.sql'),
              FSizedBox(width: 8),
              FIcon(FIcons.circle, size: 7, color: FColor(0xffd83b01)),
            ],
          ),
        ),
        FExpanded(
          child: FContainer(
            color: colors.surface,
            padding: const FEdgeInsets.all(16),
            child: FTextField(
              controller: _controller,
              focusNode: _focusNode,
              textStyle: theme.tokens.typography.monospace.copyWith(
                color: colors.textPrimary,
                height: 1.6,
              ),
              cursorColor: colors.accent,
              backgroundCursorColor: colors.textPrimary,
              selectionColor: colors.selection,
              maxLines: null,
              minLines: null,
              expands: true,
            ),
          ),
        ),
      ],
    );
  }
}

class _QueryResults extends FStatelessWidget {
  const _QueryResults();

  @override
  FWidget build(FBuildContext context) {
    final theme = FTheme.of(context);
    final colors = theme.tokens.colors;
    final rows = const <List<String>>[
      <String>['id', 'name', 'email', 'city'],
      <String>['1001', 'Ada Lovelace', 'ada@example.com', 'London'],
      <String>['1002', 'Grace Hopper', 'grace@example.com', 'New York'],
      <String>['1003', 'Linus Torvalds', 'linus@example.com', 'Helsinki'],
    ];
    return FColoredBox(
      color: colors.surfaceSubtle,
      child: FColumn(
        crossAxisAlignment: FCrossAxisAlignment.stretch,
        children: <FWidget>[
          FPadding(
            padding: const FEdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: FRow(
              children: <FWidget>[
                FText(
                  'RESULTS',
                  style: theme.tokens.typography.label.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const FSizedBox(width: 12),
                FText(
                  '3 rows',
                  style: theme.tokens.typography.label.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const FSpacer(),
                FIcon(FIcons.download, size: 18, color: colors.textSecondary),
                const FSizedBox(width: 10),
                FIcon(FIcons.openInFull, size: 17, color: colors.textSecondary),
              ],
            ),
          ),
          const FDivider(),
          FExpanded(
            child: FSingleChildScrollView(
              scrollDirection: FLayoutAxis.horizontal,
              child: FTable(
                defaultColumnWidth: const FIntrinsicColumnWidth(),
                border: FTableBorder(
                  horizontalInside: FBorderSide(color: colors.border),
                ),
                children: <FTableRow>[
                  for (var rowIndex = 0; rowIndex < rows.length; rowIndex++)
                    FTableRow(
                      decoration: FBoxDecoration(
                        color: rowIndex == 0 ? colors.surfaceRaised : null,
                      ),
                      children: <FWidget>[
                        for (final value in rows[rowIndex])
                          FPadding(
                            padding: const FEdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            child: FText(
                              value,
                              style: rowIndex == 0
                                  ? theme.tokens.typography.label.copyWith(
                                      color: colors.textSecondary,
                                      fontWeight: FFontWeight.w600,
                                    )
                                  : theme.tokens.typography.body,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Inspector extends FStatelessWidget {
  const _Inspector();

  @override
  FWidget build(FBuildContext context) {
    final theme = FTheme.of(context);
    final colors = theme.tokens.colors;
    return FColoredBox(
      color: colors.surfaceSubtle,
      child: FColumn(
        crossAxisAlignment: FCrossAxisAlignment.stretch,
        children: <FWidget>[
          FPadding(
            padding: const FEdgeInsets.fromLTRB(16, 18, 12, 8),
            child: FRow(
              children: <FWidget>[
                FExpanded(
                  child: FText(
                    'INSPECTOR',
                    style: theme.tokens.typography.label.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                FIcon(FIcons.close, size: 18, color: colors.textSecondary),
              ],
            ),
          ),
          const FDivider(),
          const FPadding(
            padding: FEdgeInsets.all(12),
            child: FRow(
              children: <FWidget>[
                FIcon(FIcons.table, size: 18),
                FSizedBox(width: 8),
                FExpanded(
                  child: FColumn(
                    crossAxisAlignment: FCrossAxisAlignment.start,
                    children: <FWidget>[
                      FText('customers'),
                      FText('Table · public schema'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const FPadding(
            padding: FEdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FText('COLUMNS'),
          ),
          const _InspectorProperty(name: 'id', type: 'integer · primary key'),
          const _InspectorProperty(name: 'name', type: 'varchar(120)'),
          const _InspectorProperty(name: 'email', type: 'varchar(255)'),
        ],
      ),
    );
  }
}

class _InspectorProperty extends FStatelessWidget {
  const _InspectorProperty({required this.name, required this.type});

  final String name;
  final String type;

  @override
  FWidget build(FBuildContext context) {
    final theme = FTheme.of(context);
    return FPadding(
      padding: const FEdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: FColumn(
        crossAxisAlignment: FCrossAxisAlignment.start,
        children: <FWidget>[
          FText(name, style: theme.tokens.typography.bodyStrong),
          FText(
            type,
            style: theme.tokens.typography.caption.copyWith(
              color: theme.tokens.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBar extends FStatelessWidget {
  const _StatusBar();

  @override
  FWidget build(FBuildContext context) => FContainer(
    height: 26,
    padding: const FEdgeInsets.symmetric(horizontal: 12),
    color: FTheme.of(context).tokens.colors.surfaceRaised,
    child: FDefaultTextStyle.merge(
      style: FTheme.of(context).tokens.typography.caption
          .copyWith(color: FTheme.of(context).tokens.colors.textSecondary),
      child: const FStatusArea(
        leading: FText('Connected to Production · PostgreSQL 16'),
        trailing: FText('Ready  ·  12 ms'),
      ),
    ),
  );
}

enum _SettingsSection { general, members, security, integrations }

class _SettingsAdminPage extends FStatefulWidget {
  const _SettingsAdminPage({
    required this.titleBar,
    required this.isCompact,
    required this.onCompactChanged,
  });

  final FWidget titleBar;
  final bool isCompact;
  final FValueChanged<bool> onCompactChanged;

  @override
  FState<_SettingsAdminPage> createState() => _SettingsAdminPageState();
}

class _SettingsAdminPageState extends FState<_SettingsAdminPage> {
  _SettingsSection _section = _SettingsSection.general;
  bool _saved = true;

  @override
  FWidget build(FBuildContext context) => FDesktopShell(
    titleBar: widget.titleBar,
    commandArea: FCommandArea(
      primary: <FCommandItem>[
        FCommandItem(
          expanded: FButton(
            variant: FButtonVariant.primary,
            onPressed: () => setState(() => _saved = true),
            child: const FRow(
              mainAxisSize: FMainAxisSize.min,
              children: <FWidget>[
                FIcon(FIcons.save),
                FSizedBox(width: 6),
                FText('Save changes'),
              ],
            ),
          ),
          compact: FIconButton(
            tooltip: 'Save changes',
            onPressed: () => setState(() => _saved = true),
            icon: const FIcon(FIcons.save),
          ),
          preferredWidth: 144,
          compactWidth: 40,
          priority: 100,
        ),
      ],
    ),
    navigation: FWorkspacePane(
      preferredSize: 220,
      minSize: 184,
      compactChild: _SettingsSectionNavigation(
        selectedSection: _section,
        onSelected: _selectSection,
        compact: true,
      ),
      child: _SettingsSectionNavigation(
        selectedSection: _section,
        onSelected: _selectSection,
      ),
    ),
    body: _SettingsContent(
      section: _section,
      isCompact: widget.isCompact,
      onCompactChanged: widget.onCompactChanged,
    ),
    statusBar: FContainer(
      height: 26,
      padding: const FEdgeInsets.symmetric(horizontal: 12),
      color: FTheme.of(context).tokens.colors.surfaceRaised,
      child: FDefaultTextStyle.merge(
        style: FTheme.of(context).tokens.typography.caption
            .copyWith(color: FTheme.of(context).tokens.colors.textSecondary),
        child: FStatusArea(
          leading: const FText('Administration · All systems operational'),
          trailing: FText(_saved ? 'Changes saved' : 'Unsaved changes'),
        ),
      ),
    ),
  );

  void _selectSection(_SettingsSection section) {
    setState(() => _section = section);
  }
}

class _SettingsSectionNavigation extends FStatelessWidget {
  const _SettingsSectionNavigation({
    required this.selectedSection,
    required this.onSelected,
    this.compact = false,
  });

  final _SettingsSection selectedSection;
  final FValueChanged<_SettingsSection> onSelected;
  final bool compact;

  static const sections = <(_SettingsSection, FIconData, String)>[
    (_SettingsSection.general, FIcons.tune, 'General'),
    (_SettingsSection.members, FIcons.people, 'Members'),
    (_SettingsSection.security, FIcons.security, 'Security'),
    (_SettingsSection.integrations, FIcons.extension, 'Integrations'),
  ];

  @override
  FWidget build(FBuildContext context) => FSidebar(
    width: 220,
    collapsed: compact,
    header: compact
        ? null
        : FPadding(
            padding: const FEdgeInsets.fromLTRB(12, 4, 12, 10),
            child: FText(
              'WORKSPACE SETTINGS',
              style: FTheme.of(context).tokens.typography.label.copyWith(
                color: FTheme.of(context).tokens.colors.textSecondary,
              ),
            ),
          ),
    children: <FWidget>[
      for (final section in sections)
        FSidebarItem(
          label: section.$3,
          icon: FIcon(section.$2, size: 19),
          selected: selectedSection == section.$1,
          collapsed: compact,
          onPressed: () => onSelected(section.$1),
        ),
    ],
  );
}

class _SettingsContent extends FStatelessWidget {
  const _SettingsContent({
    required this.section,
    required this.isCompact,
    required this.onCompactChanged,
  });

  final _SettingsSection section;
  final bool isCompact;
  final FValueChanged<bool> onCompactChanged;

  @override
  FWidget build(FBuildContext context) => FSingleChildScrollView(
    padding: const FEdgeInsets.all(24),
    child: FAlign(
      alignment: FAlignment.topCenter,
      child: FConstrainedBox(
        constraints: const FBoxConstraints(maxWidth: 780),
        child: _buildSection(context),
      ),
    ),
  );

  FWidget _buildSection(FBuildContext context) {
    final theme = FTheme.of(context);
    final title = switch (section) {
      _SettingsSection.general => 'General',
      _SettingsSection.members => 'Members',
      _SettingsSection.security => 'Security',
      _SettingsSection.integrations => 'Integrations',
    };
    final description = switch (section) {
      _SettingsSection.general =>
        'Manage your organization profile and regional preferences.',
      _SettingsSection.members =>
        'Manage who can access your organization and their roles.',
      _SettingsSection.security =>
        'Configure authentication and session policies.',
      _SettingsSection.integrations =>
        'Connect the tools your team uses every day.',
    };

    return FColumn(
      crossAxisAlignment: FCrossAxisAlignment.stretch,
      children: <FWidget>[
        FText(title, style: theme.tokens.typography.title),
        const FSizedBox(height: 6),
        FText(
          description,
          style: theme.tokens.typography.body.copyWith(
            color: theme.tokens.colors.textSecondary,
          ),
        ),
        const FSizedBox(height: 24),
        FPanel(
          raised: true,
          padding: const FEdgeInsets.all(24),
          child: switch (section) {
            _SettingsSection.general => const _GeneralSettingsForm(),
            _SettingsSection.members => const _MembersSettingsPanel(),
            _SettingsSection.security => const _SecuritySettingsForm(),
            _SettingsSection.integrations => const _IntegrationsSettingsPanel(),
          },
        ),
        if (section == _SettingsSection.general) ...<FWidget>[
          const FSizedBox(height: 24),
          FText(
            'Controls gallery',
            style: theme.tokens.typography.sectionTitle,
          ),
          const FSizedBox(height: 12),
          _ControlsGallery(
            isCompact: isCompact,
            onCompactChanged: onCompactChanged,
          ),
        ],
      ],
    );
  }
}

class _GeneralSettingsForm extends FStatefulWidget {
  const _GeneralSettingsForm();

  @override
  FState<_GeneralSettingsForm> createState() => _GeneralSettingsFormState();
}

class _GeneralSettingsFormState extends FState<_GeneralSettingsForm> {
  String _region = 'Asia Pacific (Shanghai)';

  @override
  FWidget build(FBuildContext context) {
    final theme = FTheme.of(context);
    return FColumn(
      crossAxisAlignment: FCrossAxisAlignment.stretch,
      children: <FWidget>[
        FText('Organization profile', style: theme.tokens.typography.title),
        const FSizedBox(height: 16),
        const FTextField(
          label: 'Organization name',
          placeholder: 'Acme Corporation',
        ),
        const FSizedBox(height: 16),
        const FTextField(
          label: 'Billing email',
          placeholder: 'billing@example.com',
        ),
        const FSizedBox(height: 16),
        FText(
          'Default region',
          style: theme.tokens.typography.label.copyWith(
            color: theme.tokens.colors.textPrimary,
          ),
        ),
        const FSizedBox(height: 6),
        FSelect<String>(
          value: _region,
          onChanged: (value) => setState(() => _region = value ?? _region),
          items: const <FSelectItem<String>>[
            FSelectItem(
              value: 'Asia Pacific (Shanghai)',
              label: 'Asia Pacific (Shanghai)',
            ),
            FSelectItem(value: 'US West', label: 'US West'),
            FSelectItem(value: 'Europe', label: 'Europe'),
          ],
        ),
      ],
    );
  }
}

class _ControlsGallery extends FStatefulWidget {
  const _ControlsGallery({
    required this.isCompact,
    required this.onCompactChanged,
  });

  final bool isCompact;
  final FValueChanged<bool> onCompactChanged;

  @override
  FState<_ControlsGallery> createState() => _ControlsGalleryState();
}

class _ControlsGalleryState extends FState<_ControlsGallery> {
  bool _checked = true;
  String _environment = 'Development';
  int _tabIndex = 0;

  @override
  FWidget build(FBuildContext context) => FPanel(
    padding: const FEdgeInsets.all(20),
    child: FColumn(
      crossAxisAlignment: FCrossAxisAlignment.start,
      children: <FWidget>[
        FText(
          'Actions',
          style: FTheme.of(context).tokens.typography.sectionTitle,
        ),
        const FSizedBox(height: 12),
        FWrap(
          spacing: 8,
          runSpacing: 8,
          children: <FWidget>[
            FButton(
              variant: FButtonVariant.primary,
              onPressed: () {},
              child: const FText('Primary'),
            ),
            FButton(
              variant: FButtonVariant.secondary,
              onPressed: () {},
              child: const FText('Secondary'),
            ),
            FButton(
              variant: FButtonVariant.subtle,
              onPressed: () {},
              child: const FText('Subtle'),
            ),
            FButton(
              variant: FButtonVariant.danger,
              onPressed: () {},
              child: const FText('Danger'),
            ),
            FButton(onPressed: null, child: const FText('Disabled')),
            FIconButton(
              icon: const FIcon(FIcons.moreHorizontal),
              onPressed: () {},
              tooltip: 'More actions',
            ),
            FTooltip(
              message: 'Anchored to its control',
              child: FButton(onPressed: () {}, child: const FText('Tooltip')),
            ),
            FPopover(
              placement: FPlacement.bottomStart,
              trigger: FContainer(
                height: 32,
                padding: const FEdgeInsets.symmetric(horizontal: 12),
                alignment: FAlignment.center,
                decoration: FBoxDecoration(
                  color: FTheme.of(context).tokens.colors.surface,
                  borderRadius: FTheme.of(context).tokens.radius.control,
                  border: FBorder.all(
                    color: FTheme.of(context).tokens.colors.borderStrong,
                  ),
                ),
                child: FText(
                  'Popover',
                  style: FTheme.of(context).tokens.typography.label,
                ),
              ),
              content: const FPanel(
                padding: FEdgeInsets.all(16),
                child: FText('Popover content follows its anchor.'),
              ),
            ),
            FButton(
              onPressed: () {
                showFDialog<void>(
                  context: context,
                  builder: (dialogContext) => FDialog(
                    title: const FText('Confirm action'),
                    content: const FText(
                      'This dialog uses the active FFrame design system.',
                    ),
                    actions: <FWidget>[
                      FButton(
                        onPressed: () => FNavigator.pop(dialogContext),
                        child: const FText('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: const FText('Dialog'),
            ),
          ],
        ),
        const FSizedBox(height: 20),
        const FDivider(),
        const FSizedBox(height: 16),
        FText(
          'Inputs and state',
          style: FTheme.of(context).tokens.typography.sectionTitle,
        ),
        const FSizedBox(height: 12),
        const FSearchBox(placeholder: 'Search controls…'),
        const FSizedBox(height: 12),
        FSelect<String>(
          value: _environment,
          onChanged: (value) =>
              setState(() => _environment = value ?? _environment),
          items: const <FSelectItem<String>>[
            FSelectItem(value: 'Development', label: 'Development'),
            FSelectItem(value: 'Staging', label: 'Staging'),
            FSelectItem(value: 'Production', label: 'Production'),
          ],
        ),
        const FSizedBox(height: 12),
        FWrap(
          spacing: 20,
          runSpacing: 8,
          children: <FWidget>[
            FCheckbox(
              value: _checked,
              onChanged: (value) => setState(() => _checked = value ?? false),
              label: const FText('Enable notifications'),
            ),
            FSwitch(
              value: widget.isCompact,
              onChanged: widget.onCompactChanged,
              label: const FText('Compact density'),
            ),
          ],
        ),
        const FSizedBox(height: 20),
        FText('Tabs', style: FTheme.of(context).tokens.typography.sectionTitle),
        const FSizedBox(height: 8),
        FSizedBox(
          height: 128,
          child: FTabs(
            selectedIndex: _tabIndex,
            onChanged: (value) => setState(() => _tabIndex = value),
            tabs: const <FTab>[
              FTab(
                label: 'Overview',
                child: FCenter(child: FText('Overview panel')),
              ),
              FTab(
                label: 'Activity',
                child: FCenter(child: FText('Recent activity')),
              ),
              FTab(
                label: 'Access',
                child: FCenter(child: FText('Access policy')),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MembersSettingsPanel extends FStatelessWidget {
  const _MembersSettingsPanel();

  @override
  FWidget build(FBuildContext context) {
    return FColumn(
      crossAxisAlignment: FCrossAxisAlignment.stretch,
      children: <FWidget>[
        FRow(
          children: <FWidget>[
            const FExpanded(child: FText('Organization members')),
            FButton(
              onPressed: () {},
              child: const FRow(
                mainAxisSize: FMainAxisSize.min,
                children: <FWidget>[
                  FIcon(FIcons.addPerson),
                  FSizedBox(width: 6),
                  FText('Invite member'),
                ],
              ),
            ),
          ],
        ),
        const FSizedBox(height: 12),
        const FDivider(),
        const _MemberEntry(
          initials: 'AL',
          name: 'Alex Lee',
          email: 'alex@example.com',
          role: 'Admin',
        ),
        const FDivider(),
        const _MemberEntry(
          initials: 'JM',
          name: 'Jamie Miller',
          email: 'jamie@example.com',
          role: 'Editor',
        ),
      ],
    );
  }
}

class _MemberEntry extends FStatelessWidget {
  const _MemberEntry({
    required this.initials,
    required this.name,
    required this.email,
    required this.role,
  });

  final String initials;
  final String name;
  final String email;
  final String role;

  @override
  FWidget build(FBuildContext context) {
    final theme = FTheme.of(context);
    final colors = theme.tokens.colors;
    return FPadding(
      padding: const FEdgeInsets.symmetric(vertical: 10),
      child: FRow(
        children: <FWidget>[
          FContainer(
            width: 36,
            height: 36,
            alignment: FAlignment.center,
            decoration: FBoxDecoration(
              color: colors.selection,
              borderRadius: theme.tokens.radius.control,
              border: FBorder.all(color: colors.border),
            ),
            child: FText(
              initials,
              style: theme.tokens.typography.label.copyWith(
                color: colors.textPrimary,
                fontWeight: FFontWeight.w600,
              ),
            ),
          ),
          const FSizedBox(width: 12),
          FExpanded(
            child: FColumn(
              crossAxisAlignment: FCrossAxisAlignment.start,
              children: <FWidget>[
                FText(name, style: theme.tokens.typography.bodyStrong),
                FText(
                  email,
                  style: theme.tokens.typography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          FText(
            role,
            style: theme.tokens.typography.label.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SecuritySettingsForm extends FStatefulWidget {
  const _SecuritySettingsForm();

  @override
  FState<_SecuritySettingsForm> createState() => _SecuritySettingsFormState();
}

class _SecuritySettingsFormState extends FState<_SecuritySettingsForm> {
  bool _requireTwoFactor = true;
  bool _singleSignOn = true;

  @override
  FWidget build(FBuildContext context) => FColumn(
    crossAxisAlignment: FCrossAxisAlignment.stretch,
    children: <FWidget>[
      FText(
        'Authentication policy',
        style: FTheme.of(context).tokens.typography.title,
      ),
      const FSizedBox(height: 8),
      const FDivider(),
      _SecurityOptionRow(
        title: 'Require two factor authentication',
        subtitle: 'Protect all organization accounts with an extra step.',
        value: _requireTwoFactor,
        onChanged: (value) => setState(() => _requireTwoFactor = value),
      ),
      const FDivider(),
      _SecurityOptionRow(
        title: 'Single sign-on',
        subtitle: 'Allow members to sign in through your identity provider.',
        value: _singleSignOn,
        onChanged: (value) => setState(() => _singleSignOn = value),
      ),
    ],
  );
}

class _SecurityOptionRow extends FStatelessWidget {
  const _SecurityOptionRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final FValueChanged<bool> onChanged;

  @override
  FWidget build(FBuildContext context) {
    final theme = FTheme.of(context);
    return FPadding(
      padding: const FEdgeInsets.symmetric(vertical: 10),
      child: FRow(
        children: <FWidget>[
          FExpanded(
            child: FColumn(
              crossAxisAlignment: FCrossAxisAlignment.start,
              children: <FWidget>[
                FText(title, style: theme.tokens.typography.bodyStrong),
                const FSizedBox(height: 3),
                FText(
                  subtitle,
                  style: theme.tokens.typography.caption.copyWith(
                    color: theme.tokens.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const FSizedBox(width: 16),
          FSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _IntegrationsSettingsPanel extends FStatelessWidget {
  const _IntegrationsSettingsPanel();

  @override
  FWidget build(FBuildContext context) {
    final theme = FTheme.of(context);
    return FColumn(
      crossAxisAlignment: FCrossAxisAlignment.stretch,
      children: <FWidget>[
        _IntegrationEntry(
          icon: FIcons.chat,
          title: 'Slack',
          description: 'Send query and audit notifications to Slack.',
          trailing: FIcon(
            FIcons.checkCircle,
            color: theme.tokens.colors.success,
          ),
        ),
        const FDivider(),
        _IntegrationEntry(
          icon: FIcons.webhook,
          title: 'Webhooks',
          description: 'Notify external services when workspace events occur.',
          trailing: FIcon(
            FIcons.chevronRight,
            color: theme.tokens.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _IntegrationEntry extends FStatelessWidget {
  const _IntegrationEntry({
    required this.icon,
    required this.title,
    required this.description,
    required this.trailing,
  });

  final FIconData icon;
  final String title;
  final String description;
  final FWidget trailing;

  @override
  FWidget build(FBuildContext context) {
    final theme = FTheme.of(context);
    return FPadding(
      padding: const FEdgeInsets.symmetric(vertical: 12),
      child: FRow(
        children: <FWidget>[
          FIcon(icon, color: theme.tokens.colors.textSecondary),
          const FSizedBox(width: 12),
          FExpanded(
            child: FColumn(
              crossAxisAlignment: FCrossAxisAlignment.start,
              children: <FWidget>[
                FText(title, style: theme.tokens.typography.bodyStrong),
                FText(
                  description,
                  style: theme.tokens.typography.caption.copyWith(
                    color: theme.tokens.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
