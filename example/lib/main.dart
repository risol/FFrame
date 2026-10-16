import 'package:flutter/material.dart';
import 'package:fframe/fframe.dart';
import 'package:fframe/material.dart';

void main() => runApp(const FFrameExampleApp());

/// Interactive Material database client used as the package example.
class FFrameExampleApp extends StatelessWidget {
  /// Creates the example app.
  const FFrameExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FFrame Database Studio',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5264C8)),
      useMaterial3: true,
      visualDensity: VisualDensity.compact,
    ),
    home: const _DatabaseClientDemo(),
  );
}

class _DatabaseClientDemo extends StatefulWidget {
  const _DatabaseClientDemo();

  @override
  State<_DatabaseClientDemo> createState() => _DatabaseClientDemoState();
}

class _DatabaseClientDemoState extends State<_DatabaseClientDemo> {
  int _selectedIndex = 0;
  final FWorkspaceController _workspaceController = FWorkspaceController();

  @override
  void dispose() {
    _workspaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FMaterialShell(
    selectedIndex: _selectedIndex,
    onDestinationSelected: (value) => setState(() => _selectedIndex = value),
    destinations: const <FMaterialDestination>[
      FMaterialDestination(
        icon: Icon(Icons.storage_outlined),
        label: 'Databases',
      ),
      FMaterialDestination(
        icon: Icon(Icons.admin_panel_settings_outlined),
        label: 'Administration',
      ),
    ],
    body: _selectedIndex == 0
        ? FDesktopShell(
            titleBar: _buildTitleBar(context),
            commandArea: FMaterialCommandArea(
              primary: <FCommandItem>[
                FCommandItem(
                  expanded: IconButton(
                    tooltip: 'Run query',
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow_rounded),
                  ),
                  priority: 100,
                  preferredWidth: 44,
                  compactWidth: 40,
                ),
                FCommandItem(
                  expanded: IconButton(
                    tooltip: 'Save query',
                    onPressed: () {},
                    icon: const Icon(Icons.save_outlined),
                  ),
                  compact: IconButton(
                    tooltip: 'Save query',
                    onPressed: () {},
                    icon: const Icon(Icons.save_outlined),
                  ),
                  priority: 80,
                  preferredWidth: 100,
                  compactWidth: 40,
                ),
                FCommandItem(
                  expanded: IconButton(
                    tooltip: 'Format SQL',
                    onPressed: () {},
                    icon: const Icon(Icons.auto_fix_high_outlined),
                  ),
                  compact: IconButton(
                    tooltip: 'Format SQL',
                    onPressed: () {},
                    icon: const Icon(Icons.auto_fix_high_outlined),
                  ),
                  priority: 40,
                  preferredWidth: 100,
                  compactWidth: 40,
                ),
              ],
              secondary: <FCommandItem>[
                FCommandItem(
                  expanded: IconButton(
                    tooltip: 'Explain query',
                    onPressed: () {},
                    icon: const Icon(Icons.account_tree_outlined),
                  ),
                  compact: IconButton(
                    tooltip: 'Explain query',
                    onPressed: () {},
                    icon: const Icon(Icons.account_tree_outlined),
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
          )
        : const _SettingsAdminPage(),
  );

  Widget _buildTitleBar(BuildContext context) => Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    color: Theme.of(context).colorScheme.surfaceContainerHigh,
    child: FTitleBarLayout(
      leading: Icon(
        Icons.storage_rounded,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: const Text('FFrame Database Studio'),
      center: const SizedBox(
        width: 320,
        child: SearchBar(
          hintText: 'Search tables, queries…',
          leading: Icon(Icons.search),
          elevation: WidgetStatePropertyAll(0),
        ),
      ),
      actions: <Widget>[
        IconButton(
          tooltip: 'Toggle navigation',
          onPressed: _workspaceController.toggleNavigation,
          icon: const Icon(Icons.menu),
        ),
        IconButton(
          tooltip: 'Toggle inspector',
          onPressed: _workspaceController.toggleInspector,
          icon: const Icon(Icons.tune),
        ),
      ],
      spacing: 8,
    ),
  );
}

class _DatabaseTree extends StatelessWidget {
  const _DatabaseTree();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 12, 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'EXPLORER',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              Icon(
                Icons.more_horiz,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
        const ListTile(
          dense: true,
          leading: Icon(Icons.dns_outlined, size: 18),
          title: Text('Production'),
          trailing: Icon(Icons.expand_more, size: 18),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Column(
            children: <Widget>[
              ListTile(
                dense: true,
                leading: Icon(Icons.folder_open_outlined, size: 17),
                title: Text('public'),
                trailing: Icon(Icons.expand_more, size: 18),
              ),
              ListTile(
                dense: true,
                selected: true,
                leading: Icon(Icons.table_chart_outlined, size: 17),
                title: Text('customers'),
              ),
              ListTile(
                dense: true,
                leading: Icon(Icons.table_chart_outlined, size: 17),
                title: Text('orders'),
              ),
              ListTile(
                dense: true,
                leading: Icon(Icons.table_chart_outlined, size: 17),
                title: Text('products'),
              ),
            ],
          ),
        ),
        const ListTile(
          dense: true,
          leading: Icon(Icons.folder_outlined, size: 18),
          title: Text('Functions'),
        ),
        const ListTile(
          dense: true,
          leading: Icon(Icons.folder_outlined, size: 18),
          title: Text('Views'),
        ),
      ],
    ),
  );
}

class _CompactDatabaseTree extends StatelessWidget {
  const _CompactDatabaseTree();

  @override
  Widget build(BuildContext context) => NavigationRail(
    selectedIndex: 0,
    labelType: NavigationRailLabelType.none,
    destinations: const <NavigationRailDestination>[
      NavigationRailDestination(
        icon: Icon(Icons.table_chart_outlined),
        label: Text('Tables'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.folder_outlined),
        label: Text('Views'),
      ),
    ],
  );
}

class _QueryEditor extends StatelessWidget {
  const _QueryEditor();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        color: Theme.of(context).colorScheme.surfaceContainer,
        alignment: AlignmentDirectional.centerStart,
        child: const Row(
          children: <Widget>[
            Icon(Icons.description_outlined, size: 16),
            SizedBox(width: 8),
            Text('customer_overview.sql'),
            SizedBox(width: 8),
            Icon(Icons.circle, size: 7, color: Colors.deepOrange),
          ],
        ),
      ),
      Expanded(
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.all(16),
          child: const TextField(
            expands: true,
            maxLines: null,
            minLines: null,
            decoration: InputDecoration.collapsed(hintText: ''),
            style: TextStyle(fontFamily: 'monospace', height: 1.6),
          ),
        ),
      ),
    ],
  );
}

class _QueryResults extends StatelessWidget {
  const _QueryResults();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: <Widget>[
              Text('RESULTS', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(width: 12),
              Text('3 rows', style: Theme.of(context).textTheme.labelSmall),
              const Spacer(),
              const Icon(Icons.download_outlined, size: 18),
              const SizedBox(width: 10),
              const Icon(Icons.open_in_full, size: 17),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 34,
              dataRowMinHeight: 34,
              dataRowMaxHeight: 34,
              columns: const <DataColumn>[
                DataColumn(label: Text('id')),
                DataColumn(label: Text('name')),
                DataColumn(label: Text('email')),
                DataColumn(label: Text('city')),
              ],
              rows: const <DataRow>[
                DataRow(
                  cells: <DataCell>[
                    DataCell(Text('1001')),
                    DataCell(Text('Ada Lovelace')),
                    DataCell(Text('ada@example.com')),
                    DataCell(Text('London')),
                  ],
                ),
                DataRow(
                  cells: <DataCell>[
                    DataCell(Text('1002')),
                    DataCell(Text('Grace Hopper')),
                    DataCell(Text('grace@example.com')),
                    DataCell(Text('New York')),
                  ],
                ),
                DataRow(
                  cells: <DataCell>[
                    DataCell(Text('1003')),
                    DataCell(Text('Linus Torvalds')),
                    DataCell(Text('linus@example.com')),
                    DataCell(Text('Helsinki')),
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

class _Inspector extends StatelessWidget {
  const _Inspector();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 12, 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'INSPECTOR',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              const Icon(Icons.close, size: 18),
            ],
          ),
        ),
        const Divider(height: 1),
        const ListTile(
          dense: true,
          title: Text('customers'),
          subtitle: Text('Table · public schema'),
          leading: Icon(Icons.table_chart_outlined),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('COLUMNS'),
        ),
        const ListTile(
          dense: true,
          title: Text('id'),
          subtitle: Text('integer · primary key'),
        ),
        const ListTile(
          dense: true,
          title: Text('name'),
          subtitle: Text('varchar(120)'),
        ),
        const ListTile(
          dense: true,
          title: Text('email'),
          subtitle: Text('varchar(255)'),
        ),
      ],
    ),
  );
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) => Container(
    height: 26,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    color: Theme.of(context).colorScheme.surfaceContainerHigh,
    child: const FStatusArea(
      leading: Text('Connected to Production · PostgreSQL 16'),
      trailing: Text('Ready  ·  12 ms'),
    ),
  );
}

enum _SettingsSection { general, members, security, integrations }

class _SettingsAdminPage extends StatefulWidget {
  const _SettingsAdminPage();

  @override
  State<_SettingsAdminPage> createState() => _SettingsAdminPageState();
}

class _SettingsAdminPageState extends State<_SettingsAdminPage> {
  _SettingsSection _section = _SettingsSection.general;

  @override
  Widget build(BuildContext context) => FDesktopShell(
    titleBar: Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: FTitleBarLayout(
        leading: Icon(
          Icons.admin_panel_settings_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text('FFrame Administration'),
        center: const SizedBox(
          width: 320,
          child: SearchBar(
            hintText: 'Search settings…',
            leading: Icon(Icons.search),
            elevation: WidgetStatePropertyAll(0),
          ),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: CircleAvatar(radius: 15, child: Text('A')),
          ),
        ],
      ),
    ),
    commandArea: FMaterialCommandArea(
      primary: <FCommandItem>[
        FCommandItem(
          expanded: FilledButton.icon(
            onPressed: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Settings saved'))),
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save changes'),
          ),
          compact: IconButton(
            tooltip: 'Save changes',
            onPressed: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Settings saved'))),
            icon: const Icon(Icons.save_outlined),
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
    body: _SettingsContent(section: _section),
    statusBar: Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: const FStatusArea(
        leading: Text('Administration · All systems operational'),
        trailing: Text('Changes saved automatically'),
      ),
    ),
  );

  void _selectSection(_SettingsSection section) {
    setState(() => _section = section);
  }
}

class _SettingsSectionNavigation extends StatelessWidget {
  const _SettingsSectionNavigation({
    required this.selectedSection,
    required this.onSelected,
    this.compact = false,
  });

  final _SettingsSection selectedSection;
  final ValueChanged<_SettingsSection> onSelected;
  final bool compact;

  static const sections = <(_SettingsSection, IconData, String)>[
    (_SettingsSection.general, Icons.tune, 'General'),
    (_SettingsSection.members, Icons.people_outline, 'Members'),
    (_SettingsSection.security, Icons.shield_outlined, 'Security'),
    (_SettingsSection.integrations, Icons.extension_outlined, 'Integrations'),
  ];

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return NavigationRail(
        selectedIndex: selectedSection.index,
        labelType: NavigationRailLabelType.none,
        onDestinationSelected: (index) =>
            onSelected(_SettingsSection.values[index]),
        destinations: <NavigationRailDestination>[
          for (final section in sections)
            NavigationRailDestination(
              icon: Icon(section.$2),
              label: Text(section.$3),
            ),
        ],
      );
    }

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
            child: Text(
              'WORKSPACE SETTINGS',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          for (final section in sections)
            ListTile(
              dense: true,
              selected: selectedSection == section.$1,
              leading: Icon(section.$2, size: 19),
              title: Text(section.$3),
              onTap: () => onSelected(section.$1),
            ),
        ],
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({required this.section});

  final _SettingsSection section;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780),
        child: _buildSection(context),
      ),
    ),
  );

  Widget _buildSection(BuildContext context) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(description, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: switch (section) {
              _SettingsSection.general => const _GeneralSettingsForm(),
              _SettingsSection.members => const _MembersSettingsPanel(),
              _SettingsSection.security => const _SecuritySettingsForm(),
              _SettingsSection.integrations =>
                const _IntegrationsSettingsPanel(),
            },
          ),
        ),
      ],
    );
  }
}

class _GeneralSettingsForm extends StatelessWidget {
  const _GeneralSettingsForm();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Text('Organization profile'),
      SizedBox(height: 16),
      TextField(
        decoration: InputDecoration(
          labelText: 'Organization name',
          hintText: 'Acme Corporation',
          border: OutlineInputBorder(),
        ),
      ),
      SizedBox(height: 16),
      TextField(
        decoration: InputDecoration(
          labelText: 'Billing email',
          hintText: 'billing@example.com',
          border: OutlineInputBorder(),
        ),
      ),
      SizedBox(height: 16),
      TextField(
        decoration: InputDecoration(
          labelText: 'Default region',
          hintText: 'Asia Pacific (Shanghai)',
          border: OutlineInputBorder(),
        ),
      ),
    ],
  );
}

class _MembersSettingsPanel extends StatelessWidget {
  const _MembersSettingsPanel();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Row(
        children: <Widget>[
          const Expanded(child: Text('Organization members')),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Invite member'),
          ),
        ],
      ),
      const SizedBox(height: 12),
      const ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(child: Text('AL')),
        title: Text('Alex Lee'),
        subtitle: Text('alex@example.com'),
        trailing: Text('Admin'),
      ),
      const ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(child: Text('JM')),
        title: Text('Jamie Miller'),
        subtitle: Text('jamie@example.com'),
        trailing: Text('Editor'),
      ),
    ],
  );
}

class _SecuritySettingsForm extends StatefulWidget {
  const _SecuritySettingsForm();

  @override
  State<_SecuritySettingsForm> createState() => _SecuritySettingsFormState();
}

class _SecuritySettingsFormState extends State<_SecuritySettingsForm> {
  bool _requireTwoFactor = true;
  bool _singleSignOn = true;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      const Text('Authentication policy'),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: _requireTwoFactor,
        onChanged: (value) => setState(() => _requireTwoFactor = value),
        title: const Text('Require two factor authentication'),
        subtitle: const Text(
          'Protect all organization accounts with an extra step.',
        ),
      ),
      const Divider(),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: _singleSignOn,
        onChanged: (value) => setState(() => _singleSignOn = value),
        title: const Text('Single sign-on'),
        subtitle: const Text(
          'Allow members to sign in through your identity provider.',
        ),
      ),
    ],
  );
}

class _IntegrationsSettingsPanel extends StatelessWidget {
  const _IntegrationsSettingsPanel();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.chat_outlined),
        title: Text('Slack'),
        subtitle: Text('Send query and audit notifications to Slack.'),
        trailing: Icon(Icons.check_circle, color: Colors.green),
      ),
      Divider(),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.webhook_outlined),
        title: Text('Webhooks'),
        subtitle: Text('Notify external services when workspace events occur.'),
        trailing: Icon(Icons.chevron_right),
      ),
    ],
  );
}
