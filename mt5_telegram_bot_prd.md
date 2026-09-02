# Product Requirements Document (PRD): MetaTrader 5 to Telegram Notification Bot

## 1. Overview & Goal
Build a robust, real-time notification bridge between MetaTrader 5 (MT5) Expert Advisors (EAs) and Telegram. The system automatically alerts the trader whenever an automated trading decision results in a market execution, providing crucial order parameters (entry price, Stop Loss, Take Profit, lot size, etc.) directly to their Telegram chat without requiring active terminal monitoring.

## 2. Target Users & Use Cases
* **Automated Forex/Commodity Traders:** Traders utilizing custom or pre-built MQL5 Expert Advisors who need instant operational oversight.
* **Use Case:** A trader running an automated EA on a VPS needs immediate push alerts on mobile when a trade is opened, including precise price levels, to maintain situational awareness.

## 3. Core Features & Requirements
### 3.1. Instant Execution Detection
* The MQL5 script/EA must monitor order events or trigger notifications immediately upon successful execution (`OrderSend` / trade history tracking).

### 3.2. Rich Text Telegram Messages
* Utilize Telegram Bot API (`sendMessage`) with HTML parse mode for clear visual formatting.
* Mandatory data fields per notification:
  * Symbol / Pair (e.g., EURUSD, XAUUSD)
  * Action Type (BUY / SELL)
  * Volume (Lot size)
  * Open Price
  * Stop Loss (SL)
  * Take Profit (TP)
  * Execution Timestamp

### 3.3. Secure & Native MT5 WebRequest Integration
* Leverage native MQL5 `WebRequest()` functionality.
* Eliminate third-party DLL dependencies for maximum stability and security on live or VPS trading environments.

## 4. Technical Specifications & Prerequisites
* **Platform:** MetaTrader 5 (Windows / VPS)
* **Language:** MQL5
* **External API:** Telegram Bot API (`https://api.telegram.org/bot<TOKEN>/sendMessage`)
* **MT5 Terminal Settings:**
  * `Allow WebRequest` must be enabled in `Tools -> Options -> Expert Advisors`.
  * `https://api.telegram.org` must be explicitly added to the allowed URL list.

## 5. Message Template Design
```html
🟢 <b>TRADE EXECUTED (BUY)</b>
━━━━━━━━━━━━━━━━━
📊 <b>Pair:</b> EURUSD
📦 <b>Lot:</b> 0.10
💰 <b>Open Price:</b> 1.08500
🛑 <b>Stop Loss:</b> 1.08200
🎯 <b>Take Profit:</b> 1.09000
⏰ <b>Time:</b> 2026.07.23 22:15:00
━━━━━━━━━━━━━━━━━
```

## 6. Implementation Workflow
1. **Bot Creation:** Initialize a bot via `@BotFather` to obtain the `Bot Token` and retrieve the target `Chat ID`.
2. **Terminal Configuration:** Configure MT5 WebRequest security settings.
3. **MQL5 Integration:** Embed the HTTP POST function (`SendTelegramMessage`) and trigger it upon successful order placement within the EA logic.
