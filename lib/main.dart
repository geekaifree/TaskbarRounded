import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const TaskbarRoundedApp());
class TaskbarRoundedApp extends StatelessWidget {
  const TaskbarRoundedApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(title: '任务栏圆角美化', debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.purple, useMaterial3: true, brightness: Brightness.light),
    darkTheme: ThemeData(colorSchemeSeed: Colors.purple, useMaterial3: true, brightness: Brightness.dark),
    home: const RoundedTaskbarHomePage());
}

class RoundedTaskbarHomePage extends StatefulWidget {
  const RoundedTaskbarHomePage({super.key});
  @override
  State<RoundedTaskbarHomePage> setState() => _RoundedTaskbarHomePageState();
}

class _RoundedTaskbarHomePageState extends State<RoundedTaskbarHomePage> {
  double _cornerRadius = 16;
  double _taskbarHeight = 48;
  double _margin = 8;
  double _opacity = 0.85;
  bool _floating = true;
  bool _showShadow = true;
  Color _bgColor = Colors.black;
  double _bgOpacity = 0.7;
  final _bgColors = [Colors.black, Colors.grey.shade900, Colors.indigo.shade900, Colors.purple.shade900, Colors.teal.shade900];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() { _cornerRadius = p.getDouble('cornerRadius') ?? 16; _margin = p.getDouble('margin') ?? 8; _opacity = p.getDouble('opacity') ?? 0.85; _floating = p.getBool('floating') ?? true; _showShadow = p.getBool('showShadow') ?? true; });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble('cornerRadius', _cornerRadius); await p.setDouble('margin', _margin); await p.setDouble('opacity', _opacity); await p.setBool('floating', _floating); await p.setBool('showShadow', _showShadow);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎨 任务栏圆角'), centerTitle: true, actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: () { setState(() { _cornerRadius = 16; _margin = 8; _opacity = 0.85; _floating = true; _showShadow = true; }); _save(); }, tooltip: '重置'),
      ]),
      body: Column(children: [
        // 预览
        Expanded(flex: 2, child: Container(margin: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.indigo, Colors.purple]), borderRadius: BorderRadius.circular(16)), child: Stack(children: [
          const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.desktop_windows, size: 48, color: Colors.white), SizedBox(height: 8), Text('桌面预览', style: TextStyle(color: Colors.white, fontSize: 16))])),
          Positioned(left: _floating ? _margin.toDouble() : 0, right: _floating ? _margin.toDouble() : 0, bottom: _floating ? _margin.toDouble() : 0, child: Container(
            height: _taskbarHeight,
            decoration: BoxDecoration(color: _bgColor.withOpacity(_bgOpacity), borderRadius: _floating ? BorderRadius.circular(_cornerRadius) : BorderRadius.vertical(top: Radius.circular(_floating ? _cornerRadius : 0)), boxShadow: _showShadow ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, -2))] : null),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _buildTaskbarIcon(Icons.window), const SizedBox(width: 16), _buildTaskbarIcon(Icons.search), const SizedBox(width: 16),
              _buildTaskbarIcon(Icons.folder), const SizedBox(width: 16), _buildTaskbarIcon(Icons.chrome_reader_mode),
            ]),
          )),
        ]))),
        // 设置
        Expanded(flex: 3, child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('圆角设置', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Row(children: [const Text('圆角半径: '), Expanded(child: Slider(value: _cornerRadius, min: 0, max: 32, onChanged: (v) { setState(() => _cornerRadius = v); _save(); })), Text('${_cornerRadius.toInt()}px')]),
            Row(children: [const Text('边距: '), Expanded(child: Slider(value: _margin, min: 0, max: 24, onChanged: (v) { setState(() => _margin = v); _save(); })), Text('${_margin.toInt()}px')]),
          ]))),
          const SizedBox(height: 8),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('外观设置', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SwitchListTile(title: const Text('浮动模式'), subtitle: const Text('任务栏悬浮在桌面之上'), value: _floating, onChanged: (v) { setState(() => _floating = v); _save(); }, contentPadding: EdgeInsets.zero),
            SwitchListTile(title: const Text('显示阴影'), value: _showShadow, onChanged: (v) { setState(() => _showShadow = v); _save(); }, contentPadding: EdgeInsets.zero),
            Row(children: [const Text('透明度: '), Expanded(child: Slider(value: _bgOpacity, onChanged: (v) { setState(() => _bgOpacity = v); _save(); })), Text('${(_bgOpacity * 100).toInt()}%')]),
            const SizedBox(height: 8),
            const Text('背景颜色'), const SizedBox(height: 8),
            Wrap(spacing: 8, children: _bgColors.map((c) => GestureDetector(onTap: () => setState(() => _bgColor = c), child: Container(width: 36, height: 36, decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: _bgColor == c ? Colors.white : Colors.transparent, width: 2))))).toList()),
          ]))),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () { _save(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('设置已保存并应用'), behavior: SnackBarBehavior.floating)); }, icon: const Icon(Icons.check), label: const Text('应用设置'))),
        ]))),
      ]),
    );
  }

  Widget _buildTaskbarIcon(IconData icon) => Icon(icon, color: Colors.white, size: 22);
}
