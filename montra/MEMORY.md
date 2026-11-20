# Montra Project Memory & Architecture Guide

> **CRITICAL DIRECTIVE FOR AI AGENTS & DEVELOPERS:**
> This file is the single source of truth for all instructions, design decisions, feature implementations, and architecture history for the Montra project.
> **Whenever the user provides new instructions, makes changes, adds/removes features, or modifies logic, you MUST update this file immediately.**

---

## 1. Application Overview & Architecture

**Montra** is an offline-first personal expense tracker for Android (built with Flutter) that automatically intercepts and parses bank and financial SMS notifications to record income and expenses in real time without compromising privacy.

### Tech Stack
* **Framework:** Flutter (Material 3 design system)
* **Language:** Dart
* **State Management:** Riverpod (`flutter_riverpod`)
* **Local Database:** Drift (SQLite with WAL mode, foreign keys, and indexes)
* **Navigation:** GoRouter with `ShellRoute` for bottom navigation
* **Native Android Integration:** Kotlin BroadcastReceiver (`SmsReceiver.kt`) + Background MethodChannel for foreground & background SMS capture
* **Background Scheduling:** Android `WorkManager` (every 12h check for 1st-of-month summary)
* **Security:** `local_auth` (biometrics / device PIN) + `flutter_secure_storage`

---

## 2. Core App Working & Systems

### A. SMS Detection & Parsing Engine
* **Native Receiver:** `SmsReceiver.kt` listens for incoming `android.provider.Telephony.SMS_RECEIVED`.
* **Dart Interceptor:** `NativeSmsInterceptor` handles foreground and background message parsing.
* **Parser:** `SmsParser` uses regex to extract:
  * Amount, transaction type (Debit/Expense, Credit/Income, ATM, Ignored).
  * Merchant or payee (e.g., Swiggy, Zomato, Amazon, Uber).
  * Payment method (UPI, Debit Card, Credit Card, NetBanking, ATM Cash).
  * Available bank balance & bank transaction reference IDs (RRN/UTR).
  * Auto-categorization (Food, Transport, Groceries, Shopping, Health, Utilities, etc.).
* **Deduplication:** Prevents duplicate entries using reference number (`bankTransactionId`) or identical SMS body checks.
* **Unrecognized SMS:** Financial messages that cannot be parsed are captured in the `UnrecognizedSms` database table for audit and manual resolution.

### B. Database Schema & Migration (`AppDatabase`)
* Current Schema Version: **12**
* **Tables:**
  * `Transactions`: id, amount, type, merchant, categoryId, paymentMethod, accountId, targetAccountId, availableBalance, transactionDate, notes, originalSms, bankTransactionId, receiptAttachment.
  * `Categories`: id, name, type, color, icon.
  * `Accounts`: id, bankName, availableBalance, totalTransactions, totalIncome, totalExpenses, lastTransactionDate, icon, color, isHidden.
  * `Budgets`: id, amount, month, year, categoryId, startDate, endDate.
  * `Notifications`: id, title, body, notificationDate, type, isRead, payload.
  * `Settings`: key, value (primary key key).
  * `Tags` & `TransactionTags`: Multi-tagging support.
  * `UnrecognizedSms`: Audit trail for skipped or unrecognized bank messages.
  * `SavedSummaries`: id, month, year, totalExpense, topCategory, topCategoryAmount, topMerchant, transactionCount, totalIncome, netSavings, dailyAverage, incomeCount, categoryBreakdown (JSON), merchantBreakdown (JSON), paymentMethodBreakdown (JSON), generatedAt. Indexed by `(month, year)`.
  * `NotificationSettingsDb`: Settings for large expense thresholds and budget alerts.

### C. Notification Engine (`NotificationManager`)
* Immediate transaction detection notification (`💳 Expense Detected`).
* Large expense alerts when spending exceeds user threshold.
* Budget progress alerts (50%, 80%, 95%, 100%, and over-limit warnings).
* Monthly summary push notifications on the 1st of each month.

---

## 3. UI/UX & Screen Features

### 1. Dashboard / Home Screen (`/`)
* **Header:** Greeting (`Good Morning/Afternoon/Evening`), User Name (editable modal), Profile avatar modal.
* **Balance Card:** Today's expenses vs This Month's expenses.
* **Recent Transactions:**
  * Displays the 5 most recent transactions.
  * **Quick Category Selection:** Double-tap on the item or tap on the category avatar to open a category selection sheet and instantly assign/change the category.
  * **Long-Press Menu:**
    * *Ignore / Restore:* Toggles transaction between active `'Expense'` and `'Ignored'` (with strikethrough styling and stat recalculation).
    * *Change Category:* Opens the category picker sheet.
    * *Edit Details & Date:* Opens the full editor screen.
    * *Delete:* Prompts for confirmation and deletes the record from Drift SQLite.
  * **Tap to Edit:** Opens `/add-transaction` pre-filled with transaction data.

### 2. Transactions Screen (`/transactions`)
* **Real-time Search:** Filter transactions by merchant name, notes, or type.
* **Multi-Select Batch Delete:** Long-press enters multi-selection mode with checkboxes and an app bar delete action.
* **Transaction Items:** Feature parity with Dashboard (tap to edit, double-tap to change category, long-press menu for ignore/restore, category change, edit, delete).
* **View Monthly Expense History:**
  * Accessible from a top history card.
  * Lists each recorded month with its total spending (`Month Year • ₹Amount`).
  * **Interactive Report Generation:** Tapping any month item (or its chart icon) immediately computes stats for that specific month and navigates to the **Monthly Summary Report** screen (`/monthly-summary-report`).

### 2b. Monthly Summary Report Screen (`/monthly-summary-report`)
* **Strict Month Isolation:** All metrics, category breakdowns, payee rankings, and transaction items are strictly computed for the chosen calendar month using `.toLocal()` timezone boundaries. Ignored transactions are excluded.
* **Month Navigation:** `< Previous Month` and `Next Month >` arrows (with future month prevention), plus an interactive 12-month & year picker modal sheet.
* **Hero Statement Banner:** Deep gradient card showing total expense, transaction count, daily average spend, total income, net savings (positive/negative badges), and days recorded.
* **Savings Health Card:** Displays savings percentage rate, retained savings vs deficit, and colored progress track.
* **Key Highlights Row:** Top spending category, top merchant payee, and peak spending day.
* **Category Breakdown:** FlChart Donut chart with touch highlighting and itemized list with percentage progress bars.
* **Top Payees Leaderboard:** Ranked list (1-5) of top merchants with purchase counts and percentage share.
* **Payment Modes Distribution:** Grid breakdown of UPI, Cards, Net Banking, and Cash.
* **Top 5 Major Purchases:** Highlights the highest-value individual expenses of that month.
* **Itemized Monthly Ledger:** "All Transactions of [Month Name]" with filter chips (`All`, `Expenses`, `Income`), clickable items to view/edit in `/add-transaction` with automatic statement reload on return, and expand/collapse support.
* **Sharing & Persistence:** Formatted text report generation via `SharePlus` and snapshot storage in Drift `saved_summaries`.

### 3. Budgets Screen (`/budgets`)
* Category-specific or Overall monthly budget limits.
* Progress bars indicating spent amount, remaining amount, and percentage.
* Add/Edit budget screen (`/add-budget`) supporting custom date ranges or monthly cycles.

### 4. Analytics Screen (`/analytics`)
* **Scope:** **Strictly scoped to the present calendar month** (`DateTime.now().month` and `year`). All past months are excluded from current month analytics.
* **Merchant Intelligence:** Most visited merchant, visit count, highest spend merchant, and max spent for the current month.
* **Weekly Trend Bar Chart:** 7-day spending distribution (0 = Today, ..., 6 = 6 days ago) within the current month.
* **Category Breakdown Pie Chart:** Dynamic slice distribution with percentage labels and color-coded category legends.

### 5. Categories Management (`/categories` & `/add-category`)
* Lists all custom and pre-seeded categories with their icons and colors.
* **Add / Edit Category:**
  * Category Name input.
  * Type dropdown (Expense, Income, Transfer).
  * **Visual Icon Picker:** Interactive grid of 32 curated Material icons (shopping, food, drinks, groceries, transport, fuel, flight, bills, utilities, medical, movies, gaming, education, home, gym, gifts, subscriptions, etc.) with a live circular preview header.
  * Automatic database backfill ensures no category has null or empty icons.

### 6. Settings Screen (`/settings`)
* **General:**
  * Categories navigation.
  * Notification Settings (thresholds for large expenses and budget alerts).
  * Ignored SMS viewer (`/ignored-sms`).
* **Appearance:** Theme mode selector (Light, Dark, System).
* **Security:** Mobile Local Authentication toggle (Device Fingerprint, Face, or PIN lock screen via `/auth`).
* **Data Management:**
  * **Import & Export Data (`/backup`):** Manual user-controlled "Export JSON (Full)", "Export CSV", and "Upload File & Restore Data".
  * **Clear Database:** Prompts with options to clear past history only, all transactions, or perform a complete wipe.

---

## 4. Master Instruction Log & Changes History

| Date | Request / Instruction | Changes Implemented | Status |
| :--- | :--- | :--- | :--- |
| **2026-11-09** | **Dashboard Feature Parity**<br>"in dash board recent transaction provide all the feature provided in transaction page like adding category, modifing the transaction" | Added `_showCategorySelection` (on double tap & avatar tap) and `_showLongPressMenu` (Ignore/Restore, Change Category, Edit Details, Delete) to `dashboard_screen.dart`. | **Completed** |
| **2026-11-09** | **Remove Auto-Backup**<br>"and remove the feature of auto backup of data" | 1. Removed `triggerAutoBackupIfEnabled()` from `dashboard_screen.dart` (on pause).<br>2. Removed auto-backup calls on save/delete in `add_transaction_screen.dart`.<br>3. Removed auto-backup preference keys and methods in `backup_service.dart`.<br>4. Removed `AutoBackupNotifier` and `autoBackupEnabledProvider`.<br>5. Retained manual JSON & CSV export. | **Completed** |
| **2026-11-09** | **Analytics Present Month Scope**<br>"and in analytics page it is taking previous month data it should consider only present month data" | Filtered transactions in `analytics_screen.dart` so all bar charts, pie charts, category sums, and totals strictly consider only current month (`t.transactionDate.year == now.year && t.transactionDate.month == now.month`). | **Completed** |
| **2026-11-09** | **Remove Check Updates**<br>"and remove check updates feature" | Removed the "Check for Updates" tile and `UpdateService` call from `settings_screen.dart`. | **Completed** |
| **2026-11-09** | **Category Icon Assignment & DB Migration**<br>"and when user add a new category provide some icon to assign it the user should be able to assign a icon to category and also modify the db according to it" | 1. Added `availableIcons` catalog (32 icons) in `category_icon_helper.dart`.<br>2. Built an interactive icon picker with preview in `add_category_screen.dart`.<br>3. Updated `CategoryIconHelper.getIcon` to prefer explicit `iconName`.<br>4. Bumped Drift database to `schemaVersion: 11` with backfill migration in `onUpgrade` and `beforeOpen` to populate empty icons.<br>5. Updated `categories_screen.dart`, `dashboard_screen.dart`, and `transactions_screen.dart` to display assigned icons. | **Completed** |
| **2026-11-09** | **Relocate Monthly Report Generation**<br>"and from settings remove generate monthly report add that in view monthly expense history provide that feature here like expenses" | 1. Removed "Generate Monthly Summary" from `settings_screen.dart`.<br>2. Added `computeStatsForMonth(month, year)` to `monthly_summary_service.dart`.<br>3. In `transactions_screen.dart` ("View Monthly Expense History" sheet), made every month row tappable with a report chart icon to calculate and open `/monthly-summary-report` for that specific month. | **Completed** |
| **2026-11-16** | **Create Persistent Project Memory**<br>"create a memory file in folder what ever i make changes and give you instruction and anything whatever it would be save that in that file and apps working and feature also" | Created `MEMORY.md` at both project root (`/`) and Flutter root (`/montra`) documenting full architecture, features, database schemas, and chronological instruction changelog. | **Completed** |
| **2026-11-16** | **Production Release APK & Direct Device Install**<br>"now install the app directlly in connected device the smallest production ready apk" | Target device identified: `I2219` (`10BEAH2U41003X1`, `android-arm64`). Built release APK with `--split-per-abi`, `--obfuscate`, `--split-debug-info`, R8 shrinking (22.4 MB), and installed `app-arm64-v8a-release.apk` directly via ADB. | **Completed** |
| **2026-11-16** | **Expand Category Icons Catalog**<br>"add more icons in category" | Expanded `CategoryIconHelper.availableIcons` from 32 to 85+ icons covering Food, Drinks, Groceries, Shopping, Fashion, Vehicles, Travel, Home, Bills, Healthcare, Sports, Entertainment, Tech, Kids, Pets, Investments, and Finance. Added instant search filter and scrollable container in `add_category_screen.dart`. | **Completed** |
| **2026-11-19** | **Enhance Monthly Summary UI & Month Isolation**<br>"enhance the monthly summariy ui it is not good and detailed"<br>"monthly report should contain details of that month only" | 1. **Strict Month Isolation:** Filtered all transactions using `.toLocal()` calendar boundaries in `monthly_summary_service.dart` and `transactions_provider.dart`. Excluded ignored transactions and non-month records.<br>2. **Month Switcher & Picker:** Added `< Previous Month` and `Next Month >` navigation with future-month disabling, plus an interactive 12-month/year picker modal.<br>3. **Executive UI Overhaul:** Built gradient Hero Statement banner (Expense, Income, Net Savings, Daily Average), Savings Health card with progress bar, Key Highlights row (Top Category, Top Payee, Peak Spending Day), interactive FlChart Donut breakdown, Top 5 Payees leaderboard, Payment Modes distribution, and Top 5 Major Expenses.<br>4. **Itemized Monthly Ledger:** Added "All Transactions of [Month Name]" section with segmented filters (All, Expenses, Income), clickable transaction tiles to edit/inspect via `/add-transaction` with reactive reload, and expandable view.<br>5. **Zero-State Handling:** Empty months render a clean UI with month switcher intact instead of breaking.<br>6. **Tests:** Added `monthly_summary_test.dart` verifying data isolation and calculations (all 63 tests pass). | **Completed** |
| **2026-11-19** | **Database Schema Migration (Version 12)**<br>"edit the db base according to new chanegs" | 1. **SavedSummaries Schema Expansion:** Added `totalIncome`, `netSavings`, `dailyAverage`, `incomeCount`, and JSON fields (`categoryBreakdown`, `merchantBreakdown`, `paymentMethodBreakdown`) to `SavedSummaries` table in `tables.dart`.<br>2. **Index Optimization:** Added performance index `idx_saved_summaries_month_year` on `(month, year)` in `onCreate`, `onUpgrade`, and `beforeOpen`.<br>3. **Schema Version Bump:** Updated Drift database to `schemaVersion: 12` with non-destructive `addColumn` migrations in `database.dart`.<br>4. **Code Generation:** Re-ran `build_runner` generating updated table models and companions in `database.g.dart`.<br>5. **Persistence Logic:** Updated `_saveSummary()` in `monthly_summary_screen.dart` to save complete monthly financial metrics and remove previous snapshots for that month/year.<br>6. **Test Verification:** Updated and verified database schema version 12 in `widget_test.dart` (all 63 tests passed). | **Completed** |
| **2026-11-20** | **Production Release APK Build & Direct Device Install**<br>"10BEAH2U41003X1 this device is connected via cable i want to install the updated apk directly here provide me the command for that il'l do it i want the smallest apk"<br>"do it your self" | 1. Compiled smallest production release APK with architecture splitting (`--split-per-abi`), bytecode obfuscation (`--obfuscate`), and symbol extraction (`--split-debug-info`). Output: `app-arm64-v8a-release.apk` (22.6 MB).<br>2. Deployed directly to connected target device `10BEAH2U41003X1` via ADB stream install (`install -r`). Installation completed with `Success`. | **Completed** |

---

## 5. Ongoing Maintenance Rules for AI Agents

1. **Before Any Task:** Read this `MEMORY.md` to understand existing architectural patterns, database schemas, and previous user decisions.
2. **After Any Modification:** Append the new instruction, files touched, and verification results to the table in **Section 4 (Master Instruction Log)**.
3. **If Features Change:** Update the corresponding feature summary in **Section 3** and schema details in **Section 2**.

