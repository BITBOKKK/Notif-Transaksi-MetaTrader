# MT5 Telegram Notifier - Setup Guide

## Prerequisites
- MetaTrader 5 installed (Windows/VPS)
- Telegram account with BotFather access

## Step 1: Create Telegram Bot

1. Open Telegram and search for **@BotFather**
2. Send `/newbot` command
3. Enter a name for your bot (e.g., "MT5 Trade Notifier")
4. Enter a username (must end with `bot`, e.g., "mt5_trade_notifier_bot")
5. **Copy the Bot Token** provided (format: `123456789:ABCdefGHIjklMNOpqrSTUvwxYZ`)

## Step 2: Get Your Chat ID

1. Open Telegram and search for **@userinfobot**
2. Send any message to the bot
3. **Copy your Chat ID** (numeric value like `123456789`)

*For group notifications:*
1. Add `@userinfobot` to your group
2. Send a message in the group
3. Check the chat ID (will be negative, like `-1001234567890`)

## Step 3: Install EA in MetaTrader 5

1. Copy `MT5_Telegram_Notifier.mq5` to:
   ```
   C:\Users\[YourUsername]\AppData\Roaming\MetaQuotes\Terminal\[TerminalID]\MQL5\Experts\
   ```

2. Open MetaTrader 5
3. In the Navigator panel (Ctrl+N), find **Expert Advisors**
4. Right-click and select **Refresh**
5. You should see **MT5_Telegram_Notifier** in the list

## Step 4: Configure WebRequest

**Important:** This is required for the bot to communicate with Telegram.

1. In MT5, go to **Tools** → **Options** → **Expert Advisors**
2. Check **Allow WebRequest for listed URL**
3. Click **Add** and enter:
   ```
   https://api.telegram.org
   ```
4. Click **OK**

## Step 5: Configure and Attach EA

1. Drag **MT5_Telegram_Notifier** from Navigator to any chart
2. In the settings dialog:
   - **Telegram Bot Token:** Paste your Bot Token from Step 1
   - **Telegram Chat ID:** Paste your Chat ID from Step 2
   - **Enable Telegram Notifications:** `true`
   - Configure other options as needed:
     - `Notify BUY Trades`: Enable/disable buy notifications
     - `Notify SELL Trades`: Enable/disable sell notifications
     - `Notify Order Modifications`: Enable/disable modification alerts
     - `Notify Order Closes`: Enable/disable close alerts

3. Click **OK**

## Step 6: Test the Connection

1. In the **Experts** tab at the bottom, check for initialization messages
2. If configured correctly, you should see: "MT5 Telegram Notifier initialized successfully"
3. To send a test message, press F3 to open Strategy Tester or use this code in Experts tab:

```mql5
// Quick test - paste in a script or use EA's test function
SendTestMessage();
```

## Troubleshooting

| Error | Solution |
|-------|----------|
| "WebRequest failed. Error: 4060" | Add `https://api.telegram.org` to WebRequest allowed URLs |
| "Please set your Bot Token and Chat ID" | Enter correct values in EA input parameters |
| "HTTP 400: Bad Request" | Check Bot Token format is correct |
| "HTTP 401: Unauthorized" | Bot Token is invalid, get new one from @BotFather |
| "HTTP 403: Forbidden" | Chat ID is wrong or bot is blocked |

## Message Format

The bot sends notifications in this format:

```
🟢 TRADE EXECUTED (BUY)
━━━━━━━━━━━━━━━━━━
📊 Pair: EURUSD
📦 Lot: 0.10
💰 Open Price: 1.08500
🛑 Stop Loss: 1.08200
🎯 Take Profit: 1.09000
⏰ Time: 2026.07.23 22:15:00
━━━━━━━━━━━━━━━━━━
```

## Notes

- The EA must be attached to a chart to work
- Keep the EA running at all times for continuous monitoring
- For VPS, ensure MT5 is running with auto-trading enabled
- The EA uses minimal resources and won't affect trading performance
