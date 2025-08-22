import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ticker_price_data.dart';


/// 실시간 Ticker 상세 정보 화면
class TickerDetailsScreen extends StatelessWidget {
  final IntegratedTickerPriceData ticker;

  const TickerDetailsScreen({
    super.key,
    required this.ticker,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(ticker.symbol),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copySymbolToClipboard(ticker.symbol, context),
            tooltip: 'Copy Symbol',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoSection(colorScheme),
            const SizedBox(height: 16.0),
            if (ticker.priceData != null) _buildPriceDataSection(colorScheme),
            const SizedBox(height: 16.0),
            _buildInstrumentInfoSection(colorScheme),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 8.0),
                Text(
                  '기본 정보',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            _buildInfoRow('심볼', ticker.symbol, colorScheme),
            _buildInfoRow('카테고리', ticker.category.toUpperCase(), colorScheme),
            if (ticker.quantity != null)
              _buildInfoRow('수량', ticker.quantity.toString(), colorScheme),
            _buildInfoRow('기초 코드', ticker.baseCode, colorScheme),
            _buildInfoRow('견적 코드', ticker.quoteCode, colorScheme),
            _buildInfoRow('상태', ticker.status, colorScheme),
            if (ticker.koreanName != null)
              _buildInfoRow('한국어 이름', ticker.koreanName!, colorScheme),
            if (ticker.englishName != null)
              _buildInfoRow('영어 이름', ticker.englishName!, colorScheme),
            if (ticker.marketWarning != null)
              _buildInfoRow('시장 경고', ticker.marketWarning!, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDataSection(ColorScheme colorScheme) {
    final priceData = ticker.priceData!;
    
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 8.0),
                Text(
                  '실시간 가격 정보',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            if (priceData.lastPrice != null)
              _buildInfoRow('현재 가격', priceData.lastPrice!, colorScheme),
            if (priceData.prevPrice24h != null)
              _buildInfoRow('24시간 전 가격', priceData.prevPrice24h!, colorScheme),
            if (priceData.price24hPcnt != null)
              _buildInfoRow('24시간 변화율', '${priceData.price24hPcnt}%', colorScheme),
            if (priceData.highPrice24h != null)
              _buildInfoRow('24시간 최고가', priceData.highPrice24h!, colorScheme),
            if (priceData.lowPrice24h != null)
              _buildInfoRow('24시간 최저가', priceData.lowPrice24h!, colorScheme),
            if (priceData.volume24h != null)
              _buildInfoRow('24시간 거래량', _formatVolume(priceData.volume24h!), colorScheme),
            if (priceData.turnover24h != null)
              _buildInfoRow('24시간 거래대금', _formatVolume(priceData.turnover24h!), colorScheme),
            if (priceData.openInterest != null)
              _buildInfoRow('미결제약정', _formatVolume(priceData.openInterest!), colorScheme),
            if (priceData.openInterestValue != null)
              _buildInfoRow('미결제약정 가치', _formatVolume(priceData.openInterestValue!), colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildInstrumentInfoSection(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 8.0),
                Text(
                  'Instrument 정보',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            _buildInfoRow('거래소', ticker.exchange, colorScheme),
            _buildInfoRow('마지막 업데이트', 
              '${ticker.lastUpdated.hour.toString().padLeft(2, '0')}:${ticker.lastUpdated.minute.toString().padLeft(2, '0')}:${ticker.lastUpdated.second.toString().padLeft(2, '0')}', 
              colorScheme),
            if (ticker.endDate != null)
              _buildInfoRow('종료일', ticker.endDate!, colorScheme),
            if (ticker.settleCoin != null)
              _buildInfoRow('정산 코인', ticker.settleCoin!, colorScheme),
            if (ticker.launchTime != null)
              _buildInfoRow('런칭 시간', ticker.launchTime!, colorScheme),
          ],
        ),
      ),
    );
  }

  

  

  

  

  

  

  

  

  Widget _buildInfoRow(String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withAlpha(153),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  

  

  

  void _copySymbolToClipboard(String symbol, BuildContext context) {
    Clipboard.setData(ClipboardData(text: symbol));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$symbol 복사됨')),
    );
  }

  

  String _formatVolume(String volume) {
    final value = double.tryParse(volume);
    if (value == null) return volume;
    
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(2)}B';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(2)}K';
    }
    return value.toStringAsFixed(2);
  }

  
}
