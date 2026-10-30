import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;
import 'package:url_launcher/url_launcher.dart';

const List<String> _languageCodes = ['ar', 'en', 'fr', 'de', 'it', 'es', 'zh'];
const List<String> _languageNames = [
  'العربية',
  'English',
  'Français',
  'Deutsch',
  'Italiano',
  'Español',
  '中文',
];

const Map<String, Color> _themeColors = {
  'ocean': Color(0xFF4A90E2),
  'emerald': Color(0xFF059669),
  'royal': Color(0xFF6D28D9),
  'sunset': Color(0xFFEA580C),
  'crimson': Color(0xFFDC2626),
  'slate': Color(0xFF334155),
};

const Map<String, String> _themeLabels = {
  'ocean': 'Ocean Blue',
  'emerald': 'Emerald Green',
  'royal': 'Royal Purple',
  'sunset': 'Sunset Orange',
  'crimson': 'Crimson',
  'slate': 'Deep Slate',
};

/// The original app signature: a bright light-sky-blue sweep.

const List<Color> _defaultHeaderGradient = [
  Color(0xFF4A90E2),
  Color(0xFF63B8FF),
  Color(0xFF87CEEB),
  Color(0xFFE0F7FA),
];

List<Color> headerGradientForTheme(String themeName, Color primary) {
  if (themeName == 'ocean') return _defaultHeaderGradient;
  final accent = HSLColor.fromColor(
    primary,
  ).withLightness(.32).withSaturation(.72).toColor();
  return [
    accent,
    primary,
    HSLColor.fromColor(primary).withLightness(.57).toColor(),
  ];
}

const Map<String, List<String>> _translations = {
  'متابع العادات': [
    'متابع العادات',
    'Habit Tracker',
    'Suivi des habitudes',
    'Gewohnheitstracker',
    'Tracker abitudini',
    'Seguimiento de hábitos',
    '习惯追踪器',
  ],
  'العادات': [
    'العادات',
    'Habits',
    'Habitudes',
    'Gewohnheiten',
    'Abitudini',
    'Hábitos',
    '习惯',
  ],
  'الإحصائيات': [
    'الإحصائيات',
    'Analytics',
    'Statistiques',
    'Statistiken',
    'Statistiche',
    'Estadísticas',
    '统计',
  ],
  'الفئات': [
    'الفئات',
    'Categories',
    'Catégories',
    'Kategorien',
    'Categorie',
    'Categorías',
    '分类',
  ],
  'الكل': ['الكل', 'All', 'Tout', 'Alle', 'Tutte', 'Todas', '全部'],
  'صحة': ['صحة', 'Health', 'Santé', 'Gesundheit', 'Salute', 'Salud', '健康'],
  'رياضة': ['رياضة', 'Fitness', 'Sport', 'Sport', 'Sport', 'Deporte', '运动'],
  'عبادات': [
    'عبادات',
    'Worship',
    'Spirituality',
    'Andacht',
    'Spiritualità',
    'Espiritualidad',
    '信仰',
  ],
  'عمل': ['عمل', 'Work', 'Travail', 'Arbeit', 'Lavoro', 'Trabajo', '工作'],
  'تطوير': [
    'تطوير',
    'Growth',
    'Progrès',
    'Entwicklung',
    'Crescita',
    'Desarrollo',
    '成长',
  ],
  'قراءة': ['قراءة', 'Reading', 'Lecture', 'Lesen', 'Lettura', 'Lectura', '阅读'],
  'يومياً': [
    'يومياً',
    'Daily',
    'Quotidien',
    'Täglich',
    'Ogni giorno',
    'Diario',
    '每天',
  ],
  'أسبوعياً': [
    'أسبوعياً',
    'Weekly',
    'Hebdomadaire',
    'Wöchentlich',
    'Settimanale',
    'Semanal',
    '每周',
  ],
  'شهرياً': [
    'شهرياً',
    'Monthly',
    'Mensuel',
    'Monatlich',
    'Mensile',
    'Mensual',
    '每月',
  ],
  'مرحباً بك': [
    'مرحباً بك',
    'Welcome',
    'Bienvenue',
    'Willkommen',
    'Benvenuto',
    'Bienvenido',
    '欢迎',
  ],
  'تعديل الاسم': [
    'تعديل الاسم',
    'Edit name',
    'Modifier le nom',
    'Namen bearbeiten',
    'Modifica nome',
    'Editar nombre',
    '编辑姓名',
  ],
  'اسمك': [
    'اسمك',
    'Your name',
    'Votre nom',
    'Dein Name',
    'Il tuo nome',
    'Tu nombre',
    '你的名字',
  ],
  'مثال: أحمد / Alex / Jean': [
    'مثال: أحمد / Alex / Jean',
    'e.g. Alex',
    'ex. Alex',
    'z. B. Alex',
    'es. Alex',
    'p. ej., Alex',
    '例如：Alex',
  ],
  'إلغاء': [
    'إلغاء',
    'Cancel',
    'Annuler',
    'Abbrechen',
    'Annulla',
    'Cancelar',
    '取消',
  ],
  'حفظ': ['حفظ', 'Save', 'Enregistrer', 'Speichern', 'Salva', 'Guardar', '保存'],
  'إضافة عادة جديدة': [
    'إضافة عادة جديدة',
    'Add a habit',
    'Ajouter une habitude',
    'Gewohnheit hinzufügen',
    'Aggiungi abitudine',
    'Añadir hábito',
    '添加习惯',
  ],
  'اسم العادة': [
    'اسم العادة',
    'Habit name',
    'Nom de l’habitude',
    'Name der Gewohnheit',
    'Nome abitudine',
    'Nombre del hábito',
    '习惯名称',
  ],
  'مثال: القراءة اليومية': [
    'مثال: القراءة اليومية',
    'e.g. Read daily',
    'ex. Lire chaque jour',
    'z. B. täglich lesen',
    'es. leggere ogni giorno',
    'p. ej., leer a diario',
    '例如：每天阅读',
  ],
  'الفئة': [
    'الفئة',
    'Category',
    'Catégorie',
    'Kategorie',
    'Categoria',
    'Categoría',
    '分类',
  ],
  'التكرار': [
    'التكرار',
    'Frequency',
    'Fréquence',
    'Häufigkeit',
    'Frequenza',
    'Frecuencia',
    '频率',
  ],
  'يرجى إدخال اسم العادة': [
    'يرجى إدخال اسم العادة',
    'Enter a habit name',
    'Saisissez un nom d’habitude',
    'Gib einen Gewohnheitsnamen ein',
    'Inserisci il nome dell’abitudine',
    'Introduce un nombre de hábito',
    '请输入习惯名称',
  ],
  'إضافة العادة': [
    'إضافة العادة',
    'Add habit',
    'Ajouter',
    'Hinzufügen',
    'Aggiungi',
    'Añadir hábito',
    '添加习惯',
  ],
  'تعديل العادة': [
    'تعديل العادة',
    'Edit habit',
    'Modifier',
    'Bearbeiten',
    'Modifica',
    'Editar hábito',
    '编辑习惯',
  ],
  'حفظ التعديلات': [
    'حفظ التعديلات',
    'Save changes',
    'Enregistrer',
    'Änderungen speichern',
    'Salva modifiche',
    'Guardar cambios',
    '保存更改',
  ],
  'حذف العادة': [
    'حذف العادة',
    'Delete habit',
    'Supprimer',
    'Gewohnheit löschen',
    'Elimina abitudine',
    'Eliminar hábito',
    '删除习惯',
  ],
  'خيارات العادة': [
    'خيارات العادة',
    'Habit options',
    'Options',
    'Optionen',
    'Opzioni',
    'Opciones',
    '习惯选项',
  ],
  'التذكير اليومي': [
    'التذكير اليومي',
    'Daily reminder',
    'Rappel quotidien',
    'Tägliche Erinnerung',
    'Promemoria giornaliero',
    'Recordatorio diario',
    '每日提醒',
  ],
  'تحديد وقت التذكير': [
    'تحديد وقت التذكير',
    'Set reminder time',
    'Définir l’heure',
    'Erinnerungszeit festlegen',
    'Imposta orario',
    'Fijar hora',
    '设置提醒时间',
  ],
  'تحديد وقت التذكير اليومي': [
    'تحديد وقت التذكير اليومي',
    'Set daily reminder time',
    'Définir le rappel quotidien',
    'Tägliche Erinnerung festlegen',
    'Imposta promemoria giornaliero',
    'Configurar recordatorio diario',
    '设置每日提醒时间',
  ],
  'تم تحديث وقت التذكير بنجاح!': [
    'تم تحديث وقت التذكير بنجاح!',
    'Reminder time updated!',
    'Heure du rappel mise à jour !',
    'Erinnerungszeit aktualisiert!',
    'Orario aggiornato!',
    '¡Hora actualizada!',
    '提醒时间已更新！',
  ],
  'تعذر جدولة التذكير. تحقق من أذونات الإشعارات.': [
    'تعذر جدولة التذكير. تحقق من أذونات الإشعارات.',
    'Could not schedule reminder. Check notification permissions.',
    'Impossible de programmer le rappel. Vérifiez les autorisations.',
    'Erinnerung nicht planbar. Benachrichtigungsrechte prüfen.',
    'Impossibile pianificare. Controlla i permessi.',
    'No se pudo programar. Revisa los permisos.',
    '无法安排提醒，请检查通知权限。',
  ],
  'تذكيرك اليومي': [
    'تذكيرك اليومي',
    'Your daily reminder',
    'Votre rappel quotidien',
    'Deine tägliche Erinnerung',
    'Il tuo promemoria',
    'Tu recordatorio diario',
    '每日提醒',
  ],
  'حان وقت متابعة عاداتك اليوم.': [
    'حان وقت متابعة عاداتك اليوم.',
    'Time to check in on your habits.',
    'C’est le moment de suivre vos habitudes.',
    'Zeit, deine Gewohnheiten zu pflegen.',
    'È ora di seguire le tue abitudini.',
    'Es hora de revisar tus hábitos.',
    '该查看今天的习惯了。',
  ],
  'عاداتك': [
    'عاداتك',
    'Your habits',
    'Vos habitudes',
    'Deine Gewohnheiten',
    'Le tue abitudini',
    'Tus hábitos',
    '你的习惯',
  ],
  'الاشتراك المميز': [
    'الاشتراك المميز',
    'Unlock Pro',
    'Débloquer Pro',
    'Pro freischalten',
    'Sblocca Pro',
    'Desbloquear Pro',
    '解锁专业版',
  ],
  'عادات': [
    'عادات',
    'habits',
    'habitudes',
    'Gewohnheiten',
    'abitudini',
    'hábitos',
    '个习惯',
  ],
  'لا توجد عادات حتى الآن': [
    'لا توجد عادات حتى الآن',
    'No habits yet',
    'Aucune habitude pour le moment',
    'Noch keine Gewohnheiten',
    'Ancora nessuna abitudine',
    'Aún no hay hábitos',
    '还没有习惯',
  ],
  'ابدأ بتسجيل عادة جديدة وراقب تقدمك يوميًا': [
    'ابدأ بتسجيل عادة جديدة وراقب تقدمك يوميًا',
    'Add a habit and track your daily progress',
    'Ajoutez une habitude et suivez vos progrès',
    'Füge eine Gewohnheit hinzu und verfolge deinen Fortschritt',
    'Aggiungi un’abitudine e segui i progressi',
    'Añade un hábito y sigue tu progreso',
    '添加习惯并追踪每日进度',
  ],
  'لا توجد عادات في هذه الفئة': [
    'لا توجد عادات في هذه الفئة',
    'No habits in this category',
    'Aucune habitude dans cette catégorie',
    'Keine Gewohnheiten in dieser Kategorie',
    'Nessuna abitudine in questa categoria',
    'No hay hábitos en esta categoría',
    '此分类中没有习惯',
  ],
  'إنجاز اليوم': [
    'إنجاز اليوم',
    'Today’s progress',
    'Progrès du jour',
    'Heutiger Fortschritt',
    'Progressi di oggi',
    'Progreso de hoy',
    '今日进度',
  ],
  'مرحباً، {name}': [
    'مرحباً، {name}',
    'Hello, {name}',
    'Bonjour, {name}',
    'Hallo, {name}',
    'Ciao, {name}',
    'Hola, {name}',
    '你好，{name}',
  ],
  'فتح القائمة': [
    'فتح القائمة',
    'Open menu',
    'Ouvrir le menu',
    'Menü öffnen',
    'Apri menu',
    'Abrir menú',
    '打开菜单',
  ],
  'تعديل الاسم ({name})': [
    'تعديل الاسم ({name})',
    'Edit name ({name})',
    'Modifier le nom ({name})',
    'Namen bearbeiten ({name})',
    'Modifica nome ({name})',
    'Editar nombre ({name})',
    '编辑姓名（{name}）',
  ],
  'المظهر الداكن': [
    'المظهر الداكن',
    'Dark appearance',
    'Thème sombre',
    'Dunkles Design',
    'Tema scuro',
    'Tema oscuro',
    '深色外观',
  ],
  'لغة التطبيق': [
    'لغة التطبيق',
    'App language',
    'Langue',
    'Sprache',
    'Lingua',
    'Idioma',
    '应用语言',
  ],
  'المساعدة والدعم': [
    'المساعدة والدعم',
    'Help & Support',
    'Aide et assistance',
    'Hilfe & Support',
    'Aiuto e supporto',
    'Ayuda y soporte',
    '帮助与支持',
  ],
  'إدارة الفئات': [
    'إدارة الفئات',
    'Manage categories',
    'Gérer les catégories',
    'Kategorien verwalten',
    'Gestisci categorie',
    'Administrar categorías',
    '管理分类',
  ],
  'Tasks': ['Tasks', 'Tasks', 'Tâches', 'Aufgaben', 'Attività', 'Tareas', '任务'],
  'تفعيل الترقية': [
    'تفعيل الترقية',
    'Unlock Pro',
    'Débloquer Pro',
    'Pro freischalten',
    'Sblocca Pro',
    'Desbloquear Pro',
    '解锁专业版',
  ],
  'مساعدة التطبيق': [
    'مساعدة التطبيق',
    'App help',
    'Aide de l’application',
    'App-Hilfe',
    'Aiuto app',
    'Ayuda de la app',
    '应用帮助',
  ],
  'إرشادات سريعة': [
    'إرشادات سريعة',
    'Quick guides',
    'Guides rapides',
    'Kurzanleitungen',
    'Guide rapide',
    'Guías rápidas',
    '快速指南',
  ],
  'أضف عادة ثم حدّد تكرارها وفئتها.': [
    'أضف عادة ثم حدّد تكرارها وفئتها.',
    'Add a habit, then choose its frequency and category.',
    'Ajoutez une habitude puis choisissez sa fréquence et sa catégorie.',
    'Füge eine Gewohnheit hinzu und wähle Häufigkeit und Kategorie.',
    'Aggiungi un’abitudine e scegli frequenza e categoria.',
    'Añade un hábito y elige frecuencia y categoría.',
    '添加习惯，然后选择频率和分类。',
  ],
  'حدّث إنجازك اليومي من شاشة العادات.': [
    'حدّث إنجازك اليومي من شاشة العادات.',
    'Mark completion from the Habits screen.',
    'Cochez vos habitudes dans l’écran Habitudes.',
    'Markiere Erledigungen im Gewohnheiten-Bildschirm.',
    'Segna i completamenti nella schermata Abitudini.',
    'Marca los hábitos en la pantalla Hábitos.',
    '在习惯页面标记完成状态。',
  ],
  'اختر وقت التذكير اليومي من القائمة.': [
    'اختر وقت التذكير اليومي من القائمة.',
    'Set a daily reminder time from the menu.',
    'Définissez un rappel quotidien depuis le menu.',
    'Lege im Menü eine tägliche Erinnerung fest.',
    'Imposta un promemoria dal menu.',
    'Configura un recordatorio diario desde el menú.',
    '从菜单设置每日提醒时间。',
  ],
  'الأسئلة الشائعة': [
    'الأسئلة الشائعة',
    'FAQ',
    'FAQ',
    'Häufige Fragen',
    'Domande frequenti',
    'Preguntas frecuentes',
    '常见问题',
  ],
  'كيف أضيف عادة؟': [
    'كيف أضيف عادة؟',
    'How do I add a habit?',
    'Comment ajouter une habitude ?',
    'Wie füge ich eine Gewohnheit hinzu?',
    'Come aggiungo un’abitudine?',
    '¿Cómo añado un hábito?',
    '如何添加习惯？',
  ],
  'اضغط إضافة عادة، ثم أدخل الاسم واختر التكرار والفئة.': [
    'اضغط إضافة عادة، ثم أدخل الاسم واختر التكرار والفئة.',
    'Tap Add habit, enter a name, then choose its frequency and category.',
    'Touchez Ajouter, saisissez un nom puis choisissez fréquence et catégorie.',
    'Tippe auf Hinzufügen, gib einen Namen ein und wähle Häufigkeit und Kategorie.',
    'Tocca Aggiungi, inserisci un nome e scegli frequenza e categoria.',
    'Pulsa Añadir, escribe un nombre y elige frecuencia y categoría.',
    '点击添加习惯，输入名称并选择频率和分类。',
  ],
  'كيف أغير وقت التذكير؟': [
    'كيف أغير وقت التذكير؟',
    'How do I change the reminder time?',
    'Comment modifier l’heure du rappel ?',
    'Wie ändere ich die Erinnerungszeit?',
    'Come cambio l’orario del promemoria?',
    '¿Cómo cambio la hora del recordatorio?',
    '如何更改提醒时间？',
  ],
  'افتح القائمة واختر التذكير اليومي.': [
    'افتح القائمة واختر التذكير اليومي.',
    'Open the menu and choose Daily reminder.',
    'Ouvrez le menu et choisissez Rappel quotidien.',
    'Öffne das Menü und wähle Tägliche Erinnerung.',
    'Apri il menu e scegli Promemoria giornaliero.',
    'Abre el menú y elige Recordatorio diario.',
    '打开菜单并选择每日提醒。',
  ],
  'أين أجد إحصائياتي؟': [
    'أين أجد إحصائياتي؟',
    'Where are my statistics?',
    'Où trouver mes statistiques ?',
    'Wo finde ich meine Statistiken?',
    'Dove trovo le statistiche?',
    '¿Dónde están mis estadísticas?',
    '在哪里查看统计？',
  ],
  'استخدم تبويب الإحصائيات في شريط التنقل.': [
    'استخدم تبويب الإحصائيات في شريط التنقل.',
    'Open the Analytics tab in the navigation bar.',
    'Ouvrez l’onglet Statistiques dans la barre de navigation.',
    'Öffne den Statistik-Tab in der Navigation.',
    'Apri la scheda Statistiche nella barra di navigazione.',
    'Abre la pestaña Estadísticas en la barra de navegación.',
    '点击导航栏中的统计标签。',
  ],
  'مساحة أكبر لعاداتك، وتركيز أعمق على تقدمك.': [
    'مساحة أكبر لعاداتك، وتركيز أعمق على تقدمك.',
    'More room for your habits and deeper insight into your progress.',
    'Plus de place pour vos habitudes et un meilleur suivi.',
    'Mehr Platz für Gewohnheiten und tiefere Einblicke in deinen Fortschritt.',
    'Più spazio per le abitudini e più approfondimenti sui progressi.',
    'Más espacio para tus hábitos y mejor seguimiento.',
    '更多习惯空间，更深入了解进度。',
  ],
  'تذكير يومي بمتابعة عاداتك': [
    'تذكير يومي بمتابعة عاداتك',
    'Daily habit reminder',
    'Rappel quotidien des habitudes',
    'Tägliche Gewohnheitserinnerung',
    'Promemoria quotidiano delle abitudini',
    'Recordatorio diario de hábitos',
    '每日习惯提醒',
  ],
  'راسل الدعم': [
    'راسل الدعم',
    'Email support',
    'Contacter le support',
    'Support kontaktieren',
    'Contatta il supporto',
    'Contactar soporte',
    '联系支持',
  ],
  'تم نسخ البريد الإلكتروني': [
    'تم نسخ البريد الإلكتروني',
    'Email copied',
    'E-mail copié',
    'E-Mail kopiert',
    'Email copiato',
    'Correo copiado',
    '邮箱已复制',
  ],
  'الفئة الجديدة': [
    'الفئة الجديدة',
    'New category',
    'Nouvelle catégorie',
    'Neue Kategorie',
    'Nuova categoria',
    'Nueva categoría',
    '新分类',
  ],
  'اسم الفئة': [
    'اسم الفئة',
    'Category name',
    'Nom de catégorie',
    'Kategoriename',
    'Nome categoria',
    'Nombre de categoría',
    '分类名称',
  ],
  'إضافة فئة': [
    'إضافة فئة',
    'Add category',
    'Ajouter une catégorie',
    'Kategorie hinzufügen',
    'Aggiungi categoria',
    'Añadir categoría',
    '添加分类',
  ],
  'تعديل الفئة': [
    'تعديل الفئة',
    'Edit category',
    'Modifier la catégorie',
    'Kategorie bearbeiten',
    'Modifica categoria',
    'Editar categoría',
    '编辑分类',
  ],
  'حذف الفئة': [
    'حذف الفئة',
    'Delete category',
    'Supprimer la catégorie',
    'Kategorie löschen',
    'Elimina categoria',
    'Eliminar categoría',
    '删除分类',
  ],
  'تأكيد حذف الفئة؟': [
    'تأكيد حذف الفئة؟',
    'Delete this category?',
    'Supprimer cette catégorie ?',
    'Kategorie löschen?',
    'Eliminare questa categoria?',
    '¿Eliminar esta categoría?',
    '删除此分类？',
  ],
  'أضف فئتك الأولى': [
    'أضف فئتك الأولى',
    'Add your first category',
    'Ajoutez votre première catégorie',
    'Füge deine erste Kategorie hinzu',
    'Aggiungi la prima categoria',
    'Añade tu primera categoría',
    '添加你的第一个分类',
  ],
  'لا يمكن ترك الاسم فارغاً': [
    'لا يمكن ترك الاسم فارغاً',
    'Name cannot be empty',
    'Le nom ne peut pas être vide',
    'Der Name darf nicht leer sein',
    'Il nome non può essere vuoto',
    'El nombre no puede estar vacío',
    '名称不能为空',
  ],
  'هذه الفئة موجودة بالفعل': [
    'هذه الفئة موجودة بالفعل',
    'This category already exists',
    'Cette catégorie existe déjà',
    'Diese Kategorie gibt es bereits',
    'Questa categoria esiste già',
    'Esta categoría ya existe',
    '此分类已存在',
  ],
  'لا يمكن حذف فئة تحتوي على عادات': [
    'لا يمكن حذف فئة تحتوي على عادات',
    'Move its habits before deleting this category',
    'Déplacez ses habitudes avant de la supprimer',
    'Verschiebe die Gewohnheiten vor dem Löschen',
    'Sposta le abitudini prima di eliminarla',
    'Mueve sus hábitos antes de eliminarla',
    '请先移动其中的习惯再删除分类',
  ],
  'عادات غير محدودة': [
    'عادات غير محدودة',
    'Unlimited habits',
    'Habitudes illimitées',
    'Unbegrenzte Gewohnheiten',
    'Abitudini illimitate',
    'Hábitos ilimitados',
    '无限习惯',
  ],
  'إحصائيات متقدمة': [
    'إحصائيات متقدمة',
    'Advanced analytics',
    'Statistiques avancées',
    'Erweiterte Statistiken',
    'Statistiche avanzate',
    'Estadísticas avanzadas',
    '高级统计',
  ],
  'دعم الفئات المخصصة': [
    'دعم الفئات المخصصة',
    'Custom categories',
    'Catégories personnalisées',
    'Eigene Kategorien',
    'Categorie personalizzate',
    'Categorías personalizadas',
    '自定义分类',
  ],
  'بدون إعلانات': [
    'بدون إعلانات',
    'Ad-free',
    'Sans publicité',
    'Werbefrei',
    'Senza pubblicità',
    'Sin anuncios',
    '无广告',
  ],
  'الترقية إلى Habit Tracker Pro': [
    'الترقية إلى Habit Tracker Pro',
    'Upgrade to Habit Tracker Pro',
    'Passer à Habit Tracker Pro',
    'Upgrade auf Habit Tracker Pro',
    'Passa a Habit Tracker Pro',
    'Mejorar a Habit Tracker Pro',
    '升级至 Habit Tracker Pro',
  ],
  'مزايا Pro': [
    'مزايا Pro',
    'Pro benefits',
    'Avantages Pro',
    'Pro-Vorteile',
    'Vantaggi Pro',
    'Ventajas Pro',
    'Pro 权益',
  ],
  'اشتراك شهري': [
    'اشتراك شهري',
    'Monthly plan',
    'Abonnement mensuel',
    'Monatsabo',
    'Piano mensile',
    'Plan mensual',
    '月度订阅',
  ],
  'لكل شهر': [
    'لكل شهر',
    'per month',
    'par mois',
    'pro Monat',
    'al mese',
    'al mes',
    '每月',
  ],
  'اشتراك سنوي': [
    'اشتراك سنوي',
    'Annual plan',
    'Abonnement annuel',
    'Jahresabo',
    'Piano annuale',
    'Plan anual',
    '年度订阅',
  ],
  'لكل سنة': [
    'لكل سنة',
    'per year',
    'par an',
    'pro Jahr',
    'all’anno',
    'al año',
    '每年',
  ],
  'خصم 40%': [
    'خصم 40%',
    'Save 40%',
    '-40 %',
    '40 % Rabatt',
    'Risparmia il 40%',
    'Ahorra 40%',
    '优惠 40%',
  ],
  'تفعيل Pro للتجربة': [
    'تفعيل Pro للتجربة',
    'Enable Pro demo',
    'Activer la démo Pro',
    'Pro-Demo aktivieren',
    'Attiva demo Pro',
    'Activar demo Pro',
    '启用 Pro 演示',
  ],
  'وضع تجريبي محفوظ على هذا الجهاز': [
    'وضع تجريبي محفوظ على هذا الجهاز',
    'Demo mode saved on this device',
    'Mode démo enregistré sur cet appareil',
    'Demomodus auf diesem Gerät gespeichert',
    'Demo salvata su questo dispositivo',
    'Modo demo guardado en este dispositivo',
    '演示模式保存在此设备',
  ],
  'اشترك الآن': [
    'اشترك الآن',
    'Subscribe now',
    'S’abonner',
    'Jetzt abonnieren',
    'Abbonati ora',
    'Suscribirse',
    '立即订阅',
  ],
  'تم تفعيل Pro': [
    'تم تفعيل Pro',
    'Pro enabled',
    'Pro activé',
    'Pro aktiviert',
    'Pro attivato',
    'Pro activado',
    'Pro 已启用',
  ],
  'تخطي / إغلاق': [
    'تخطي / إغلاق',
    'Skip / Close',
    'Ignorer / Fermer',
    'Überspringen / Schließen',
    'Salta / Chiudi',
    'Omitir / Cerrar',
    '跳过 / 关闭',
  ],
  'أيام': ['أيام', 'days', 'jours', 'Tage', 'giorni', 'días', '天'],
  'السلسلة الحالية': [
    'السلسلة الحالية',
    'Current streak',
    'Série actuelle',
    'Aktuelle Serie',
    'Serie attuale',
    'Racha actual',
    '当前连续天数',
  ],
  'أفضل سلسلة': [
    'أفضل سلسلة',
    'Best streak',
    'Meilleure série',
    'Beste Serie',
    'Migliore serie',
    'Mejor racha',
    '最长连续天数',
  ],
  'نسبة الالتزام': [
    'نسبة الالتزام',
    'Completion rate',
    'Taux de réalisation',
    'Erfüllungsrate',
    'Tasso di completamento',
    'Tasa de cumplimiento',
    '完成率',
  ],
  'من عاداتك المجدولة اليوم': [
    'من عاداتك المجدولة اليوم',
    'of habits scheduled today',
    'des habitudes prévues aujourd’hui',
    'der heute geplanten Gewohnheiten',
    'delle abitudini previste oggi',
    'de los hábitos programados hoy',
    '今日计划习惯',
  ],
  'إنجازات الأسبوع': [
    'إنجازات الأسبوع',
    'This week',
    'Cette semaine',
    'Diese Woche',
    'Questa settimana',
    'Esta semana',
    '本周',
  ],
  'الشارات': [
    'الشارات',
    'Achievements',
    'Succès',
    'Erfolge',
    'Traguardi',
    'Logros',
    '成就',
  ],
  'بطل البداية': [
    'بطل البداية',
    'First step',
    'Premier pas',
    'Erster Schritt',
    'Primo passo',
    'Primer paso',
    '迈出第一步',
  ],
  'مستمر للأسبوع الأول': [
    'مستمر للأسبوع الأول',
    'Week one streak',
    'Une semaine régulière',
    'Eine Woche dran',
    'Una settimana costante',
    'Una semana constante',
    '坚持一周',
  ],
  'عزيمة فولاذية': [
    'عزيمة فولاذية',
    'Unstoppable',
    'Volonté de fer',
    'Eiserner Wille',
    'Volontà d’acciaio',
    'Voluntad de acero',
    '钢铁意志',
  ],
  'كل خطوة صغيرة تصنع فرقاً.': [
    'كل خطوة صغيرة تصنع فرقاً.',
    'Small steps make a difference.',
    'Chaque petit pas compte.',
    'Kleine Schritte machen den Unterschied.',
    'Ogni piccolo passo conta.',
    'Cada pequeño paso cuenta.',
    '每一小步都有意义。',
  ],
  'إغلاق': ['إغلاق', 'Close', 'Fermer', 'Schließen', 'Chiudi', 'Cerrar', '关闭'],
};

String appText(
  BuildContext context,
  String key, {
  Map<String, String> values = const {},
}) {
  final code = Localizations.localeOf(context).languageCode;
  final translated = appTextForCode(code, key);
  return values.entries.fold(
    translated,
    (text, entry) => text.replaceAll('{${entry.key}}', entry.value),
  );
}

void main() {
  runApp(const HabitTrackerApp());
}

class HabitTrackerApp extends StatefulWidget {
  const HabitTrackerApp({super.key});

  @override
  State<HabitTrackerApp> createState() => _HabitTrackerAppState();
}

class _HabitTrackerAppState extends State<HabitTrackerApp> {
  bool _isDarkMode = false;
  String _languageCode = 'en';
  String _themeName = 'ocean';
  bool _settingsLoaded = false;
  bool _onboardingComplete = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isDarkMode = prefs.getBool('dark_mode_enabled') ?? false;
        final storedLanguage = prefs.getString('language_code') ?? 'en';
        _languageCode = _languageCodes.contains(storedLanguage)
            ? storedLanguage
            : 'en';
        final storedTheme = prefs.getString('app_theme_name') ?? 'ocean';
        _themeName = _themeColors.containsKey(storedTheme)
            ? storedTheme
            : 'ocean';
        // Treat existing installs with a saved name as already onboarded.
        _onboardingComplete =
            prefs.getBool('is_first_login') == false ||
            (prefs.getBool('is_first_login') == null &&
                (prefs.getString('user_name')?.trim().isNotEmpty ?? false));
        _settingsLoaded = true;
      });
    }
  }

  Future<void> _setDarkMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode_enabled', enabled);
    if (mounted) {
      setState(() => _isDarkMode = enabled);
    }
  }

  Future<void> _setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    if (mounted) {
      setState(() => _languageCode = languageCode);
    }
  }

  Future<void> _setTheme(String themeName) async {
    if (!_themeColors.containsKey(themeName)) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme_name', themeName);
    if (mounted) setState(() => _themeName = themeName);
  }

  Future<void> _completeOnboarding(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name.trim());
    await prefs.setString('user_email', email.trim());
    await prefs.setString('language_code', _languageCode);
    await prefs.setBool('is_first_login', false);
    if (mounted) {
      setState(() => _onboardingComplete = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _themeColors[_themeName]!;
    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F7FF),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.light().textTheme),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: primaryColor.withValues(alpha: .14),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFF1D2333)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: StadiumBorder(),
        extendedTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F6FF),
        hintStyle: const TextStyle(color: Color(0xFF8A90A5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0E1326),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        color: const Color(0xFF182033),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );

    return MaterialApp(
      title: appTextForCode(_languageCode, 'متابع العادات'),
      debugShowCheckedModeBanner: false,
      locale: Locale(_languageCode),
      supportedLocales: _languageCodes.map(Locale.new).toList(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: lightTheme,
      darkTheme: darkTheme,
      themeAnimationDuration: Duration.zero,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: !_settingsLoaded
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : !_onboardingComplete
          ? OnboardingScreen(
              languageCode: _languageCode,
              onLanguageChanged: _setLanguage,
              onContinue: _completeOnboarding,
            )
          : HabitTrackerHomePage(
              isDarkMode: _isDarkMode,
              onDarkModeChanged: _setDarkMode,
              languageCode: _languageCode,
              onLanguageChanged: _setLanguage,
              themeName: _themeName,
              onThemeChanged: _setTheme,
            ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  final String languageCode;
  final Future<void> Function(String) onLanguageChanged;
  final Future<void> Function(String name, String email) onContinue;

  const OnboardingScreen({
    super.key,
    required this.languageCode,
    required this.onLanguageChanged,
    required this.onContinue,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _saving = false;

  static const _copy = {
    'en': [
      'Welcome',
      'Choose your language',
      'Your name',
      'Email (optional)',
      'Get Started',
    ],
    'ar': [
      'مرحباً',
      'اختر لغتك',
      'اسمك',
      'البريد الإلكتروني (اختياري)',
      'ابدأ',
    ],
    'fr': [
      'Bienvenue',
      'Choisissez votre langue',
      'Votre nom',
      'E-mail (facultatif)',
      'Commencer',
    ],
    'de': [
      'Willkommen',
      'Sprache auswählen',
      'Dein Name',
      'E-Mail (optional)',
      'Loslegen',
    ],
    'it': [
      'Benvenuto',
      'Scegli la lingua',
      'Il tuo nome',
      'Email (facoltativa)',
      'Inizia',
    ],
    'es': [
      'Bienvenido',
      'Elige tu idioma',
      'Tu nombre',
      'Correo (opcional)',
      'Comenzar',
    ],
    'zh': ['欢迎', '选择语言', '你的名字', '电子邮件（可选）', '开始使用'],
  };

  List<String> get _strings => _copy[widget.languageCode] ?? _copy['en']!;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _saving = true);
    await widget.onContinue(_nameController.text, _emailController.text);
    if (!mounted) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = _strings;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/icon/app_icon.png',
                      width: 88,
                      height: 88,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tasks',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      strings[0],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(strings[1]),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: widget.languageCode,
                      items: List.generate(
                        _languageCodes.length,
                        (index) => DropdownMenuItem(
                          value: _languageCodes[index],
                          child: Text(_languageNames[index]),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          widget.onLanguageChanged(value);
                        }
                      },
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(labelText: strings[2]),
                      validator: (value) =>
                          (value?.trim().isEmpty ?? true) ? strings[2] : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: strings[3]),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _saving ? null : _submit,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(strings[4]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String appTextForCode(String code, String key) {
  final index = _languageCodes.indexOf(code);
  if (index < 0) {
    return key;
  }
  return _translations[key]?[index] ?? key;
}

class HabitTrackerHomePage extends StatefulWidget {
  final bool isDarkMode;
  final Future<void> Function(bool enabled)? onDarkModeChanged;
  final String languageCode;
  final Future<void> Function(String languageCode)? onLanguageChanged;
  final String themeName;
  final Future<void> Function(String themeName)? onThemeChanged;

  const HabitTrackerHomePage({
    super.key,
    this.isDarkMode = false,
    this.onDarkModeChanged,
    this.languageCode = 'ar',
    this.onLanguageChanged,
    this.themeName = 'ocean',
    this.onThemeChanged,
  });

  @override
  State<HabitTrackerHomePage> createState() => _HabitTrackerHomePageState();
}

class _HabitTrackerHomePageState extends State<HabitTrackerHomePage>
    with WidgetsBindingObserver {
  static const int _reminderNotificationId = 217;
  static const List<String> _defaultCategories = [
    'صحة',
    'رياضة',
    'عبادات',
    'عمل',
    'تطوير',
    'قراءة',
  ];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Habit> _habits = [];
  final List<String> _categories = [..._defaultCategories];
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  String _selectedCategory = 'الكل';
  int _selectedTab = 0;
  bool _isPro = false;
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  String _userContactInfo = '';
  String _profileImageBase64 = '';
  String _userBio = '';
  String _dateFormat = 'system';
  DateTime _displayDate = DateTime.now();
  TimeOfDay _displayTime = TimeOfDay.now();
  String _analyticsDisplayStyle = 'bar';
  bool _privateAnalytics = false;
  bool _isCheckingResets = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  bool _reminderEnabled = false;
  bool _notificationsInitialized = false;
  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndResetHabits();
    _loadHabits();
    _loadReminderSettings();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndResetHabits();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadHabits() async {
    final prefs = await _getPrefs();
    final isPro = prefs.getBool('is_pro_key') ?? false;
    final userName = prefs.getString('user_name')?.trim() ?? '';
    final userEmail = prefs.getString('user_email')?.trim() ?? '';
    final userPhone = prefs.getString('user_phone')?.trim() ?? '';
    final userContactInfo = prefs.getString('user_contact_info')?.trim() ?? '';
    final profileImageBase64 = prefs.getString('profile_image_base64') ?? '';
    final userBio = prefs.getString('user_bio') ?? '';
    final dateFormat = prefs.getString('date_format') ?? 'system';
    final analyticsDisplayStyle =
        prefs.getString('analytics_display_style') ?? 'bar';
    final privateAnalytics = prefs.getBool('private_analytics') ?? false;
    final savedDisplayDate = prefs.getString('display_date');
    final savedDisplayHour = prefs.getInt('display_time_hour');
    final savedDisplayMinute = prefs.getInt('display_time_minute');
    final savedCategories = prefs.getStringList('habit_categories');
    if (mounted) {
      setState(() {
        _isPro = isPro;
        _userName = userName;
        _userEmail = userEmail;
        _userPhone = userPhone;
        _userContactInfo = userContactInfo;
        _profileImageBase64 = profileImageBase64;
        _userBio = userBio;
        _dateFormat = dateFormat;
        _analyticsDisplayStyle = analyticsDisplayStyle;
        _privateAnalytics = privateAnalytics;
        _displayDate =
            DateTime.tryParse(savedDisplayDate ?? '') ?? DateTime.now();
        _displayTime = TimeOfDay(
          hour: savedDisplayHour ?? TimeOfDay.now().hour,
          minute: savedDisplayMinute ?? TimeOfDay.now().minute,
        );
        if (savedCategories != null) {
          _categories
            ..clear()
            ..addAll(savedCategories);
        }
      });
    }
    if (userName.isEmpty && mounted) {
      await _showUserNameDialog(required: true);
    }
    final jsonString = prefs.getString('habits_key');

    if (jsonString == null || jsonString.isEmpty) {
      await _checkAndResetHabits();
      return;
    }

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! List) {
        return;
      }

      final loadedHabits = decoded
          .whereType<Map<String, dynamic>>()
          .map((item) => Habit.fromJson(item))
          .whereType<Habit>()
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _habits
          ..clear()
          ..addAll(loadedHabits);
      });
      await _checkAndResetHabits();
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _habits.clear();
      });
    }
  }

  Future<void> _saveHabits() async {
    final prefs = await _getPrefs();
    final jsonString = jsonEncode(
      _habits.map((habit) => habit.toJson()).toList(),
    );
    await prefs.setString('habits_key', jsonString);
  }

  Future<void> _saveCategories() async {
    final prefs = await _getPrefs();
    await prefs.setStringList('habit_categories', _categories);
  }

  String _text(String key, {Map<String, String> values = const {}}) =>
      appText(context, key, values: values);

  bool get _isRtl => widget.languageCode == 'ar';

  Future<void> _showCategoryNameDialog({String? category}) async {
    var name = category ?? '';
    final updatedName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_text(category == null ? 'الفئة الجديدة' : 'تعديل الفئة')),
        content: TextFormField(
          initialValue: category == null ? '' : _text(category),
          autofocus: true,
          textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
          onChanged: (value) => name = value,
          decoration: InputDecoration(labelText: _text('اسم الفئة')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(_text('إلغاء')),
          ),
          FilledButton(
            onPressed: () {
              final value = name.trim();
              if (value.isEmpty) {
                return;
              }
              Navigator.pop(dialogContext, value);
            },
            child: Text(_text('حفظ')),
          ),
        ],
      ),
    );
    if (updatedName == null || !mounted) {
      return;
    }
    if (_categories.contains(updatedName) && updatedName != category) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_text('هذه الفئة موجودة بالفعل'))));
      return;
    }

    setState(() {
      if (category == null) {
        _categories.add(updatedName);
      } else {
        final categoryIndex = _categories.indexOf(category);
        if (categoryIndex < 0) {
          return;
        }
        _categories[categoryIndex] = updatedName;
        for (var index = 0; index < _habits.length; index++) {
          if (_habits[index].category == category) {
            _habits[index] = _habits[index].copyWith(category: updatedName);
          }
        }
      }
    });
    await _saveCategories();
    await _saveHabits();
  }

  Future<void> _deleteCategory(String category) async {
    final inUse = _habits.any((habit) => habit.category == category);
    if (inUse) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_text('لا يمكن حذف فئة تحتوي على عادات'))),
      );
      return;
    }
    setState(() {
      _categories.remove(category);
      if (_selectedCategory == category) {
        _selectedCategory = 'الكل';
      }
    });
    await _saveCategories();
  }

  Future<void> _changeDarkModeFromDrawer(bool enabled) async {
    Navigator.of(context).pop();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) {
      return;
    }
    await widget.onDarkModeChanged?.call(enabled);
  }

  Uint8List? get _profileImageBytes {
    if (_profileImageBase64.isEmpty) return null;
    try {
      return base64Decode(_profileImageBase64);
    } catch (_) {
      return null;
    }
  }

  Future<void> _selectProfileImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 600,
    );
    if (image == null) return;
    final imageBase64 = base64Encode(await image.readAsBytes());
    final prefs = await _getPrefs();
    await prefs.setString('profile_image_base64', imageBase64);
    if (mounted) setState(() => _profileImageBase64 = imageBase64);
  }

  Future<void> _showSettingsDialog() async {
    final prefs = await _getPrefs();
    if (!mounted) return;
    final nameController = TextEditingController(text: _userName);
    final bioController = TextEditingController(text: _userBio);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, refresh) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.settings_outlined, size: 24),
              const SizedBox(width: 10),
              Text(_text('الإعدادات')),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dialogSectionTitle('الملف الشخصي'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      InkWell(
                        onTap: () async {
                          await _selectProfileImage();
                          if (context.mounted) refresh(() {});
                        },
                        borderRadius: BorderRadius.circular(35),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              backgroundImage: _profileImageBytes == null
                                  ? null
                                  : MemoryImage(_profileImageBytes!),
                              child: _profileImageBytes == null
                                  ? Icon(
                                      Icons.person_rounded,
                                      size: 35,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    )
                                  : null,
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'اسم العرض',
                            isDense: true,
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                              ),
                              onPressed: () async {
                                final name = nameController.text.trim();
                                if (name.isNotEmpty) {
                                  await prefs.setString('user_name', name);
                                  if (!context.mounted) return;
                                  setState(() => _userName = name);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تم حفظ الاسم'),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: bioController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'نبذة عنك',
                      hintText: 'اكتب شيئاً عن أهدافك...',
                    ),
                    onChanged: (value) async {
                      await prefs.setString('user_bio', value);
                      if (mounted) setState(() => _userBio = value);
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(),
                  ),
                  _dialogSectionTitle('المظهر والسمات'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: widget.themeName,
                    decoration: const InputDecoration(
                      labelText: 'سمة التطبيق',
                      prefixIcon: Icon(Icons.palette_outlined),
                    ),
                    items: _themeColors.entries
                        .map(
                          (entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: entry.value,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(_themeLabels[entry.key]!),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) async {
                      if (value != null) {
                        await widget.onThemeChanged?.call(value);
                        if (context.mounted) refresh(() {});
                      }
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(),
                  ),
                  _dialogSectionTitle('الوقت والتقويم'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today_rounded),
                          label: Text(
                            MaterialLocalizations.of(
                              context,
                            ).formatShortDate(_displayDate),
                          ),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              initialDate: _displayDate,
                            );
                            if (date != null) {
                              await prefs.setString(
                                'display_date',
                                date.toIso8601String(),
                              );
                              if (mounted) setState(() => _displayDate = date);
                              refresh(() {});
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.access_time_rounded),
                          label: Text(
                            MaterialLocalizations.of(
                              context,
                            ).formatTimeOfDay(_displayTime),
                          ),
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _displayTime,
                            );
                            if (time != null) {
                              await prefs.setInt(
                                'display_time_hour',
                                time.hour,
                              );
                              await prefs.setInt(
                                'display_time_minute',
                                time.minute,
                              );
                              if (mounted) setState(() => _displayTime = time);
                              refresh(() {});
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _dateFormat,
                    decoration: const InputDecoration(labelText: 'تنسيق الوقت'),
                    items: const [
                      DropdownMenuItem(
                        value: 'system',
                        child: Text('تنسيق النظام'),
                      ),
                      DropdownMenuItem(
                        value: '12h',
                        child: Text('وقت 12 ساعة'),
                      ),
                      DropdownMenuItem(
                        value: '24h',
                        child: Text('وقت 24 ساعة'),
                      ),
                    ],
                    onChanged: (value) async {
                      if (value != null) {
                        await prefs.setString('date_format', value);
                        if (mounted) setState(() => _dateFormat = value);
                        refresh(() {});
                      }
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(),
                  ),
                  _dialogSectionTitle('الإحصائيات والخصوصية'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _analyticsDisplayStyle,
                    decoration: const InputDecoration(
                      labelText: 'نوع الرسم البياني الافتراضي',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'bar',
                        child: Text('رسم بياني أعمدة'),
                      ),
                      DropdownMenuItem(
                        value: 'pie',
                        child: Text('رسم بياني دائري'),
                      ),
                      DropdownMenuItem(
                        value: 'line',
                        child: Text('رسم بياني خطي'),
                      ),
                    ],
                    onChanged: (value) async {
                      if (value != null) {
                        await prefs.setString('analytics_display_style', value);
                        if (mounted) {
                          setState(() => _analyticsDisplayStyle = value);
                        }
                        refresh(() {});
                      }
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('إخفاء بيانات الإحصاءات'),
                    subtitle: const Text(
                      'سيتم تشفير بياناتك محلياً فقط',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: _privateAnalytics,
                    onChanged: (value) async {
                      await prefs.setBool('private_analytics', value);
                      if (mounted) setState(() => _privateAnalytics = value);
                      refresh(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(_profileText('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
    nameController.dispose();
    bioController.dispose();
  }

  Widget _dialogSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: Color(0xFF3F51B5),
      ),
    );
  }

  Future<void> _showHelpAndSupport() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9DDE7),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _text('المساعدة والدعم'),
                style: const TextStyle(
                  color: Color(0xFF202943),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              ExpansionTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(_text('إرشادات سريعة')),
                children: [
                  ListTile(
                    dense: true,
                    title: Text(_text('أضف عادة ثم حدّد تكرارها وفئتها.')),
                  ),
                  ListTile(
                    dense: true,
                    title: Text(_text('حدّث إنجازك اليومي من شاشة العادات.')),
                  ),
                  ListTile(
                    dense: true,
                    title: Text(_text('اختر وقت التذكير اليومي من القائمة.')),
                  ),
                ],
              ),
              ExpansionTile(
                leading: const Icon(Icons.quiz_outlined),
                title: Text(_text('الأسئلة الشائعة')),
                children: [
                  ListTile(
                    dense: true,
                    title: Text(_text('كيف أضيف عادة؟')),
                    subtitle: Text(
                      _text(
                        'اضغط إضافة عادة، ثم أدخل الاسم واختر التكرار والفئة.',
                      ),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    title: Text(_text('كيف أغير وقت التذكير؟')),
                    subtitle: Text(_text('افتح القائمة واختر التذكير اليومي.')),
                  ),
                  ListTile(
                    dense: true,
                    title: Text(_text('أين أجد إحصائياتي؟')),
                    subtitle: Text(
                      _text('استخدم تبويب الإحصائيات في شريط التنقل.'),
                    ),
                  ),
                ],
              ),
              ListTile(
                leading: const Icon(Icons.mail_outline_rounded),
                title: Text(_text('راسل الدعم')),
                subtitle: const Text('support@habittracker.app'),
                onTap: () async {
                  final uri = Uri(
                    scheme: 'mailto',
                    path: 'support@habittracker.app',
                    queryParameters: {'subject': 'Habit Tracker support'},
                  );
                  final launched = await launchUrl(uri);
                  if (!launched && sheetContext.mounted) {
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      SnackBar(content: Text('support@habittracker.app')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadReminderSettings() async {
    final prefs = await _getPrefs();
    final reminderTime = TimeOfDay(
      hour: prefs.getInt('reminder_hour') ?? 8,
      minute: prefs.getInt('reminder_minute') ?? 0,
    );
    final reminderEnabled = prefs.getBool('reminder_enabled') ?? false;
    final exactAlarmAllowed = prefs.getBool('reminder_exact_alarm') ?? false;
    if (mounted) {
      setState(() {
        _reminderTime = reminderTime;
        _reminderEnabled = reminderEnabled;
      });
    }

    timezone_data.initializeTimeZones();
    try {
      final initialized = await _notifications.initialize(
        settings: InitializationSettings(
          android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: const DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      _notificationsInitialized = initialized ?? false;
    } catch (_) {
      _notificationsInitialized = false;
    }

    if (reminderEnabled && _notificationsInitialized) {
      try {
        await _scheduleDailyReminder(
          reminderTime,
          useExactAlarm: exactAlarmAllowed,
        );
      } catch (_) {
        // The saved time remains visible; the user can retry from the reminder control.
      }
    }
  }

  Future<bool> _requestReminderPermissions() async {
    if (!_notificationsInitialized) {
      throw StateError('Notifications are not available on this device.');
    }

    if (Theme.of(context).platform == TargetPlatform.android) {
      final androidNotifications = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final notificationsAllowed = await androidNotifications
          ?.requestNotificationsPermission();
      if (notificationsAllowed == false) {
        throw StateError('Notification permission was denied.');
      }
      final exactAlarmAllowed = await androidNotifications
          ?.requestExactAlarmsPermission();
      return exactAlarmAllowed ?? true;
    }

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      final iosNotifications = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final notificationsAllowed = await iosNotifications?.requestPermissions(
        alert: true,
        badge: false,
        sound: true,
      );
      if (notificationsAllowed != true) {
        throw StateError('Notification permission was denied.');
      }
    }
    return false;
  }

  Future<void> _scheduleDailyReminder(
    TimeOfDay time, {
    required bool useExactAlarm,
  }) async {
    if (!_notificationsInitialized) {
      throw StateError('Notifications are not initialized.');
    }

    try {
      final localTimezone = await FlutterTimezone.getLocalTimezone();
      timezone.setLocalLocation(timezone.getLocation(localTimezone.identifier));
    } catch (_) {
      timezone.setLocalLocation(timezone.UTC);
    }

    final now = timezone.TZDateTime.now(timezone.local);
    var scheduledDate = timezone.TZDateTime(
      timezone.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.cancel(id: _reminderNotificationId);
    await _notifications.zonedSchedule(
      id: _reminderNotificationId,
      title: appTextForCode(widget.languageCode, 'تذكيرك اليومي'),
      body: appTextForCode(widget.languageCode, 'حان وقت متابعة عاداتك اليوم.'),
      scheduledDate: scheduledDate,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_habit_reminder',
          appTextForCode(widget.languageCode, 'التذكير اليومي'),
          channelDescription: appTextForCode(
            widget.languageCode,
            'تذكير يومي بمتابعة عاداتك',
          ),
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: useExactAlarm
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _selectReminderTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      helpText: _text('تحديد وقت التذكير اليومي'),
      builder: (context, child) => Directionality(
        textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
    );
    if (selectedTime == null || !mounted) {
      return;
    }

    try {
      final exactAlarmAllowed = await _requestReminderPermissions();
      await _scheduleDailyReminder(
        selectedTime,
        useExactAlarm: exactAlarmAllowed,
      );
      final prefs = await _getPrefs();
      await prefs.setInt('reminder_hour', selectedTime.hour);
      await prefs.setInt('reminder_minute', selectedTime.minute);
      await prefs.setBool('reminder_enabled', true);
      await prefs.setBool('reminder_exact_alarm', exactAlarmAllowed);
      if (!mounted) {
        return;
      }
      setState(() {
        _reminderTime = selectedTime;
        _reminderEnabled = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_text('تم تحديث وقت التذكير بنجاح!')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_text('تعذر جدولة التذكير. تحقق من أذونات الإشعارات.')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  DateTime _startOfWeek(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  bool _shouldResetHabit(Habit habit, DateTime now) {
    if (!habit.completed) {
      return false;
    }
    final lastCompletedDate = habit.lastCompletedDate;
    if (lastCompletedDate == null) {
      return true;
    }

    switch (habit.frequency.toLowerCase()) {
      case 'weekly':
      case 'أسبوعياً':
        return _startOfWeek(now) != _startOfWeek(lastCompletedDate);
      case 'monthly':
      case 'شهرياً':
        return now.year != lastCompletedDate.year ||
            now.month != lastCompletedDate.month;
      case 'daily':
      case 'يومياً':
      default:
        final currentDay = DateTime(now.year, now.month, now.day);
        final completionDay = DateTime(
          lastCompletedDate.year,
          lastCompletedDate.month,
          lastCompletedDate.day,
        );
        final isPreviousCalendarDay = completionDay.isBefore(currentDay);
        return isPreviousCalendarDay ||
            now.difference(lastCompletedDate) > const Duration(hours: 24);
    }
  }

  Future<void> _checkAndResetHabits() async {
    if (_isCheckingResets || _habits.isEmpty) {
      return;
    }
    _isCheckingResets = true;
    try {
      final now = DateTime.now();
      var changed = false;
      for (var index = 0; index < _habits.length; index++) {
        final habit = _habits[index];
        if (_shouldResetHabit(habit, now)) {
          _habits[index] = habit.copyWith(completed: false);
          changed = true;
        }
      }
      if (changed && mounted) {
        setState(() {});
        await _saveHabits();
      }
    } finally {
      _isCheckingResets = false;
    }
  }

  IconData _iconForCategory(String category) => habitIconForCategory(category);

  Color _colorForCategory(String category) => habitColorForCategory(category);

  Future<void> _showUserNameDialog({bool required = false}) async {
    var enteredName = _userName;
    final example = _text('مثال: أحمد / Alex / Jean');
    final newName = await showDialog<String>(
      context: context,
      barrierDismissible: !required,
      builder: (dialogContext) => AlertDialog(
        title: Text(_text(required ? 'مرحباً بك' : 'تعديل الاسم')),
        content: TextFormField(
          initialValue: _userName,
          autofocus: true,
          textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
          textCapitalization: TextCapitalization.words,
          onChanged: (value) => enteredName = value,
          decoration: InputDecoration(
            labelText: _text('اسمك'),
            hintText: example,
            prefixIcon: const Icon(Icons.person_outline_rounded),
          ),
          onFieldSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.pop(dialogContext, value.trim());
            }
          },
        ),
        actions: [
          if (!required)
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(_text('إلغاء')),
            ),
          FilledButton(
            onPressed: () {
              final value = enteredName.trim();
              if (value.isNotEmpty) {
                Navigator.pop(dialogContext, value);
              }
            },
            child: Text(_text('حفظ')),
          ),
        ],
      ),
    );
    if (newName == null || newName.trim().isEmpty || !mounted) {
      return;
    }
    final normalizedName = newName.trim();
    final prefs = await _getPrefs();
    await prefs.setString('user_name', normalizedName);
    if (mounted) {
      setState(() => _userName = normalizedName);
    }
  }

  String _profileText(String key) {
    const labels = <String, List<String>>{
      'profile': [
        'البيانات الشخصية',
        'Personal Profile',
        'Profil personnel',
        'Persönliches Profil',
        'Profilo personale',
        'Perfil personal',
        '个人资料',
      ],
      'security': [
        'الأمان والحماية',
        'Security & Privacy',
        'Sécurité et confidentialité',
        'Sicherheit & Datenschutz',
        'Sicurezza e privacy',
        'Seguridad y privacidad',
        '安全与隐私',
      ],
      'name': ['الاسم', 'Name', 'Nom', 'Name', 'Nome', 'Nombre', '姓名'],
      'email': [
        'البريد الإلكتروني',
        'Email',
        'E-mail',
        'E-Mail',
        'Email',
        'Correo electrónico',
        '电子邮件',
      ],
      'phone': [
        'رقم الهاتف',
        'Phone Number',
        'Téléphone',
        'Telefonnummer',
        'Numero di telefono',
        'Teléfono',
        '电话号码',
      ],
      'contact': [
        'معلومات إضافية',
        'Additional Contact Info',
        'Coordonnées supplémentaires',
        'Weitere Kontaktangaben',
        'Altre informazioni di contatto',
        'Información de contacto adicional',
        '其他联系信息',
      ],
      'save': [
        'حفظ',
        'Save',
        'Enregistrer',
        'Speichern',
        'Salva',
        'Guardar',
        '保存',
      ],
      'cancel': [
        'إلغاء',
        'Cancel',
        'Annuler',
        'Abbrechen',
        'Annulla',
        'Cancelar',
        '取消',
      ],
      'pin': [
        'تعيين رمز PIN / كلمة مرور',
        'Set App PIN / Password',
        'Définir un code PIN / mot de passe',
        'App-PIN / Passwort festlegen',
        'Imposta PIN / password',
        'Establecer PIN / contraseña',
        '设置应用 PIN / 密码',
      ],
      'pinHint': [
        'أدخل رمز PIN أو كلمة المرور',
        'Enter PIN or password',
        'Saisissez un code PIN ou mot de passe',
        'PIN oder Passwort eingeben',
        'Inserisci PIN o password',
        'Introduce PIN o contraseña',
        '输入 PIN 或密码',
      ],
      'pinSet': [
        'تم تعيين رمز التطبيق',
        'App PIN set',
        'Code de l’application défini',
        'App-PIN festgelegt',
        'PIN dell’app impostato',
        'PIN de la app establecido',
        '已设置应用 PIN',
      ],
      'pinRemove': [
        'إزالة رمز PIN',
        'Remove PIN',
        'Supprimer le code PIN',
        'PIN entfernen',
        'Rimuovi PIN',
        'Quitar PIN',
        '移除 PIN',
      ],
      'fingerprint': [
        'استخدام بصمة الإصبع',
        'Fingerprint Authentication',
        'Authentification par empreinte',
        'Fingerabdruck verwenden',
        'Autenticazione con impronta',
        'Autenticación por huella',
        '使用指纹验证',
      ],
      'face': [
        'استخدام بصمة الوجه',
        'Face ID Authentication',
        'Authentification faciale',
        'Gesichtserkennung verwenden',
        'Autenticazione con volto',
        'Autenticación facial',
        '使用面容验证',
      ],
      'emptyPin': [
        'أدخل رمزاً أو كلمة مرور أولاً',
        'Enter a PIN or password first',
        'Saisissez d’abord un code ou mot de passe',
        'Gib zuerst eine PIN oder ein Passwort ein',
        'Inserisci prima un PIN o una password',
        'Introduce primero un PIN o contraseña',
        '请先输入 PIN 或密码',
      ],
    };
    final index = _languageCodes.indexOf(widget.languageCode);
    return labels[key]?[index < 0 ? 1 : index] ?? key;
  }

  Future<void> _showProfileDialog() async {
    final controllers = [
      TextEditingController(text: _userName),
      TextEditingController(text: _userEmail),
      TextEditingController(text: _userPhone),
      TextEditingController(text: _userContactInfo),
    ];
    final values = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_profileText('profile')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < controllers.length; i++) ...[
                if (i > 0) ...[const SizedBox(height: 12)],
                TextField(
                  controller: controllers[i],
                  textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
                  maxLines: i == 3 ? 3 : 1,
                  keyboardType: i == 1
                      ? TextInputType.emailAddress
                      : i == 2
                      ? TextInputType.phone
                      : TextInputType.text,
                  decoration: InputDecoration(
                    labelText: _profileText(
                      ['name', 'email', 'phone', 'contact'][i],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(_profileText('cancel')),
          ),
          FilledButton(
            onPressed: () {
              if (controllers.first.text.trim().isEmpty) {
                return;
              }
              Navigator.pop(
                dialogContext,
                controllers.map((c) => c.text.trim()).toList(),
              );
            },
            child: Text(_profileText('save')),
          ),
        ],
      ),
    );
    if (values == null || !mounted) {
      for (final controller in controllers) {
        controller.dispose();
      }
      return;
    }
    final prefs = await _getPrefs();
    await prefs.setString('user_name', values[0]);
    await prefs.setString('user_email', values[1]);
    await prefs.setString('user_phone', values[2]);
    await prefs.setString('user_contact_info', values[3]);
    for (final controller in controllers) {
      controller.dispose();
    }
    if (mounted) {
      setState(() {
        _userName = values[0];
        _userEmail = values[1];
        _userPhone = values[2];
        _userContactInfo = values[3];
      });
    }
  }

  Future<void> _showSecurityDialog() async {
    final prefs = await _getPrefs();
    if (!mounted) {
      return;
    }
    var pinEnabled = (prefs.getString('app_pin') ?? '').isNotEmpty;
    var fingerprint = prefs.getBool('biometric_fingerprint_enabled') ?? false;
    var faceId = prefs.getBool('biometric_face_enabled') ?? false;
    final pinController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, refresh) => AlertDialog(
          title: Text(_profileText('security')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pinController,
                obscureText: true,
                decoration: InputDecoration(labelText: _profileText('pinHint')),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () async {
                    if (pinController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_profileText('emptyPin'))),
                      );
                      return;
                    }
                    await prefs.setString('app_pin', pinController.text.trim());
                    if (!context.mounted) {
                      return;
                    }
                    pinController.clear();
                    refresh(() => pinEnabled = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_profileText('pinSet'))),
                    );
                  },
                  icon: const Icon(Icons.lock_outline),
                  label: Text(_profileText('pin')),
                ),
              ),
              if (pinEnabled)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () async {
                      await prefs.remove('app_pin');
                      if (!context.mounted) {
                        return;
                      }
                      refresh(() => pinEnabled = false);
                    },
                    icon: const Icon(Icons.lock_open_outlined),
                    label: Text(_profileText('pinRemove')),
                  ),
                ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_profileText('fingerprint')),
                value: fingerprint,
                onChanged: (value) async {
                  await prefs.setBool('biometric_fingerprint_enabled', value);
                  if (!context.mounted) {
                    return;
                  }
                  refresh(() => fingerprint = value);
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_profileText('face')),
                value: faceId,
                onChanged: (value) async {
                  await prefs.setBool('biometric_face_enabled', value);
                  if (!context.mounted) {
                    return;
                  }
                  refresh(() => faceId = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(_profileText('cancel')),
            ),
          ],
        ),
      ),
    );
    pinController.dispose();
  }

  Future<void> _setProMode(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool('is_pro_key', enabled);
    if (mounted) {
      setState(() => _isPro = enabled);
    }
  }

  Future<void> _openPaywall() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) =>
            PaywallPage(isPro: _isPro, onProModeChanged: _setProMode),
      ),
    );
  }

  Future<void> _addNewHabit() async {
    if (!_isPro && _habits.length >= 3) {
      await _openPaywall();
      return;
    }

    final controller = TextEditingController();
    String selectedCategory = _categories.first;
    String selectedFrequency = 'يومياً';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 52,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _text('إضافة عادة جديدة'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF1D2333),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      textDirection: _isRtl
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      decoration: InputDecoration(
                        labelText: _text('اسم العادة'),
                        hintText: _text('مثال: القراءة اليومية'),
                        prefixIcon: const Icon(
                          Icons.check_circle_outline_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _text('الفئة'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: _categories.map((category) {
                        final isSelected = selectedCategory == category;
                        return ChoiceChip(
                          label: Text(_text(category)),
                          selected: isSelected,
                          onSelected: (_) {
                            setSheetState(() => selectedCategory = category);
                          },
                          selectedColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: .16),
                          backgroundColor: const Color(0xFFF3F6FF),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : const Color(0xFF475569),
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _text('التكرار'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: ['يومياً', 'أسبوعياً', 'شهرياً'].map((
                        frequency,
                      ) {
                        final isSelected = selectedFrequency == frequency;
                        return ChoiceChip(
                          label: Text(_text(frequency)),
                          selected: isSelected,
                          onSelected: (_) {
                            setSheetState(() => selectedFrequency = frequency);
                          },
                          selectedColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: .16),
                          backgroundColor: const Color(0xFFF3F6FF),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : const Color(0xFF475569),
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () async {
                        final title = controller.text.trim();
                        if (title.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_text('يرجى إدخال اسم العادة')),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        setState(() {
                          _habits.insert(
                            0,
                            Habit(
                              title: title,
                              category: selectedCategory,
                              icon: _iconForCategory(selectedCategory),
                              streak: 1,
                              color: _colorForCategory(selectedCategory),
                              frequency: selectedFrequency,
                            ),
                          );
                        });
                        await _saveHabits();
                        if (!sheetContext.mounted) {
                          return;
                        }
                        Navigator.pop(sheetContext);
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        backgroundColor: const Color(0xFF3F51B5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        _text('إضافة العادة'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _editHabit(int index) async {
    final habit = _habits[index];
    var editedTitle = habit.title;
    String selectedCategory = habit.category;
    String selectedFrequency = habit.frequency;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 52,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _text('تعديل العادة'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1D2333),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: habit.title,
                    autofocus: true,
                    textDirection: _isRtl
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    onChanged: (value) => editedTitle = value,
                    decoration: InputDecoration(
                      labelText: _text('اسم العادة'),
                      prefixIcon: const Icon(Icons.edit_rounded),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _text('الفئة'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: _categories.map((category) {
                      final isSelected = selectedCategory == category;
                      return ChoiceChip(
                        label: Text(_text(category)),
                        selected: isSelected,
                        onSelected: (_) =>
                            setSheetState(() => selectedCategory = category),
                        selectedColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: .16),
                        backgroundColor: const Color(0xFFF3F6FF),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : const Color(0xFF475569),
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _text('التكرار'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: ['يومياً', 'أسبوعياً', 'شهرياً'].map((frequency) {
                      final isSelected = selectedFrequency == frequency;
                      return ChoiceChip(
                        label: Text(_text(frequency)),
                        selected: isSelected,
                        onSelected: (_) =>
                            setSheetState(() => selectedFrequency = frequency),
                        selectedColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: .16),
                        backgroundColor: const Color(0xFFF3F6FF),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : const Color(0xFF475569),
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () async {
                      final title = editedTitle.trim();
                      if (title.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_text('يرجى إدخال اسم العادة')),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _habits[index] = habit.copyWith(
                          title: title,
                          category: selectedCategory,
                          icon: _iconForCategory(selectedCategory),
                          color: _colorForCategory(selectedCategory),
                          frequency: selectedFrequency,
                        );
                      });
                      await _saveHabits();
                      if (!sheetContext.mounted) {
                        return;
                      }
                      Navigator.pop(sheetContext);
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      backgroundColor: const Color(0xFF17234A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      _text('حفظ التعديلات'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleHabit(int index) async {
    final habit = _habits[index];
    final now = DateTime.now();
    final wasCompleted = habit.completed;
    final dates = habit.completionDates.toList();
    dates.removeWhere((date) => _sameCalendarDay(date, now));
    if (!wasCompleted) {
      dates.add(now);
    }

    setState(() {
      _habits[index] = habit.copyWith(
        completed: !wasCompleted,
        lastCompletedDate: !wasCompleted ? now : habit.lastCompletedDate,
        completionDates: dates,
      );
    });
    await _saveHabits();
  }

  Future<void> _deleteHabit(int index) async {
    setState(() {
      _habits.removeAt(index);
    });
    await _saveHabits();
  }

  double get _completionRate {
    if (_habits.isEmpty) {
      return 0;
    }
    final completedCount = _habits.where((habit) => habit.completed).length;
    return completedCount / _habits.length;
  }

  bool _matchesSelectedCategory(Habit habit) {
    if (_selectedCategory == 'الكل') {
      return true;
    }
    if (_selectedCategory == 'تطوير') {
      return habit.category == 'تطوير' || habit.category == 'قراءة';
    }
    return habit.category == _selectedCategory;
  }

  Widget _buildCategoriesScreen() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _text('إدارة الفئات'),
                    style: const TextStyle(
                      color: Color(0xFF1D2333),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'قم بتنظيم عاداتك في فئات مخصصة لتسهيل المتابعة',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _showCategoryNameDialog(),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      label: Text(
                        _text('إضافة فئة جديدة'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_categories.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _text('أضف فئتك الأولى'),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final category = _categories[index];
                  final isBuiltIn = _defaultCategories.contains(category);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFF0F2F7)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: habitColorForCategory(
                            category,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          habitIconForCategory(category),
                          color: habitColorForCategory(category),
                        ),
                      ),
                      title: Text(
                        _text(category),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: _text('تعديل'),
                            onPressed: () =>
                                _showCategoryNameDialog(category: category),
                            icon: const Icon(
                              Icons.edit_note_rounded,
                              color: Color(0xFF718096),
                            ),
                          ),
                          IconButton(
                            tooltip: _text('حذف'),
                            onPressed: isBuiltIn
                                ? null
                                : () => _deleteCategory(category),
                            icon: Icon(
                              Icons.delete_sweep_outlined,
                              color: isBuiltIn
                                  ? Colors.grey.shade300
                                  : const Color(0xFFE53E3E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: _categories.length),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _drawerSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _navigationItem(
    int index,
    String title,
    IconData icon, {
    bool isCenter = false,
  }) {
    final selected = _selectedTab == index;
    final primary = Theme.of(context).colorScheme.primary;
    final foreground = isCenter
        ? Colors.white
        : selected
        ? primary
        : primary.withValues(alpha: .58);
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
          decoration: BoxDecoration(
            color: isCenter
                ? primary
                : selected
                ? primary.withValues(alpha: 0.09)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 21, color: foreground),
              const SizedBox(height: 3),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foreground,
                  fontSize: 11,
                  fontWeight: isCenter || selected
                      ? FontWeight.w800
                      : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final destinations = _isRtl
        ? [
            (1, 'الإحصائيات', Icons.query_stats_rounded),
            (0, 'العادات', Icons.checklist_rounded),
            (2, 'الفئات', Icons.category_rounded),
          ]
        : [
            (2, 'الفئات', Icons.category_rounded),
            (0, 'العادات', Icons.checklist_rounded),
            (1, 'الإحصائيات', Icons.query_stats_rounded),
          ];
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: const Border(top: BorderSide(color: Color(0xFFE6E9F0))),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            for (final destination in destinations)
              _navigationItem(
                destination.$1,
                _text(destination.$2),
                destination.$3,
                isCenter: destination.$1 == 0,
              ),
          ],
        ),
      ),
    );
  }

  bool _resetCheckScheduled = false;

  @override
  Widget build(BuildContext context) {
    if (!_resetCheckScheduled) {
      _resetCheckScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resetCheckScheduled = false;
        if (mounted) {
          _checkAndResetHabits();
        }
      });
    }
    final completionPercent = (_completionRate * 100).round();
    final visibleHabits = _habits
        .asMap()
        .entries
        .where((entry) => _matchesSelectedCategory(entry.value))
        .toList();
    final filterCategories = ['الكل', ..._categories];

    return Directionality(
      key: const ValueKey('home_directionality'),
      textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        key: _scaffoldKey,

        endDrawer: Drawer(
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _defaultHeaderGradient,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                           Image.asset(
                            'assets/icon/app_icon.png',
                            width: 56,
                            height: 56,
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            'Tasks',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _userEmail,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    children: [
                      _drawerSectionTitle(context, _text('حسابي')),
                      ListTile(
                        leading: const Icon(Icons.person_outline_rounded),
                        title: Text(_profileText('profile')),
                        onTap: () {
                          Navigator.pop(context);
                          _showProfileDialog();
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.workspace_premium_rounded,
                          color: Color(0xFFE4A52B),
                        ),
                        title: Text(_text('تفعيل الترقية')),
                        onTap: () {
                          Navigator.pop(context);
                          _openPaywall();
                        },
                      ),
                      const Divider(height: 32),
                      _drawerSectionTitle(context, _text('العادات')),
                      ListTile(
                        leading: const Icon(Icons.category_outlined),
                        title: Text(_text('إدارة الفئات')),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _selectedTab = 2);
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.notifications_active_outlined,
                        ),
                        title: Text(_text('التذكير اليومي')),
                        subtitle: Text(
                          _reminderEnabled
                              ? MaterialLocalizations.of(
                                  context,
                                ).formatTimeOfDay(_reminderTime)
                              : _text('تحديد وقت التذكير'),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _selectReminderTime();
                        },
                      ),
                      const Divider(height: 32),
                      _drawerSectionTitle(context, _text('الإعدادات')),
                      ListTile(
                        leading: const Icon(Icons.settings_outlined),
                        title: Text(_text('الإعدادات')),
                        onTap: () {
                          Navigator.pop(context);
                          _showSettingsDialog();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.verified_user_outlined),
                        title: Text(_profileText('security')),
                        onTap: () {
                          Navigator.pop(context);
                          _showSecurityDialog();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.language_rounded),
                        title: Text(_text('لغة التطبيق')),
                        trailing: DropdownButton<String>(
                          value: widget.languageCode,
                          underline: const SizedBox.shrink(),
                          items: List.generate(
                            _languageCodes.length,
                            (index) => DropdownMenuItem(
                              value: _languageCodes[index],
                              child: Text(_languageNames[index]),
                            ),
                          ),
                          onChanged: (value) async {
                            if (value != null) {
                              await widget.onLanguageChanged?.call(value);
                            }
                          },
                        ),
                      ),
                      SwitchListTile(
                        secondary: Icon(
                          widget.isDarkMode
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                        ),
                        title: Text(_text('المظهر الداكن')),
                        value: widget.isDarkMode,
                        onChanged: _changeDarkModeFromDrawer,
                      ),
                      const Divider(height: 32),
                      ListTile(
                        leading: const Icon(Icons.help_outline_rounded),
                        title: Text(_text('المساعدة والدعم')),
                        onTap: () {
                          Navigator.pop(context);
                          _showHelpAndSupport();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: IndexedStack(
          index: _selectedTab,
          children: [
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                      child: DashboardHeader(
                        completionPercent: completionPercent,
                        gradientColors: headerGradientForTheme(
                          widget.themeName,
                          Theme.of(context).colorScheme.primary,
                        ),
                        greeting: _text(
                          'مرحباً، {name}',
                          values: {'name': _userName},
                        ),
                        dateText:
                            '${MaterialLocalizations.of(context).formatFullDate(_displayDate)} • ${MaterialLocalizations.of(context).formatTimeOfDay(_displayTime)}',
                        onGreetingTap: _showUserNameDialog,
                        onMenuTap: () =>
                            _scaffoldKey.currentState?.openEndDrawer(),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          onTap: _selectReminderTime,
                          borderRadius: BorderRadius.circular(18),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 13,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE6F8F4),
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_active_outlined,
                                    color: Color(0xFF159B83),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _text('التذكير اليومي'),
                                        style: TextStyle(
                                          color: Color(0xFF202943),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        _reminderEnabled
                                            ? MaterialLocalizations.of(
                                                context,
                                              ).formatTimeOfDay(_reminderTime)
                                            : _text('تحديد وقت التذكير'),
                                        style: const TextStyle(
                                          color: Color(0xFF78819A),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.edit_outlined,
                                  size: 19,
                                  color: Color(0xFF8991A5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _text('عاداتك'),
                              style: TextStyle(
                                color: Color(0xFF19213A),
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _openPaywall,
                            tooltip: _text('تفعيل الترقية'),
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              Icons.workspace_premium_rounded,
                              color: _isPro
                                  ? const Color(0xFFE4A52B)
                                  : const Color(0xFF7B849A),
                            ),
                          ),
                          Text(
                            '${visibleHabits.length} ${_text('عادات')}',
                            style: const TextStyle(
                              color: Color(0xFF78819A),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 48,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: filterCategories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = filterCategories[index];
                          final selected = category == _selectedCategory;
                          return ChoiceChip(
                            label: Text(_text(category)),
                            selected: selected,
                            showCheckmark: false,
                            onSelected: (_) =>
                                setState(() => _selectedCategory = category),
                            backgroundColor: Colors.white,
                            selectedColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            side: BorderSide(
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : const Color(0xFFE4E8F1),
                            ),
                            labelStyle: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF626B83),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  if (_habits.isEmpty)
                    const SliverToBoxAdapter(child: EmptyHabitsView())
                  else if (visibleHabits.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(24, 32, 24, 24),
                        child: Center(
                          child: Text(
                            _text('لا توجد عادات في هذه الفئة'),
                            style: const TextStyle(
                              color: Color(0xFF78819A),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final entry = visibleHabits[index];
                          final habit = entry.value;
                          return Dismissible(
                            key: ValueKey(
                              '${habit.title}_${habit.category}_${entry.key}',
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _deleteHabit(entry.key),
                            background: Container(
                              alignment: Alignment.centerLeft,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.only(left: 24),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE8EA),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: Color(0xFFE64F62),
                              ),
                            ),
                            child: HabitCard(
                              habit: habit,
                              onToggle: () => _toggleHabit(entry.key),
                              onEdit: () => _editHabit(entry.key),
                              onDelete: () => _deleteHabit(entry.key),
                            ),
                          );
                        }, childCount: visibleHabits.length),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
            SafeArea(
              child: HabitAnalyticsScreen(
                habits: _habits,
                completionRate: _completionRate,
                chartStyle: _analyticsDisplayStyle,
                onChartStyleChanged: (style) async {
                  final prefs = await _getPrefs();
                  await prefs.setString('analytics_display_style', style);
                  if (mounted) setState(() => _analyticsDisplayStyle = style);
                },
              ),
            ),
            _buildCategoriesScreen(),
          ],
        ),
        floatingActionButton: _selectedTab == 0
            ? Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: FloatingActionButton.extended(
                  tooltip: _text('إضافة العادة'),
                  onPressed: _addNewHabit,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(_text('إضافة العادة')),
                ),
              )
            : null,
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }
}

class HabitAnalyticsScreen extends StatelessWidget {
  final List<Habit> habits;
  final double completionRate;
  final String chartStyle;
  final Future<void> Function(String style)? onChartStyleChanged;

  const HabitAnalyticsScreen({
    super.key,
    required this.habits,
    required this.completionRate,
    this.chartStyle = 'bar',
    this.onChartStyleChanged,
  });

  List<DateTime> _completionDays() {
    final days = <DateTime>{};
    for (final habit in habits) {
      final dates = habit.completionDates.isNotEmpty
          ? habit.completionDates
          : [if (habit.lastCompletedDate != null) habit.lastCompletedDate!];
      for (final date in dates) {
        days.add(DateTime(date.year, date.month, date.day));
      }
    }
    final result = days.toList()..sort();
    return result;
  }

  int _currentStreak(List<DateTime> days) {
    if (days.isEmpty) {
      return 0;
    }
    final daySet = days.toSet();
    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);
    if (!daySet.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    if (!daySet.contains(cursor)) {
      return 0;
    }

    var streak = 0;
    while (daySet.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int _bestStreak(List<DateTime> days) {
    var best = 0;
    var current = 0;
    DateTime? previous;
    for (final day in days) {
      if (previous != null && day.difference(previous).inDays == 1) {
        current++;
      } else {
        current = 1;
      }
      if (current > best) {
        best = current;
      }
      previous = day;
    }
    return best;
  }

  List<int> _weeklyCounts() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final daysSinceSaturday = (todayDate.weekday + 1) % 7;
    final saturday = todayDate.subtract(Duration(days: daysSinceSaturday));
    final counts = List<int>.filled(7, 0);

    for (final habit in habits) {
      final completedDays = <DateTime>{};
      final dates = habit.completionDates.isNotEmpty
          ? habit.completionDates
          : [if (habit.lastCompletedDate != null) habit.lastCompletedDate!];
      for (final date in dates) {
        completedDays.add(DateTime(date.year, date.month, date.day));
      }
      for (var dayIndex = 0; dayIndex < 7; dayIndex++) {
        final day = saturday.add(Duration(days: dayIndex));
        if (completedDays.contains(day)) {
          counts[dayIndex]++;
        }
      }
    }
    return counts;
  }

  Widget _streakTile(
    BuildContext context,
    String title,
    int days,
    Color accent,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.local_fire_department_rounded, color: accent, size: 23),
            const SizedBox(height: 11),
            Text(
              '$days ${appText(context, 'أيام')}',
              style: const TextStyle(
                color: Color(0xFF202943),
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF78819A),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completionDays = _completionDays();
    final currentStreak = _currentStreak(completionDays);
    final bestStreak = _bestStreak(completionDays);
    final weeklyCounts = _weeklyCounts();
    final weeklyMax = weeklyCounts.fold<int>(
      0,
      (maximum, count) => count > maximum ? count : maximum,
    );
    final percentage = (completionRate * 100).round();
    final badges = [
      ('بطل البداية', bestStreak >= 1, Icons.flag_rounded),
      ('مستمر للأسبوع الأول', bestStreak >= 7, Icons.calendar_month_rounded),
      ('عزيمة فولاذية', bestStreak >= 30, Icons.workspace_premium_rounded),
    ];

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _defaultHeaderGradient,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: _defaultHeaderGradient.first.withValues(
                          alpha: 0.2,
                        ),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.query_stats_rounded,
                        color: Color(0xFF69F0D0),
                        size: 32,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        appText(context, 'الإحصائيات'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        appText(context, 'كل خطوة صغيرة تصنع فرقاً.'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text(
                      'طريقة العرض',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<String>(
                        initialValue: chartStyle,
                        isDense: true,
                        decoration: const InputDecoration(isDense: true),
                        items: const [
                          DropdownMenuItem(value: 'bar', child: Text('أعمدة')),
                          DropdownMenuItem(value: 'pie', child: Text('دائري')),
                          DropdownMenuItem(value: 'line', child: Text('خطي')),
                        ],
                        onChanged: (value) {
                          if (value != null) onChartStyleChanged?.call(value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _streakTile(
                      context,
                      appText(context, 'السلسلة الحالية'),
                      currentStreak,
                      const Color(0xFFFF874F),
                    ),
                    const SizedBox(width: 12),
                    _streakTile(
                      context,
                      appText(context, 'أفضل سلسلة'),
                      bestStreak,
                      const Color(0xFF6A54D8),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E8F0)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 88,
                        height: 88,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: completionRate,
                              strokeWidth: 8,
                              backgroundColor: const Color(0xFFE9EDF4),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF16BFAE),
                              ),
                            ),
                            Text(
                              '$percentage%',
                              style: const TextStyle(
                                color: Color(0xFF202943),
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appText(context, 'نسبة الالتزام'),
                              style: TextStyle(
                                color: Color(0xFF202943),
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              appText(context, 'من عاداتك المجدولة اليوم'),
                              style: TextStyle(
                                color: Color(0xFF78819A),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  appText(context, 'إنجازات الأسبوع'),
                  style: TextStyle(
                    color: Color(0xFF202943),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 240,
                  padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E8F0)),
                  ),
                  child: chartStyle == 'pie'
                      ? PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 34,
                            sections: List.generate(
                              7,
                              (index) => PieChartSectionData(
                                value: weeklyCounts[index].toDouble(),
                                title: weeklyCounts[index] == 0
                                    ? ''
                                    : weeklyCounts[index].toString(),
                                radius: 48,
                                color: [
                                  const Color(0xFF6752D5),
                                  const Color(0xFF21D2B4),
                                  const Color(0xFFFF874F),
                                  const Color(0xFF4D8CF7),
                                  const Color(0xFFE35D8E),
                                  const Color(0xFFB384F5),
                                  const Color(0xFFF2BF4A),
                                ][index],
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        )
                      : chartStyle == 'line'
                      ? LineChart(
                          LineChartData(
                            minY: 0,
                            maxY: (weeklyMax < 4 ? 4 : weeklyMax + 1)
                                .toDouble(),
                            gridData: const FlGridData(
                              show: true,
                              drawVerticalLine: false,
                            ),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: List.generate(
                                  7,
                                  (index) => FlSpot(
                                    index.toDouble(),
                                    weeklyCounts[index].toDouble(),
                                  ),
                                ),
                                isCurved: true,
                                color: const Color(0xFF6752D5),
                                barWidth: 4,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: const Color(
                                    0xFF21D2B4,
                                  ).withValues(alpha: 0.2),
                                ),
                              ),
                            ],
                          ),
                        )
                      : BarChart(
                          BarChartData(
                            minY: 0,
                            maxY: (weeklyMax < 4 ? 4 : weeklyMax + 1)
                                .toDouble(),
                            barGroups: List.generate(
                              7,
                              (index) => BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: weeklyCounts[index].toDouble(),
                                    width: 18,
                                    borderRadius: BorderRadius.circular(6),
                                    gradient: const LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Color(0xFF6752D5),
                                        Color(0xFF21D2B4),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 1,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: const Color(0xFFE9ECF3),
                                strokeWidth: 1,
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 26,
                                  interval: 1,
                                  getTitlesWidget:
                                      (double value, TitleMeta meta) => Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(
                                          color: Color(0xFF8991A5),
                                          fontSize: 10,
                                        ),
                                      ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  getTitlesWidget:
                                      (double value, TitleMeta meta) {
                                        final labels = [
                                          'السبت',
                                          'الأحد',
                                          'الإثنين',
                                          'الثلاثاء',
                                          'الأربعاء',
                                          'الخميس',
                                          'الجمعة',
                                        ];
                                        final index = value.toInt();
                                        if (index < 0 ||
                                            index >= labels.length) {
                                          return const SizedBox.shrink();
                                        }
                                        return SideTitleWidget(
                                          meta: meta,
                                          space: 8,
                                          child: Text(
                                            appText(context, labels[index]),
                                            style: const TextStyle(
                                              color: Color(0xFF78819A),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        );
                                      },
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                Text(
                  appText(context, 'الشارات'),
                  style: TextStyle(
                    color: Color(0xFF202943),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                for (final badge in badges)
                  Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: badge.$2 ? const Color(0xFFF0FCF9) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: badge.$2
                            ? const Color(0xFF9DE5D8)
                            : const Color(0xFFE5E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          badge.$3,
                          color: badge.$2
                              ? const Color(0xFF18A98F)
                              : const Color(0xFFA9B0C0),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            appText(context, badge.$1),
                            style: TextStyle(
                              color: badge.$2
                                  ? const Color(0xFF202943)
                                  : const Color(0xFF8991A5),
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Icon(
                          badge.$2
                              ? Icons.check_circle_rounded
                              : Icons.lock_outline_rounded,
                          color: badge.$2
                              ? const Color(0xFF18A98F)
                              : const Color(0xFFA9B0C0),
                          size: 19,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

bool _sameCalendarDay(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;

class PaywallPage extends StatefulWidget {
  final bool isPro;
  final Future<void> Function(bool enabled) onProModeChanged;

  const PaywallPage({
    super.key,
    required this.isPro,
    required this.onProModeChanged,
  });

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  bool _annualPlanSelected = true;
  bool _isUpdatingPro = false;
  late bool _isProEnabled;

  @override
  void initState() {
    super.initState();
    _isProEnabled = widget.isPro;
  }

  Future<void> _updateProMode(bool enabled) async {
    setState(() => _isUpdatingPro = true);
    await widget.onProModeChanged(enabled);
    if (mounted) {
      setState(() {
        _isProEnabled = enabled;
        _isUpdatingPro = false;
      });
    }
  }

  Widget _benefit(BuildContext context, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF19A98F), size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              appText(context, label),
              style: const TextStyle(
                color: Color(0xFF27304A),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _planCard(
    BuildContext context, {
    required bool selected,
    required String title,
    required String price,
    required String period,
    String? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0FDF9) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFF18B69A) : const Color(0xFFE3E7EF),
            width: selected ? 1.7 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected
                  ? const Color(0xFF16A98F)
                  : const Color(0xFFA2A8B8),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          appText(context, title),
                          style: const TextStyle(
                            color: Color(0xFF202943),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 7),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0D5),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              appText(context, badge),
                              style: const TextStyle(
                                color: Color(0xFF9B6715),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appText(context, period),
                    style: const TextStyle(
                      color: Color(0xFF81899D),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                price,
                style: const TextStyle(
                  color: Color(0xFF202943),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String text(String key) => appText(context, key);
    return Directionality(
      textDirection: Localizations.localeOf(context).languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    tooltip: text('إغلاق'),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF68718A),
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _defaultHeaderGradient,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: _defaultHeaderGradient.first.withValues(
                          alpha: 0.25,
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: Color(0xFFFFD36E),
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        text('الترقية إلى Habit Tracker Pro'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        text('مساحة أكبر لعاداتك، وتركيز أعمق على تقدمك.'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  text('مزايا Pro'),
                  style: TextStyle(
                    color: Color(0xFF202943),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                _benefit(
                  context,
                  'عادات غير محدودة',
                  Icons.all_inclusive_rounded,
                ),
                _benefit(context, 'إحصائيات متقدمة', Icons.insights_rounded),
                _benefit(context, 'دعم الفئات المخصصة', Icons.category_rounded),
                _benefit(context, 'بدون إعلانات', Icons.block_rounded),
                const SizedBox(height: 16),
                _planCard(
                  context,
                  selected: !_annualPlanSelected,
                  title: 'اشتراك شهري',
                  price: '\$2.99',
                  period: 'لكل شهر',
                  onTap: () => setState(() => _annualPlanSelected = false),
                ),
                const SizedBox(height: 10),
                _planCard(
                  context,
                  selected: _annualPlanSelected,
                  title: 'اشتراك سنوي',
                  price: '\$19.99',
                  period: 'لكل سنة',
                  badge: 'خصم 40%',
                  onTap: () => setState(() => _annualPlanSelected = true),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE7EAF1)),
                  ),
                  child: SwitchListTile.adaptive(
                    value: _isProEnabled,
                    onChanged: _isUpdatingPro ? null : _updateProMode,
                    activeTrackColor: const Color(0xFF18B69A),
                    title: Text(
                      text('تفعيل Pro للتجربة'),
                      style: TextStyle(
                        color: Color(0xFF27304A),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: Text(
                      text('وضع تجريبي محفوظ على هذا الجهاز'),
                      style: TextStyle(color: Color(0xFF81899D), fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: _isUpdatingPro
                      ? null
                      : () async {
                          if (!_isProEnabled) {
                            await _updateProMode(true);
                          }
                          if (!context.mounted) {
                            return;
                          }
                          Navigator.pop(context);
                        },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: const Color(0xFF17234A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: Text(
                    text(_isProEnabled ? 'تم تفعيل Pro' : 'اشترك الآن'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    text('تخطي / إغلاق'),
                    style: TextStyle(
                      color: Color(0xFF737C91),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardHeader extends StatelessWidget {
  final String greeting;
  final String dateText;
  final int completionPercent;
  final List<Color> gradientColors;
  final VoidCallback onGreetingTap;
  final VoidCallback onMenuTap;

  const DashboardHeader({
    super.key,
    required this.greeting,
    required this.dateText,
    required this.completionPercent,
    required this.gradientColors,
    required this.onGreetingTap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        appText(context, 'إنجاز اليوم'),
                        style: TextStyle(
                          color: Color(0xFFD6FFF8),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onMenuTap,
                      tooltip: appText(context, 'فتح القائمة'),
                      visualDensity: VisualDensity.compact,
                      color: Colors.white,
                      icon: const Icon(Icons.menu_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: onGreetingTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      greeting,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dateText,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 92,
            height: 92,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 84,
                  height: 84,
                  child: CircularProgressIndicator(
                    value: completionPercent / 100,
                    strokeWidth: 7,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF69F0D0),
                    ),
                  ),
                ),
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10193C).withValues(alpha: 0.76),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$completionPercent%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: habit.completed
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: habit.completed
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outlineVariant,
          width: habit.completed ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D2850).withValues(alpha: 0.045),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: habit.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(habit.icon, color: habit.color, size: 27),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1D2540),
                    decoration: habit.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: habit.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        appText(context, habit.category),
                        style: TextStyle(
                          color: habit.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2E8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: Color(0xFFF28B45),
                            size: 14,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${habit.streak} ${appText(context, 'أيام')}',
                            style: const TextStyle(
                              color: Color(0xFFB85D27),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F2F7),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        appText(context, habit.frequency),
                        style: const TextStyle(
                          color: Color(0xFF68718A),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              AnimatedCheckboxButton(value: habit.completed, onTap: onToggle),
              SizedBox(
                height: 32,
                child: PopupMenuButton<String>(
                  tooltip: appText(context, 'خيارات العادة'),
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    color: Color(0xFF8991A5),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    }
                    if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, color: Color(0xFF5968B5)),
                          SizedBox(width: 10),
                          Text(appText(context, 'تعديل العادة')),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFFE64F62),
                          ),
                          SizedBox(width: 10),
                          Text(appText(context, 'حذف العادة')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AnimatedCheckboxButton extends StatefulWidget {
  final bool value;
  final VoidCallback onTap;

  const AnimatedCheckboxButton({
    super.key,
    required this.value,
    required this.onTap,
  });

  @override
  State<AnimatedCheckboxButton> createState() => _AnimatedCheckboxButtonState();
}

class _AnimatedCheckboxButtonState extends State<AnimatedCheckboxButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.value ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedCheckboxButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 0.9 + (_controller.value * 0.1);
          final color = Color.lerp(
            const Color(0xFFE7EBFF),
            const Color(0xFF5CC8C0),
            _controller.value,
          )!;

          return Transform.scale(
            scale: scale,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5CC8C0).withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                widget.value ? Icons.check_rounded : Icons.circle_outlined,
                color: widget.value ? Colors.white : const Color(0xFF6A79A8),
                size: 26,
              ),
            ),
          );
        },
      ),
    );
  }
}

class EmptyHabitsView extends StatelessWidget {
  const EmptyHabitsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
      child: Column(
        children: [
          Container(
            width: 220,
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FF),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 30,
                  right: 26,
                  child: Container(
                    width: 58,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB8C6FF),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
                Positioned(
                  top: 35,
                  left: 32,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4C78FF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 26,
                  left: 42,
                  child: Container(
                    width: 110,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 52,
                  child: Container(
                    width: 92,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDEEBFF),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 34,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5CC8C0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            appText(context, 'لا توجد عادات حتى الآن'),
            style: GoogleFonts.cairo(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1D2333),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            appText(context, 'ابدأ بتسجيل عادة جديدة وراقب تقدمك يوميًا'),
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: const Color(0xFF66708A),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

IconData habitIconForCategory(String category) {
  switch (category) {
    case 'صحة':
      return Icons.favorite_rounded;
    case 'رياضة':
      return Icons.fitness_center_rounded;
    case 'عبادات':
      return Icons.mosque_rounded;
    case 'تطوير':
      return Icons.auto_awesome_rounded;
    case 'قراءة':
      return Icons.menu_book_rounded;
    case 'عمل':
      return Icons.work_rounded;
    default:
      return Icons.star_rounded;
  }
}

Color habitColorForCategory(String category) {
  switch (category) {
    case 'صحة':
      return const Color(0xFF5CC8C0);
    case 'رياضة':
      return const Color(0xFF6C8CFF);
    case 'عبادات':
      return const Color(0xFF3DAA83);
    case 'تطوير':
      return const Color(0xFFB38BFF);
    case 'قراءة':
      return const Color(0xFFB38BFF);
    case 'عمل':
      return const Color(0xFFFFB86C);
    default:
      return const Color(0xFF5CC8C0);
  }
}

class Habit {
  final String title;
  final String category;
  final IconData icon;
  final int streak;
  final Color color;
  final bool completed;
  final String frequency;
  final DateTime? lastCompletedDate;
  final List<DateTime> completionDates;

  Habit({
    required this.title,
    required this.category,
    required this.icon,
    required this.streak,
    required this.color,
    this.completed = false,
    this.frequency = 'يومياً',
    this.lastCompletedDate,
    this.completionDates = const [],
  });

  static Habit? fromJson(Map<String, dynamic> map) {
    try {
      final category = map['category'] as String? ?? 'صحة';
      final storedFrequency = map['frequency'] as String? ?? 'يومياً';
      final frequency = switch (storedFrequency.toLowerCase()) {
        'weekly' || 'أسبوعياً' => 'أسبوعياً',
        'monthly' || 'شهرياً' => 'شهرياً',
        _ => 'يومياً',
      };
      final storedLastCompletedDate = map['lastCompletedDate'] as String?;
      final storedCompletionDates =
          map['completionDates'] as List<dynamic>? ?? [];
      return Habit(
        title: map['title'] as String? ?? '',
        category: category,
        icon: habitIconForCategory(category),
        streak: map['streak'] as int? ?? 1,
        color: habitColorForCategory(category),
        completed: map['completed'] as bool? ?? false,
        frequency: frequency,
        lastCompletedDate: storedLastCompletedDate == null
            ? null
            : DateTime.tryParse(storedLastCompletedDate),
        completionDates: storedCompletionDates
            .whereType<String>()
            .map(DateTime.tryParse)
            .whereType<DateTime>()
            .toList(),
      );
    } catch (_) {
      return null;
    }
  }

  static Habit? fromJsonMap(Map<String, dynamic> map) => fromJson(map);

  Map<String, dynamic> toJson() => {
    'title': title,
    'category': category,
    'streak': streak,
    'completed': completed,
    'frequency': frequency,
    'lastCompletedDate': lastCompletedDate?.toIso8601String(),
    'completionDates': completionDates
        .map((date) => date.toIso8601String())
        .toList(),
  };

  Map<String, dynamic> toJsonMap() => toJson();

  Habit copyWith({
    String? title,
    String? category,
    IconData? icon,
    int? streak,
    Color? color,
    bool? completed,
    String? frequency,
    DateTime? lastCompletedDate,
    List<DateTime>? completionDates,
  }) {
    return Habit(
      title: title ?? this.title,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      streak: streak ?? this.streak,
      color: color ?? this.color,
      completed: completed ?? this.completed,
      frequency: frequency ?? this.frequency,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      completionDates: completionDates ?? this.completionDates,
    );
  }
}
