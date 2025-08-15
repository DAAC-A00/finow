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
            _buildBasicInfo(colorScheme),
            SizedBox(height: 24.0),
            if (ticker.priceData != null) ...[
              _buildPriceDataSection(colorScheme),
              SizedBox(height: 24.0),
            ],
            _buildInstrumentInfoSection(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      color: colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticker.symbol,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (ticker.koreanName != null)
                        Text(
                          ticker.koreanName!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface.withAlpha((255 * 0.7).round()),
                          ),
                        ),
                      if (ticker.englishName != null)
                        Text(
                          ticker.englishName!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withAlpha((255 * 0.6).round()),
                          ),
                        ),
                    ],
                  ),
                ),
                _buildCategoryBadge(ticker.category, colorScheme),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                _buildInfoChip('${ticker.baseCoin}/${ticker.quoteCoin}', colorScheme),
                SizedBox(width: 8.0),
                _buildStatusChip(ticker.status, colorScheme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo(ColorScheme colorScheme) {
    final priceData = ticker.priceData;
    final priceDirection = ticker.priceDirection;
    
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
            _buildInfoRow('기초 코인', ticker.baseCoin, colorScheme),
            _buildInfoRow('견적 코인', ticker.quoteCoin, colorScheme),
            _buildInfoRow('상태', ticker.status, colorScheme),
            if (ticker.koreanName != null)
              _buildInfoRow('한국어 이름', ticker.koreanName!, colorScheme),
            if (ticker.englishName != null)
              _buildInfoRow('영어 이름', ticker.englishName!, colorScheme),
            if (ticker.marketWarning != null)
              _buildInfoRow('시장 경고', ticker.marketWarning!, colorScheme),
            if (priceData != null) ...[
              Divider(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '현재 가격',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        priceData.lastPrice ?? '-',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _getPriceColor(priceDirection, colorScheme),
                        ),
                      ),
                      if (priceData.price24hPcnt != null)
                        Text(
                          '${priceData.price24hPcnt}%',
                          style: TextStyle(
                            fontSize: 14,
                            color: _getPriceColor(priceDirection, colorScheme),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
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
            if (priceData.bid1Price != null && priceData.ask1Price != null) ...[
              Divider(height: 24.0),
              _buildInfoRow('매수 호가', priceData.bid1Price!, colorScheme),
              _buildInfoRow('매도 호가', priceData.ask1Price!, colorScheme),
            ],
            if (priceData.indexPrice != null)
              _buildInfoRow('지수 가격', priceData.indexPrice!, colorScheme),
            if (priceData.markPrice != null)
              _buildInfoRow('마크 가격', priceData.markPrice!, colorScheme),
            if (priceData.fundingRate != null)
              _buildInfoRow('펀딩 비율', priceData.fundingRate!, colorScheme),
            if (priceData.openInterest != null)
              _buildInfoRow('미결제약정', priceData.openInterest!, colorScheme),
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
                  Icons.settings_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 8.0),
                Text(
                  '상품 정보',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            if (ticker.contractType != null)
              _buildInfoRow('계약 타입', ticker.contractType!, colorScheme),
            if (ticker.marginTrading != null)
              _buildInfoRow('마진 거래', ticker.marginTrading!, colorScheme),
            if (ticker.innovation != null && ticker.innovation != '0')
              _buildInfoRow('혁신존', ticker.innovation!, colorScheme),
            if (ticker.unifiedMarginTrade != null)
              _buildInfoRow('통합 마진 거래', ticker.unifiedMarginTrade.toString(), colorScheme),
            if (ticker.fundingInterval != null)
              _buildInfoRow('펀딩 간격', '${ticker.fundingInterval}분', colorScheme),
            if (ticker.settleCoin != null)
              _buildInfoRow('정산 코인', ticker.settleCoin!, colorScheme),
            if (ticker.copyTrading != null)
              _buildInfoRow('카피 트레이딩', ticker.copyTrading!, colorScheme),
            _buildInfoRow('마지막 업데이트', 
              '${ticker.lastUpdated.hour.toString().padLeft(2, '0')}:${ticker.lastUpdated.minute.toString().padLeft(2, '0')}:${ticker.lastUpdated.second.toString().padLeft(2, '0')}', 
              colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceFilterCard(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      color: colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '가격 필터',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12.0),
            Text(
              '가격 필터 정보는 현재 사용할 수 없습니다.',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLotSizeFilterCard(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      color: colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '로트 크기 필터',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12.0),
            Text(
              '로트 크기 필터 정보는 현재 사용할 수 없습니다.',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeverageFilterCard(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      color: colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '레버리지 필터',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12.0),
            Text(
              '레버리지 필터 정보는 현재 사용할 수 없습니다.',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskParametersCard(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      color: colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '리스크 매개변수',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12.0),
            Text(
              '리스크 매개변수 정보는 현재 사용할 수 없습니다.',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoCard(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      color: colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '추가 정보',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 16.0),
            if (ticker.marketWarning != null && ticker.marketWarning != 'NONE')
              _buildWarningRow('시장 경고', ticker.marketWarning!, colorScheme),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: colorScheme.onSurface.withAlpha((255 * 0.6).round()),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    'Ticker 정보는 Bybit API에서 실시간으로 가져온 데이터입니다.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withAlpha((255 * 0.6).round()),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String category, ColorScheme colorScheme) {
    Color color;
    switch (category.toLowerCase()) {
      case 'spot':
        color = Colors.green;
        break;
      case 'linear':
        color = Colors.blue;
        break;
      case 'inverse':
        color = Colors.purple;
        break;
      default:
        color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha((255 * 0.3).round())),
      ),
      child: Text(
        category.toUpperCase(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withAlpha((255 * 0.3).round()),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurface.withAlpha((255 * 0.8).round()),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ColorScheme colorScheme) {
    final color = status == 'Trading' ? Colors.green : Colors.grey;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
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
                color: colorScheme.onSurface.withAlpha((255 * 0.6).round()),
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

  Widget _buildWarningRow(String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber,
            size: 16,
            color: Colors.red,
          ),
          SizedBox(width: 4.0),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _copySymbol(BuildContext context) {
    Clipboard.setData(ClipboardData(text: ticker.symbol));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Symbol "${ticker.symbol}" copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copySymbolToClipboard(String symbol, BuildContext context) {
    Clipboard.setData(ClipboardData(text: symbol));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$symbol 복사됨')),
    );
  }

  Color _getPriceColor(PriceDirection direction, ColorScheme colorScheme) {
    switch (direction) {
      case PriceDirection.up:
        return Colors.green;
      case PriceDirection.down:
        return Colors.red;
      case PriceDirection.neutral:
        return colorScheme.onSurface;
    }
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
