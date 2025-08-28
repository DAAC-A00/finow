import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:finow/features/exchange_rate/exchange_rate_update_service.dart';
import 'package:finow/features/exchange_rate/exconvert_periodic_update_service.dart';
import 'package:finow/features/instruments/services/instruments_sync_service.dart';
import 'package:finow/features/instruments/models/instrument.dart';
import 'package:finow/features/settings/models/api_key_data.dart';
import 'package:finow/features/settings/api_key_status.dart';
import 'package:finow/routing/app_router.dart';
import 'package:finow/theme_provider.dart';
import 'package:finow/font_size_provider.dart';
import 'package:finow/ui_scale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // 앱 시작 전 초기화
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Hive 어댑터 등록
  Hive.registerAdapter(ExchangeRateAdapter());
  Hive.registerAdapter(InstrumentAdapter());
  
  // ticker 데이터는 실시간으로만 사용하므로 Hive 어댑터 불필요
  Hive.registerAdapter(ApiKeyDataAdapter());
  Hive.registerAdapter(ApiKeyStatusAdapter());

  // 사용할 Box들 미리 열기
  await Hive.openBox('settings');
  await Hive.openBox<ExchangeRate>('exchangeRates');
  await Hive.openBox<Instrument>('instruments');
  // ticker 데이터는 실시간으로만 사용하므로 로컬 저장 박스 불필요
  await Hive.openBox<ApiKeyData>('api_keys');

  runApp(const ProviderScope(child: _AppInitializer()));
}

class _AppInitializer extends ConsumerStatefulWidget {
  const _AppInitializer();

  @override
  ConsumerState<_AppInitializer> createState() => __AppInitializerState();
}

class __AppInitializerState extends ConsumerState<_AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  Future<void> _initializeProviders() async {
    // 1. v6 API를 통해 부족한 환율 정보를 한 번 가져옴
    await ref.read(exchangeRateUpdateServiceProvider).updateRatesAndValidateKeys();

    // 2. ExConvert API를 통해 1분마다 주기적으로 환율 정보 업데이트 시작
    ref.read(exConvertPeriodicUpdateServiceProvider).startPeriodicUpdates();
    
    // 3. 통합 심볼 정보 초기 동기화 및 Bithumb 경고 정보 주기적 업데이트 시작
    await ref.read(instrumentsSyncServiceProvider).performInitialSync();
  }

  @override
  Widget build(BuildContext context) {
    return const MyApp();
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeNotifierProvider);
    final fontSizeOption = ref.watch(fontSizeNotifierProvider);
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Finow',
      theme: AppTheme.getLightTheme(fontSizeOption.scale),
      darkTheme: AppTheme.getDarkTheme(fontSizeOption.scale),
      themeMode: themeMode,
      routerConfig: goRouter,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(fontSizeOption.scale),
          ),
          child: UIScaleProvider(
            scale: fontSizeOption.scale,
            child: child!,
          ),
        );
      },
    );
  }
}
