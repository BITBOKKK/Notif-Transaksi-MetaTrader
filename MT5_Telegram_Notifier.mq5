//+------------------------------------------------------------------+
//|                                      MT5_Telegram_Notifier.mq5   |
//|                        MetaTrader 5 to Telegram Notification Bot  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "MT5 Telegram Notifier"
#property link      ""
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>

//--- Input Parameters
input string   InpBotToken    = ""; // Telegram Bot Token
input string   InpChatID      = "";            // Telegram Chat ID
input bool     InpEnableAlert = true;                   // Enable Telegram Notifications
input bool     InpShowBuy     = true;                   // Notify BUY Trades
input bool     InpShowSell    = true;                   // Notify SELL Trades
input bool     InpShowModify  = false;                  // Notify Order Modifications
input bool     InpShowClose   = false;                  // Notify Order Closes

//--- Global Variables
CTrade         trade;
CPositionInfo  posInfo;
string         lastError = "";
int            msgCount = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit()
{
   if(!InpEnableAlert)
   {
      Print("Telegram notifications are DISABLED");
      return(INIT_SUCCEEDED);
   }
   
   if(InpBotToken == "" || InpChatID == "")
   {
      Print("ERROR: Please set your Bot Token and Chat ID in inputs!");
      Alert("MT5 Telegram Notifier: Please configure Bot Token and Chat ID!");
      return(INIT_FAILED);
   }
   
   Print("MT5 Telegram Notifier initialized successfully");
   Print("Bot Token: ", StringSubstr(InpBotToken, 0, 10), "...");
   Print("Chat ID: ", InpChatID);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                    |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("MT5 Telegram Notifier deinitialized. Total messages sent: ", msgCount);
}

//+------------------------------------------------------------------+
//| Expert tick function                                               |
//+------------------------------------------------------------------+
void OnTick()
{
   // This EA works via OnTradeTransaction event handler
}

//+------------------------------------------------------------------+
//| Trade transaction handler                                          |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
{
   if(!InpEnableAlert) return;
   
   // Only process deal additions (executed trades)
   if(trans.type != TRADE_TRANSACTION_DEAL_ADD) return;
   
   // Get deal info
   if(!HistoryDealSelect(trans.deal))
   {
      Print("Failed to select deal #", trans.deal);
      return;
   }
   
   long dealEntry = HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
   string dealSymbol = HistoryDealGetString(trans.deal, DEAL_SYMBOL);
   long dealType = HistoryDealGetInteger(trans.deal, DEAL_TYPE);
   double dealVolume = HistoryDealGetDouble(trans.deal, DEAL_VOLUME);
   double dealPrice = HistoryDealGetDouble(trans.deal, DEAL_PRICE);
   datetime dealTime = (datetime)HistoryDealGetInteger(trans.deal, DEAL_TIME);
   long dealMagic = HistoryDealGetInteger(trans.deal, DEAL_MAGIC);
   string dealComment = HistoryDealGetString(trans.deal, DEAL_COMMENT);
   long dealPositionId = HistoryDealGetInteger(trans.deal, DEAL_POSITION_ID);
   
   // Only process market entries (not exits or balance operations)
   if(dealEntry != DEAL_ENTRY_IN) return;
   
   // Determine action type
   string actionType = "";
   if(dealType == DEAL_TYPE_BUY)
   {
      if(!InpShowBuy) return;
      actionType = "BUY";
   }
   else if(dealType == DEAL_TYPE_SELL)
   {
      if(!InpShowSell) return;
      actionType = "SELL";
   }
   else
   {
      return; // Not a buy or sell
   }
   
   // Get SL and TP from the position
   double sl = 0.0;
   double tp = 0.0;
   
   if(PositionSelectByTicket(dealPositionId))
   {
      sl = PositionGetDouble(POSITION_SL);
      tp = PositionGetDouble(POSITION_TP);
   }
   
   // Format and send message
   string message = FormatTradeMessage(actionType, dealSymbol, dealVolume, 
                                       dealPrice, sl, tp, dealTime, dealComment);
   
   if(SendTelegramMessage(message))
   {
      msgCount++;
      Print("Trade notification sent: ", actionType, " ", dealSymbol, " ", dealVolume);
   }
   else
   {
      Print("Failed to send notification: ", lastError);
   }
}

//+------------------------------------------------------------------+
//| Format trade message for Telegram                                  |
//+------------------------------------------------------------------+
string FormatTradeMessage(string action, string symbol, double volume,
                          double price, double sl, double tp, 
                          datetime time, string comment)
{
   string msg = "";
   
   // Header with emoji based on action
   if(action == "BUY")
      msg += "🟢 ";
   else
      msg += "🔴 ";
   
   msg += "<b>TRADE EXECUTED (" + action + ")</b>\n";
   msg += "━━━━━━━━━━━━━━━━━━\n";
   
   // Symbol/Pair
   msg += "📊 <b>Pair:</b> " + symbol + "\n";
   
   // Volume/Lot
   msg += "📦 <b>Lot:</b> " + DoubleToString(volume, 2) + "\n";
   
   // Open Price
   msg += "💰 <b>Open Price:</b> " + DoubleToString(price, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)) + "\n";
   
   // Stop Loss
   if(sl > 0)
      msg += "🛑 <b>Stop Loss:</b> " + DoubleToString(sl, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)) + "\n";
   else
      msg += "🛑 <b>Stop Loss:</b> Not Set\n";
   
   // Take Profit
   if(tp > 0)
      msg += "🎯 <b>Take Profit:</b> " + DoubleToString(tp, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)) + "\n";
   else
      msg += "🎯 <b>Take Profit:</b> Not Set\n";
   
   // Timestamp
   msg += "⏰ <b>Time:</b> " + TimeToString(time, TIME_DATE|TIME_SECONDS) + "\n";
   
   msg += "━━━━━━━━━━━━━━━━━━\n";
   
   return msg;
}

//+------------------------------------------------------------------+
//| Send message to Telegram via WebRequest                            |
//+------------------------------------------------------------------+
bool SendTelegramMessage(string message)
{
   string url = "https://api.telegram.org/bot" + InpBotToken + "/sendMessage";
   
   // Prepare JSON payload
   string json = "{";
   json += "\"chat_id\":\"" + InpChatID + "\",";
   json += "\"text\":\"" + EscapeJSON(message) + "\",";
   json += "\"parse_mode\":\"HTML\",";
   json += "\"disable_web_page_preview\":true";
   json += "}";
   
   // Setup headers
   string headers = "Content-Type: application/json\r\n";
   
   // Prepare request
   char data[];
   char result[];
   string resultHeaders;
   
   int dataSize = StringToCharArray(json, data, 0, WHOLE_ARRAY, CP_UTF8);
   ArrayResize(data, dataSize - 1); // Remove null terminator
   
   // Send request
   int res = WebRequest("POST", url, headers, 5000, data, result, resultHeaders);
   
   if(res == -1)
   {
      int error = GetLastError();
      lastError = "WebRequest failed. Error: " + IntegerToString(error);
      
      if(error == 4060)
         lastError += " (Add https://api.telegram.org to Tools > Options > Expert Advisors > Allow WebRequest)";
      
      Print(lastError);
      return false;
   }
   
   if(res != 200)
   {
      string response = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
      lastError = "HTTP " + IntegerToString(res) + ": " + response;
      Print(lastError);
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Escape special characters for JSON                                  |
//+------------------------------------------------------------------+
string EscapeJSON(string text)
{
   string result = text;
   
   StringReplace(result, "\\", "\\\\");
   StringReplace(result, "\"", "\\\"");
   StringReplace(result, "\n", "\\n");
   StringReplace(result, "\r", "\\r");
   StringReplace(result, "\t", "\\t");
   
   return result;
}

//+------------------------------------------------------------------+
//| Test function - Send test message                                   |
//+------------------------------------------------------------------+
void SendTestMessage()
{
   string testMsg = "✅ <b>MT5 Telegram Notifier Active</b>\n";
   testMsg += "━━━━━━━━━━━━━━━━━━\n";
   testMsg += "📊 <b>Status:</b> Connected\n";
   testMsg += "⏰ <b>Time:</b> " + TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS) + "\n";
   testMsg += "━━━━━━━━━━━━━━━━━━\n";
   testMsg += "Bot is ready to receive trade notifications!";
   
   if(SendTelegramMessage(testMsg))
      Print("Test message sent successfully!");
   else
      Print("Failed to send test message: ", lastError);
}
//+------------------------------------------------------------------+
