PROPstyle Risk Monitor - MT4/MT5
Professional risk management indicator that calculates real money at risk based on Stop Loss levels - not guesses.
Built for prop traders and anyone serious about risk management.

📊 What This Does
Shows your actual dollar and percentage risk across all open positions in real-time. No spreadsheets, no mental math, no assumptions.
The indicator analyzes your stop loss placement and calculates exactly how much money you'll lose if all stops are hit.

✨ Core Features
Real-Time Risk Calculation

Total Portfolio Risk - See your combined risk across all positions in $ and %
Per-Trade Breakdown - Each position shows individual risk with color coding
Live Updates - Recalculates instantly as positions change

Why it matters: Know your exact exposure before it's too late. No more accidentally over-risking your account.

Smart Position Detection
Break-Even Detection (NEW)

Automatically detects when SL = Entry price (±2 pips)
Shows 0% risk for break-even positions
These trades are excluded from total risk calculation

Profit-Locked Detection (NEW)

Identifies positions with SL beyond entry (trailing into profit)
Displays in GREEN with "+" sign
Not counted toward your risk total
Example: #12345 EURUSD $47.25 (+0.52%)

Missing Stop Loss Warning

Shows count of trades without SL in red
Excludes these from calculations (unlimited risk)
Prevents false sense of security

Why it matters: Accurately separates risk from profit. When you trail stops into profit, your risk drops to zero - the indicator reflects this.

Balance Tracking Modes
Choose how the indicator tracks your account size:
Fixed Balance (Default)

Uses your manually set reference balance
Never changes automatically
Best for: Most traders, manual control

Track Balance Down Only

Updates only when balance drops below reference
Never increases above your initial setting
Best for: Prop challenges where you can't reset starting balance after losses

Auto Track Balance

Always uses current live balance/equity
Updates automatically with every trade
Best for: Live funded accounts, adaptive risk management

Use Equity Instead of Balance

Includes floating profit/loss in calculations
More accurate during active trading
Best for: Day traders, scalpers, multiple open positions

Why it matters: Different trading scenarios need different tracking. Prop challenges have strict rules - this keeps you compliant.

Prop Firm Safety Tools
Daily Loss Limit Tracker

Monitors loss from session start
Set limit in % or fixed dollar amount
Custom reset time (e.g., "17:00" for NY close, "00:00" for midnight)
Alert when limit reached - prevents rule violations

Trailing Drawdown Monitor

Tracks drawdown from highest balance/equity
Critical for prop firm trailing DD rules
Set in % or $ amount
Alert when approaching limit

Why it matters: Prop firms have strict daily loss and drawdown limits. One violation = challenge failed. This tracks them automatically so you don't have to.

Alert & Warning System
Configurable Risk Alerts

Max total portfolio risk % threshold
Max per-trade risk % threshold
Max open positions limit
Audio and visual alerts when exceeded

Color-Coded Display

🟢 Green: ≤1% risk (safe) or profit-locked
🟡 Yellow: 1-2% risk (caution)
🟠 Orange: 2-5% risk (elevated)
🔴 Red: >5% risk or limit exceeded

Real-Time Warnings

Total risk exceeded
Too many open positions
Missing stop losses
Single trade risk too high
Balance not set

Status Indicator

Shows "All safety checks passed" in green when safe
Displays active warnings in red/orange

Why it matters: Catch problems before they destroy your account. Alerts give you time to act, not react.

🎯 Who This Helps
Prop Traders

✅ Stay within daily loss limits automatically
✅ Track trailing drawdown rules
✅ Never violate challenge rules by accident
✅ Pass evaluations safely and consistently

Swing Traders

✅ Manage multi-position exposure over days
✅ See total portfolio risk at a glance
✅ Avoid over-concentration in correlated pairs

Day Traders & Scalpers

✅ Control stacked entries in real-time
✅ Use equity tracking for live floating P/L
✅ Prevent overtrading with position limits

Anyone Managing Risk

✅ See risk in dollars, not pips
✅ Verify position sizing before entry
✅ Build disciplined risk management habits


📥 Installation
MT4

Download PROPstyle_SafetyPack.mq4
Open MT4 → File → Open Data Folder
Navigate to: MQL4 → Indicators
Copy the .mq4 file here
Restart MT4 or click Refresh in Navigator
Navigator (Ctrl+N) → Indicators → Custom
Drag PROPstyle to your chart
Set ReferenceBalance to your account size (REQUIRED)

MT5

Download PROPstyle_SafetyPack_MT5.mq5
Open MT5 → File → Open Data Folder
Navigate to: MQL5 → Indicators
Copy the .mq5 file here
Restart MT5 or press Ctrl+N
Navigator → Indicators → Custom
Right-click PROPstyle → Attach to chart
Set ReferenceBalance to your account size (REQUIRED)


⚙️ Quick Setup Guide
Required Setting
ReferenceBalance - Your account size or prop firm starting balance

Example: 100000 for $100k account
Must be set or indicator won't work properly

Panel Position
PanelCorner - Where the display appears on chart

MT4: 0 = Top Left, 2 = Bottom Left
MT5: Dropdown menu (Top/Bottom, Left/Right)

Recommended Settings for Prop Traders
ReferenceBalance: [Your challenge amount]
TrackBalanceDown: true (locks starting balance)
MaxTotalRiskPercent: 1.0 (conservative)
TrackDailyLoss: true
DailyLossLimitPercent: 5.0 (or your firm's limit)
TrackTrailingDrawdown: true
TrailingDrawdownPercent: 10.0 (or your firm's limit)
SessionResetTime: "17:00" (NY close)
EnableAlerts: true
Recommended Settings for Live Trading
ReferenceBalance: [Your account size]
AutoTrackBalance: true (tracks live balance)
UseEquityInsteadOfBalance: true (includes floating P/L)
MaxTotalRiskPercent: 2.0
EnableAlerts: true

🔧 All Settings Explained
Balance Tracking:

ReferenceBalance - Starting account size (required)
TrackBalanceDown - Only update if balance drops
AutoTrackBalance - Always use current balance
UseEquityInsteadOfBalance - Include floating P/L

Risk Limits:

MaxTotalRiskPercent - Alert threshold for total risk
MaxPerTradeRiskPercent - Alert threshold per position
MaxOpenPositions - Max number of concurrent trades

Alerts:

EnableAlerts - Turn audio/visual alerts on/off
ShowTradesWithoutSL - Display missing SL warning

Daily Loss Tracking:

TrackDailyLoss - Enable daily loss monitoring
DailyLossLimitPercent - Daily loss limit in %
DailyLossLimitDollar - Daily loss limit in $ (0 = use % only)
SessionResetTime - When to reset daily tracking (HH:MM format)

Trailing Drawdown:

TrackTrailingDrawdown - Enable trailing DD monitoring
TrailingDrawdownPercent - Limit in % from highest balance
TrailingDrawdownDollar - Limit in $ (0 = use % only)


📸 Example Display
Total Risk: 0.51% of 100000
Total Risk: $511.05
Tracking Balance: $100000.00 [Fixed]
Open Positions: 5 / 10

#558145879 BTCUSD $14.65 (0.01%)
#558145933 BTCUSD $12.31 (0.01%)
#558145963 EURUSD $46.95 (+0.05%)  ← Profit locked (green)
#558145983 GBPUSD $4.31 (0.00%)
#558146279 XAUUSD $5.37 (0.01%)

Daily Loss: $250.00 (0.25%) / Limit: $5000.00
Trailing DD: $0.00 (0.00%) / Limit: $10000.00

All safety checks passed

= PROPstyle=by LamaToes

🆕 Latest Updates
v2.0 - Break-Even & Profit Lock Detection

✨ Break-even positions (SL = Entry ±2 pips) now show 0% risk
✨ Profit-locked positions (SL beyond entry) display in green with "+"
✨ Smart risk calculation excludes both BE and profit-locked trades
🐛 Fixed: Indicator objects now properly delete when removed from chart
🐛 Fixed: Removed all emojis that displayed as "??" in MT4/MT5


❓ FAQ
Q: Why does my total risk show 0% when I have trades open?
A: Your stops are either at break-even or in profit. The indicator correctly shows 0% risk.
Q: I set a stop loss but it's not showing in the indicator.
A: Check if your SL is at break-even (±2 pips from entry). These are excluded as they have no risk.
Q: Can I use this on multiple charts?
A: Yes, but each chart instance uses the same settings. Only attach to one chart per account.
Q: Does this work with all brokers?
A: Yes, works with any MT4/MT5 broker and all symbols.
Q: How accurate is the risk calculation?
A: 100% accurate based on your stop loss placement. Uses actual tick values from your broker.

🤝 Community & Support

Reddit: r/PropRiskManagement
Issues: Use GitHub or Reddit Issues for bug reports
Features: Request features via GitHub or Reddit


📜 License
MIT License - Free to use, modify, and distribute.
If you share or fork this project, please credit the original author.

👨‍💻 Author
Created by LamaToes
Built by traders, for traders.

⚠️ Disclaimer
This indicator is a risk monitoring tool, not financial advice. Trading involves substantial risk of loss. Always:

Use proper risk management
Never risk more than you can afford to lose
Verify all calculations independently
Test on demo accounts first

The indicator shows risk based on current stop loss placement - actual losses may vary due to slippage, gaps, or broker execution.

🌟 Show Your Support
If this indicator helps your trading:

⭐ Star this repository
🔄 Share with other traders
💬 Join the community at r/PropRiskManagement
🐛 Report bugs or suggest features

Trade safer. Trade smarter.
