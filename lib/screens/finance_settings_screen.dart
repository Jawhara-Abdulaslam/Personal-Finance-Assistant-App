// lib/screens/finance_settings_screen.dart
import 'package:flutter/material.dart';
import '../services/settings_services.dart';
import '../utils/app_constants.dart';

class FinanceSettingsScreen extends StatefulWidget {
  const FinanceSettingsScreen({super.key});

  @override
  State<FinanceSettingsScreen> createState() => _FinanceSettingsScreenState();
}

class _FinanceSettingsScreenState extends State<FinanceSettingsScreen> {
  final SettingsService _settingsService = SettingsService();

  // إعدادات التطبيق المحاسبي
  String _currency = 'ر.س';
  String _dateFormat = 'yyyy-MM-dd';
  bool _backupEnabled = true;
  bool _darkMode = false;
  bool _biometricAuth = false;
  String _taxRate = '15';
  String _startOfWeek = 'saturday';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // جلب الإعدادات المحفوظة
    try {
      // يمكنك إضافة هذه الدوال في SettingsService لاحقاً
      // final settings = await _settingsService.getFinanceSettings();
    } catch (e) {
      print('خطأ في تحميل الإعدادات: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات المحاسبة'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // إعدادات العملة
          _buildSectionTitle('إعدادات العملة'),
          _buildSettingDropdown(
            'العملة',
            Icons.currency_exchange,
            _currency,
                (value) {
              setState(() {
                _currency = value!;
              });
            },
            {
              'ر.س': 'ريال سعودي (ر.س)',
              'د.إ': 'درهم إماراتي (د.إ)',
              'ج.م': 'جنيه مصري (ج.م)',
              '\$': 'دولار (\$)',
              '€': 'يورو (€)',
            },
          ),

          const SizedBox(height: 20),

          // إعدادات التاريخ
          _buildSectionTitle('إعدادات التاريخ'),
          _buildSettingDropdown(
            'تنسيق التاريخ',
            Icons.date_range,
            _dateFormat,
                (value) {
              setState(() {
                _dateFormat = value!;
              });
            },
            {
              'yyyy-MM-dd': '2024-01-15',
              'dd/MM/yyyy': '15/01/2024',
              'MM/dd/yyyy': '01/15/2024',
              'dd MMM yyyy': '15 يناير 2024',
            },
          ),

          _buildSettingDropdown(
            'بداية الأسبوع',
            Icons.calendar_view_week,
            _startOfWeek,
                (value) {
              setState(() {
                _startOfWeek = value!;
              });
            },
            {
              'saturday': 'السبت',
              'sunday': 'الأحد',
              'monday': 'الإثنين',
            },
          ),

          const SizedBox(height: 20),

          // إعدادات الأمان
          _buildSectionTitle('إعدادات الأمان'),
          _buildSettingSwitch(
            'نسخ احتياطي تلقائي',
            'نسخ البيانات تلقائياً',
            _backupEnabled,
                (value) {
              setState(() {
                _backupEnabled = value;
              });
            },
            Icons.backup,
          ),

          _buildSettingSwitch(
            'المصادقة البيومترية',
            'استخدام البصمة أو الوجه للفتح',
            _biometricAuth,
                (value) {
              setState(() {
                _biometricAuth = value;
              });
            },
            Icons.fingerprint,
          ),

          const SizedBox(height: 20),

          // إعدادات الضرائب
          _buildSectionTitle('إعدادات الضرائب'),
          _buildSettingTextField(
            'نسبة الضريبة (%)',
            Icons.percent,
            _taxRate,
                (value) {
              setState(() {
                _taxRate = value;
              });
            },
          ),

          const SizedBox(height: 20),

          // إعدادات الواجهة
          _buildSectionTitle('إعدادات الواجهة'),
          _buildSettingSwitch(
            'الوضع الليلي',
            'تفعيل الوضع الداكن',
            _darkMode,
                (value) {
              setState(() {
                _darkMode = value;
              });
            },
            Icons.dark_mode,
          ),

          const SizedBox(height: 30),

          // أزرار الإجراءات
          _buildActionButtons(),
        ],
      ),
    );
  }

  /// بناء عنوان القسم
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppConstants.primaryColor,
        ),
      ),
    );
  }

  /// بناء زر التبديل (Switch)
  Widget _buildSettingSwitch(
      String title,
      String subtitle,
      bool value,
      Function(bool) onChanged,
      IconData icon,
      ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppConstants.primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppConstants.primaryColor,
        ),
      ),
    );
  }

  /// بناء قائمة منسدلة
  Widget _buildSettingDropdown(
      String title,
      IconData icon,
      String value,
      Function(String?) onChanged,
      Map<String, String> items,
      ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppConstants.primaryColor),
        title: Text(title),
        trailing: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: items.entries.map((entry) {
            return DropdownMenuItem(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// بناء حقل نصي
  Widget _buildSettingTextField(
      String label,
      IconData icon,
      String value,
      Function(String) onChanged,
      ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppConstants.primaryColor),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'أدخل النسبة',
              ),
              keyboardType: TextInputType.number,
              onChanged: onChanged,
              controller: TextEditingController(text: value),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء أزرار الإجراءات
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _resetSettings,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('إعادة التعيين'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('حفظ الإعدادات'),
          ),
        ),
      ],
    );
  }

  /// حفظ الإعدادات
  void _saveSettings() async {
    try {
      // هنا يمكنك إضافة دوال لحفظ كل إعداد
      // await _settingsService.setCurrency(_currency);
      // await _settingsService.setDateFormat(_dateFormat);
      // إلخ...

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الإعدادات بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في حفظ الإعدادات: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// إعادة تعيين الإعدادات
  void _resetSettings() {
    setState(() {
      _currency = 'ر.س';
      _dateFormat = 'yyyy-MM-dd';
      _backupEnabled = true;
      _darkMode = false;
      _biometricAuth = false;
      _taxRate = '15';
      _startOfWeek = 'saturday';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إعادة تعيين الإعدادات'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}