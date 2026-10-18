import 'package:flutter_test/flutter_test.dart';
import 'package:montra/src/services/sms/sms_parser.dart';

void main() {
  group('HDFC Sent Rs UPI Multi-line Format Tests', () {
    test('Parses HDFC SMS with multi-word payee, newline, ref, and bank a/c correctly', () {
      const sms = '''Sent Rs.350.00
From HDFC Bank A/C *4592
To RAJESH SHARMA K
On 17/10/26
Ref 491823
Not You?
Call 18000000000/SMS BLOCK UPI to 9000000000''';

      final result = SmsParser.parseSms('VM-HDFCBK', sms);
      expect(result, isNotNull);
      expect(result!.amount, 350.0);
      expect(result.merchant, 'Rajesh Sharma K');
      expect(result.account, '4592');
      expect(result.referenceNumber, '491823');
      expect(result.paymentMethod, 'UPI');
      expect(result.type, 'Expense');
    });

    test('Parses HDFC SMS even if sender ID is generic or unknown telecom header', () {
      const sms = '''Sent Rs.350.00
From HDFC Bank A/C *4592
To RAJESH SHARMA K
On 17/10/26
Ref 491823
Not You?
Call 18000000000/SMS BLOCK UPI to 9000000000''';

      final result = SmsParser.parseSms('VK-600001', sms);
      expect(result, isNotNull);
      expect(result!.amount, 350.0);
      expect(result.merchant, 'Rajesh Sharma K');
      expect(result.referenceNumber, '491823');
    });
  });

  group('Major Indian Banks SMS Formats', () {
    test('HDFC Debit Card spent format', () {
      const sms = 'Update! INR 1,450.00 was spent on your HDFC Bank Card ending 1234 on 15-OCT-26 at AMAZON INDIA. Bal: INR 45,210.00';
      final result = SmsParser.parseSms('HDFCBK', sms);

      expect(result, isNotNull);
      expect(result!.amount, 1450.0);
      expect(result.merchant, 'Amazon India');
      expect(result.account, '1234');
      expect(result.availableBalance, 45210.0);
      expect(result.category, 'Shopping');
      expect(result.paymentMethod, 'Card');
    });

    test('SBI transfer to UPI with amount without currency symbol', () {
      const sms = 'Dear SBI UPI User, your A/C X3456 debited by 250.0 on 05Oct26 by transfer to SWIGGY (UPI Ref no 327819287319).';
      final result = SmsParser.parseSms('VK-SBIINB', sms);

      expect(result, isNotNull);
      expect(result!.amount, 250.0);
      expect(result.merchant, 'Swiggy');
      expect(result.paymentMethod, 'UPI');
      expect(result.referenceNumber, '327819287319');
      expect(result.category, 'Food');
    });

    test('SBI ATM cash withdrawal', () {
      const sms = 'Your A/C 12345 has been debited by Rs 1,000.00 on 17/10/26 through ATM wdl. Avl Bal Rs 24,000.00.';
      final result = SmsParser.parseSms('SBI', sms);

      expect(result, isNotNull);
      expect(result!.amount, 1000.0);
      expect(result.merchant, 'ATM Cash');
      expect(result.paymentMethod, 'Cash');
      expect(result.availableBalance, 24000.0);
    });

    test('ICICI Info BIL subscription format', () {
      const sms = 'Acct XX123 debited with INR 500.00 on 09-Oct-26. Info: BIL*123456*Netflix. Available Balance is INR 23,450.00.';
      final result = SmsParser.parseSms('ICICIB', sms);

      expect(result, isNotNull);
      expect(result!.amount, 500.0);
      expect(result.merchant, 'Netflix');
      expect(result.category, 'Entertainment');
      expect(result.availableBalance, 23450.0);
    });

    test('ICICI Info UPI format', () {
      const sms = 'Dear Customer, your Acct XX123 is debited with INR 1,200.00 on 17-Oct-26. Info: UPI*Uber*uber@icici*123456. Avl Bal: INR 15,200.00.';
      final result = SmsParser.parseSms('ICICIB', sms);

      expect(result, isNotNull);
      expect(result!.amount, 1200.0);
      expect(result.merchant, 'Uber');
      expect(result.category, 'Transportation');
      expect(result.availableBalance, 15200.0);
    });

    test('Axis Bank towards VPA format', () {
      const sms = 'Your A/C no. XX3456 is debited for Rs.890.00 on 08-10-26 towards swiggy@icici. UPI Ref: 328472918. Avl Bal: INR 12,340.50.';
      final result = SmsParser.parseSms('AXISBK', sms);

      expect(result, isNotNull);
      expect(result!.amount, 890.0);
      expect(result.merchant, 'swiggy@icici');
      expect(result.paymentMethod, 'UPI');
      expect(result.availableBalance, 12340.50);
      expect(result.referenceNumber, '328472918');
    });

    test('Kotak Mahindra Bank Sent Rs UPI format', () {
      const sms = 'Sent Rs. 350.00 from Kotak Bank A/C XX4321 to Chai Point on 17-10-26. UPI Ref 382910283920. Balance: Rs. 4,200.00.';
      final result = SmsParser.parseSms('KMBL', sms);

      expect(result, isNotNull);
      expect(result!.amount, 350.0);
      expect(result.merchant, 'Chai Point');
      expect(result.paymentMethod, 'UPI');
      expect(result.category, 'Food');
      expect(result.availableBalance, 4200.0);
      expect(result.referenceNumber, '382910283920');
    });

    test('PNB SMS through UPI format', () {
      const sms = 'PNB SMS: Rs. 1,000.00 debited from A/C ...5678 on 17/10/26 through UPI/4291829182/SWIGGY. Bal: Rs. 12,000.00.';
      final result = SmsParser.parseSms('PNBSMS', sms);

      expect(result, isNotNull);
      expect(result!.amount, 1000.0);
      expect(result.merchant, 'Swiggy');
      expect(result.category, 'Food');
      expect(result.availableBalance, 12000.0);
    });

    test('Bank of Baroda UPI format', () {
      const sms = 'BOB: Your A/C *4321 is debited with Rs. 750.00 on 17-10-26 towards UPI/SWIGGY/429182918239. Avl Bal: Rs. 9,450.00.';
      final result = SmsParser.parseSms('BOBTXN', sms);

      expect(result, isNotNull);
      expect(result!.amount, 750.0);
      expect(result.merchant, 'Swiggy');
      expect(result.category, 'Food');
      expect(result.availableBalance, 9450.0);
    });

    test('Canara Bank in favour of format', () {
      const sms = 'Canara Bank: Rs 620.00 debited from A/c ...3214 on 12-10-26. In favour of Uber India via UPI ref 1234. Avl Bal: 3120.00';
      final result = SmsParser.parseSms('CANBNK', sms);

      expect(result, isNotNull);
      expect(result!.amount, 620.0);
      expect(result.merchant, 'Uber India');
      expect(result.category, 'Transportation');
      expect(result.availableBalance, 3120.0);
    });

    test('IndusInd Bank towards VPA format', () {
      const sms = 'A/C *XX1234 debited by Rs 1250.00 towards store-pay@upi. RRN:6227103. Avl Bal:254.77. Not you? Call 18602677777 - IndusInd bank';
      final result = SmsParser.parseSms('AD-INDUSB', sms);

      expect(result, isNotNull);
      expect(result!.amount, 1250.0);
      expect(result.merchant, 'store-pay@upi');
      expect(result.availableBalance, 254.77);
      expect(result.referenceNumber, '6227103');
    });

    test('IDFC FIRST Bank format', () {
      const sms = 'Your IDFC FIRST Bank A/C ending 5678 is debited by INR 450.00 on 17-Oct-26 towards Zomato via UPI. Ref: 4291829182. Avl Bal: INR 8,900.00.';
      final result = SmsParser.parseSms('IDFCFB', sms);

      expect(result, isNotNull);
      expect(result!.amount, 450.0);
      expect(result.merchant, 'Zomato');
      expect(result.availableBalance, 8900.0);
      expect(result.referenceNumber, '4291829182');
    });

    test('Federal Bank format', () {
      const sms = 'Federal Bank: Rs 850.00 debited from A/C *9876 on 17-10-26 towards DMART. UPI Ref: 382910283. Bal: Rs 15,200.00.';
      final result = SmsParser.parseSms('FEDBK', sms);

      expect(result, isNotNull);
      expect(result!.amount, 850.0);
      expect(result.merchant, 'Dmart');
      expect(result.category, 'Shopping');
      expect(result.availableBalance, 15200.0);
    });

    test('Yes Bank format', () {
      const sms = 'YES BANK: INR 1,500.00 debited from A/C XX4321 on 17-10-26 for UPI payment to amazon@apl. Ref No 4291829182. Avl Bal: INR 22,000.00.';
      final result = SmsParser.parseSms('YESBNK', sms);

      expect(result, isNotNull);
      expect(result!.amount, 1500.0);
      expect(result.merchant, 'amazon@apl');
      expect(result.availableBalance, 22000.0);
    });
  });

  group('UPI Apps & Fintech Formats', () {
    test('PhonePe transaction SMS', () {
      const sms = 'Paid Rs.250 to VIKRAM SINGH N on PhonePe. Txn ID: T261017123456789.';
      final result = SmsParser.parseSms('PHONEPE', sms);

      expect(result, isNotNull);
      expect(result!.amount, 250.0);
      expect(result.merchant, 'Vikram Singh N');
      expect(result.referenceNumber, 'T261017123456789');
      expect(result.paymentMethod, 'UPI');
    });

    test('Google Pay transaction SMS', () {
      const sms = 'You have paid Rs. 150.00 to Starbucks using Google Pay. UPI transaction ID: 429182918239.';
      final result = SmsParser.parseSms('GPAY', sms);

      expect(result, isNotNull);
      expect(result!.amount, 150.0);
      expect(result.merchant, 'Starbucks');
      expect(result.category, 'Food');
      expect(result.referenceNumber, '429182918239');
      expect(result.paymentMethod, 'UPI');
    });

    test('Paytm order SMS', () {
      const sms = 'Paytm: Rs. 350.00 paid for order at Zomato. Wallet balance: Rs. 120.00.';
      final result = SmsParser.parseSms('PAYTM', sms);

      expect(result, isNotNull);
      expect(result!.amount, 350.0);
      expect(result.merchant, 'Zomato');
      expect(result.category, 'Food');
      expect(result.availableBalance, 120.0);
    });

    test('OneCard credit card SMS', () {
      const sms = 'Rs. 2,499.00 spent on OneCard ending in 1234 at ZARA on 17-Oct-26. Available limit: Rs. 45,000.00.';
      final result = SmsParser.parseSms('ONECRD', sms);

      expect(result, isNotNull);
      expect(result!.amount, 2499.0);
      expect(result.merchant, 'Zara');
      expect(result.category, 'Shopping');
      expect(result.account, '1234');
      expect(result.availableBalance, 45000.0);
      expect(result.paymentMethod, 'Card');
    });

    test('CRED payment SMS', () {
      const sms = 'Paid Rs 500 on CRED using HDFC Bank **9123 to Swiggy. UPI Ref: 429182918239.';
      final result = SmsParser.parseSms('CRED', sms);

      expect(result, isNotNull);
      expect(result!.amount, 500.0);
      expect(result.merchant, 'Swiggy');
      expect(result.category, 'Food');
      expect(result.referenceNumber, '429182918239');
    });

    test('Short SMS without bank name in sender or body', () {
      const sms = 'Sent Rs.400.00 from A/C *5521 to VIKRAM SINGH N on 17/10/26 Ref 654321';
      final result = SmsParser.parseSms('UNKNOWN', sms);

      expect(result, isNotNull);
      expect(result!.amount, 400.0);
      expect(result.merchant, 'Vikram Singh N');
      expect(result.account, '5521');
      expect(result.referenceNumber, '654321');
    });
  });

  group('Spam, OTP, Credit & Failed Transaction Rejection Tests', () {
    test('Rejects OTP verification SMS', () {
      const sms = 'Your OTP is 123456 for transaction of Rs 200 on HDFC Bank Card ending 6789. Do not share with anyone.';
      final result = SmsParser.parseSms('HDFCBK', sms);
      expect(result, isNull);
    });

    test('Rejects promotional loan offer SMS', () {
      const sms = 'Pre-approved loan of Rs. 5,00,000 in your HDFC account. Apply now at hdfc.com/loan.';
      final result = SmsParser.parseSms('HDFCBK', sms);
      expect(result, isNull);
    });

    test('Rejects pure credit / salary deposit SMS', () {
      const sms = 'INR 50,000.00 credited to your account on 01-Oct-26 by Employer. Avl Bal: Rs 65,000.00';
      final result = SmsParser.parseSms('SBI-Bank', sms);
      expect(result, isNull);
    });

    test('Rejects declined transaction SMS', () {
      const sms = 'Transaction of Rs 200 on HDFC Bank Card was declined due to insufficient balance.';
      final result = SmsParser.parseSms('HDFCBK', sms);
      expect(result, isNull);
    });

    test('Rejects collect / payment request SMS', () {
      const sms = 'Merchant Swiggy has requested Rs 350.00 via UPI. Open UPI app to approve or decline.';
      final result = SmsParser.parseSms('NPCI', sms);
      expect(result, isNull);
    });
  });

  group('Bank Debit Formats from Dataset Benchmark', () {
    test('Parses loan EMI auto-debit format without currency symbol', () {
      const sms = 'EMI of 61741.00 debited from a/c **2191 towards HDFC Bank loan on 02 Dec 2022. Remaining: 225,839.';
      final result = SmsParser.parseSms('HDFCBK', sms);
      expect(result, isNotNull);
      expect(result!.amount, 61741.0);
      expect(result.account, '2191');
      expect(result.paymentMethod, 'Bank Transfer');
    });

    test('Parses amount with colon after Rs', () {
      const sms = 'A/c *1234 Debited for Rs:500.00 on 12-10-2024 12:00:00 by Mob Bk ref no 428512345678 Avl Bal Rs:5000.00.If not you, Call 1800000000 -Union Bank of India';
      final result = SmsParser.parseSms('UNIONB', sms);
      expect(result, isNotNull);
      expect(result!.amount, 500.0);
      expect(result.account, '1234');
      expect(result.referenceNumber, '428512345678');
      expect(result.availableBalance, 5000.0);
    });

    test('Parses Bank of Baroda Dr and Cr format', () {
      const sms = 'Rs.35.00 Dr. from A/C XXXXXX1234 and Cr. to name@oksbi';
      final result = SmsParser.parseSms('BOBTRN', sms);
      expect(result, isNotNull);
      expect(result!.amount, 35.0);
      expect(result.account, '1234');
      expect(result.merchant, 'name@oksbi');
    });

    test('Parses ICICI dual debited and credited format', () {
      const sms = 'Acct XX123 debited for Rs 240.00 on 28-Sep-26; ZOMATO credited.\n\nSMS BLOCK 123 to 9215676766.';
      final result = SmsParser.parseSms('ICICIB', sms);
      expect(result, isNotNull);
      expect(result!.amount, 240.0);
      expect(result.merchant, 'Zomato');
      expect(result.account, '123');
      expect(result.category, 'Food');
    });

    test('Parses IMPS transferred from A/c format', () {
      const sms = 'IMPS: Rs.25,000.00 transferred from A/c XX9876 to RELIANCEJP on 09-09-26. Ref 99876881. AXIS';
      final result = SmsParser.parseSms('AXISBK', sms);
      expect(result, isNotNull);
      expect(result!.amount, 25000.0);
      expect(result.merchant, 'Reliancejp');
      expect(result.account, '9876');
      expect(result.referenceNumber, '99876881');
      expect(result.paymentMethod, 'Bank Transfer');
    });

    test('Parses Hindi bank debit SMS', () {
      const sms = 'BOB: आपके खाते XX9876 से Rs.99 ZOMATO को UPI द्वारा 01-01-26 को काटे गए। उपलब्ध शेष Rs.1,234.50';
      final result = SmsParser.parseSms('BOBTRN', sms);
      expect(result, isNotNull);
      expect(result!.amount, 99.0);
      expect(result.merchant, 'Zomato');
      expect(result.availableBalance, 1234.50);
      expect(result.paymentMethod, 'UPI');
    });

    test('Parses concatenated amount without space before debited', () {
      const sms = 'Rs.500.00debited from A/c1234';
      final result = SmsParser.parseSms('SBI', sms);
      expect(result, isNotNull);
      expect(result!.amount, 500.0);
      expect(result.account, '1234');
    });

    test('Parses foreign currency transaction', () {
      const sms = 'International txn: \$ 541 debited from Federal Bank A/c 3711 at Amazon.com on 30th Mar. Bal: INR 301,934.';
      final result = SmsParser.parseSms('FEDBK', sms);
      expect(result, isNotNull);
      expect(result!.amount, 541.0);
      expect(result.account, '3711');
      expect(result.merchant, 'Amazon.com');
      expect(result.availableBalance, 301934.0);
    });
  });
}

