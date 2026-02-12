import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'models.dart';
import 'tax_calculator.dart';

class ReportPdfService {
  static Future<void> downloadCapturedReport({
    required Uint8List imageBytes,
    required double logicalWidth,
    required double logicalHeight,
  }) async {
    final safeWidth = logicalWidth <= 0 ? 1.0 : logicalWidth;
    final safeHeight = logicalHeight <= 0 ? 1.0 : logicalHeight;
    const margin = 16.0;
    final pageWidth = PdfPageFormat.a4.width;
    final contentWidth = pageWidth - (margin * 2);
    final contentHeight = contentWidth * (safeHeight / safeWidth);
    final pageFormat = PdfPageFormat(pageWidth, contentHeight + (margin * 2));

    final document = pw.Document();
    final image = pw.MemoryImage(imageBytes);
    document.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(margin),
        build: (pw.Context context) {
          return pw.Image(
            image,
            fit: pw.BoxFit.fill,
            width: contentWidth,
            height: contentHeight,
          );
        },
      ),
    );

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    await Printing.sharePdf(
      bytes: await document.save(),
      filename: 'savvy_report_design_$timestamp.pdf',
    );
  }

  static Future<void> downloadReport({
    required UserProfile profile,
    required TaxDeductionData taxData,
    required TaxCalculationResult result,
  }) async {
    final bytes = await buildReportPdf(
      profile: profile,
      taxData: taxData,
      result: result,
    );
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'savvy_tax_report_$timestamp.pdf',
    );
  }

  static Future<Uint8List> buildReportPdf({
    required UserProfile profile,
    required TaxDeductionData taxData,
    required TaxCalculationResult result,
  }) async {
    final document = pw.Document();
    final number = NumberFormat.decimalPattern('en_US');
    final generatedAt = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    final effectiveAnnualIncome = TaxCalculator.totalAnnualIncome(profile);
    final finalSettlementTax = result.finalTax - result.prepaidTax;
    final theme = await _buildKoreanTheme();
    final summaryLabel =
        result.refundAmount >= 0
            ? '예상 환급액'
            : '예상 추가 납부액';

    String formatMoney(double amount) {
      final sign = amount < 0 ? '-' : '';
      return '$sign${number.format(amount.abs().round())}원';
    }

    final deductionRows = <_ReportRow>[
      _ReportRow(
        name: '신용/체크카드',
        amount:
            taxData.cardUsage.creditCard +
            taxData.cardUsage.debitCard +
            taxData.cardUsage.cashReceipt,
        deduction: result.taxDeductions.cardUsage,
      ),
      _ReportRow(
        name: '주택청약/월세',
        amount:
            taxData.housing.housingSubscription + taxData.housing.monthlyRent,
        deduction: result.taxDeductions.housingSubscription,
      ),
    ];

    final taxCreditRows = <_ReportRow>[
      _ReportRow(
        name: '연금저축/IRP',
        amount: taxData.pension.pensionSavings + taxData.pension.irp,
        deduction: result.taxDeductions.pension,
      ),
      _ReportRow(
        name: '기부금',
        amount:
            taxData.donations.religious +
            taxData.donations.political +
            taxData.donations.general,
        deduction: result.taxDeductions.religiousDonation,
      ),
      _ReportRow(
        name: '의료비/교육비',
        amount:
            taxData.medicalEducation.medical +
            taxData.medicalEducation.education,
        deduction: result.taxDeductions.medicalEducationTaxCredit,
      ),
    ];

    final taxReductionRows = <_ReportRow>[
      if (result.smeReduction > 0)
        _ReportRow(
          name: '중소기업 청년 감면',
          amount: 0,
          deduction: result.smeReduction,
        ),
    ];

    document.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build:
            (pw.Context context) => <pw.Widget>[
              pw.Text(
                'Savvy 연말정산 리포트',
                style: pw.TextStyle(
                  fontSize: 21,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text('생성일: $generatedAt'),
              pw.SizedBox(height: 14),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Text(
                      summaryLabel,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      formatMoney(result.refundAmount),
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),
              _buildSection(
                title: '소득공제 상세',
                rows: deductionRows,
                formatMoney: formatMoney,
              ),
              pw.SizedBox(height: 10),
              _buildSection(
                title: '세액공제 상세',
                rows: taxCreditRows,
                formatMoney: formatMoney,
              ),
              if (taxReductionRows.isNotEmpty) ...<pw.Widget>[
                pw.SizedBox(height: 10),
                _buildSection(
                  title: '세액감면 상세',
                  rows: taxReductionRows,
                  formatMoney: formatMoney,
                ),
              ],
              pw.SizedBox(height: 12),
              pw.Text(
                '세금 계산 과정',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              _calcLine(
                profile.isFirstJobThisYear
                    ? '총급여'
                    : '총급여(현+전 직장 합산)',
                effectiveAnnualIncome,
                formatMoney,
              ),
              _calcLine('과세표준', result.taxableIncome, formatMoney),
              _calcLine('산출세액', result.calculatedTax, formatMoney),
              if (result.smeReduction > 0)
                _calcLine(
                  '중소기업 청년 감면',
                  -result.smeReduction,
                  formatMoney,
                ),
              _calcLine(
                '세액공제 합계',
                -result.taxDeductions.total,
                formatMoney,
              ),
              _calcLine('결정세액', result.finalTax, formatMoney),
              _calcLine(
                '기납부세액(추정)',
                -result.prepaidTax,
                formatMoney,
              ),
              pw.Divider(color: PdfColors.grey400),
              _calcLine(
                '최종 세액',
                finalSettlementTax,
                formatMoney,
                emphasized: true,
              ),
            ],
      ),
    );

    return document.save();
  }

  static pw.Widget _buildSection({
    required String title,
    required List<_ReportRow> rows,
    required String Function(double amount) formatMoney,
  }) {
    final filtered =
        rows.where((row) => row.amount > 0 || row.deduction != 0).toList();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        ...filtered.map(
          (row) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Text(row.name),
                      if (row.amount > 0)
                        pw.Text(
                          '납입액: ${formatMoney(row.amount)}',
                          style: const pw.TextStyle(
                            color: PdfColors.grey700,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
                pw.Text(
                  formatMoney(row.deduction),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _calcLine(
    String label,
    double value,
    String Function(double amount) formatMoney, {
    bool emphasized = false,
  }) {
    final style = pw.TextStyle(
      fontSize: emphasized ? 13 : 11,
      fontWeight: emphasized ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        children: <pw.Widget>[
          pw.Text(label, style: style),
          pw.Spacer(),
          pw.Text(formatMoney(value), style: style),
        ],
      ),
    );
  }

  static Future<pw.ThemeData?> _buildKoreanTheme() async {
    try {
      final base = await PdfGoogleFonts.notoSansKRRegular();
      final bold = await PdfGoogleFonts.notoSansKRBold();
      return pw.ThemeData.withFont(base: base, bold: bold);
    } catch (_) {
      return null;
    }
  }
}

class _ReportRow {
  const _ReportRow({
    required this.name,
    required this.amount,
    required this.deduction,
  });

  final String name;
  final double amount;
  final double deduction;
}
