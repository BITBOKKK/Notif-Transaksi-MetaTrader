//+------------------------------------------------------------------+
//|                                      MT5_Telegram_Notifier.mq5   |
//|                                  Copyright 2026                  |
//|                                      https://www.mql5.com        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026"
#property link      "https://www.mql5.com"
#property version   "1.00"

// --- INPUT PARAMETERS ---
input string InpBotToken = ""; // Token Bot Telegram dari BotFather
input string InpChatID   = "";                  // Chat ID Telegram Anda

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("MT5 Telegram Notifier Berhasil Dimulai.");
   // Kirim pesan uji coba saat EA dipasang
   SendTelegramMessage(InpBotToken, InpChatID, "🟢 <b>MT5 Telegram Notifier Berhasil Terhubung!</b>");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("MT5 Telegram Notifier Dimatikan.");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Tidak digunakan karena kita memakai OnTradeTransaction
}

//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
{
   // Deteksi ketika ada transaksi order baru yang masuk ke market
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
   {
      ulong deal_ticket = trans.deal;
      if(HistoryDealSelect(deal_ticket))
      {
         long deal_entry = HistoryDealGetInteger(deal_ticket, DEAL_ENTRY);
         
         // Pastikan ini adalah transaksi buka posisi (DEAL_ENTRY_IN)
         if(deal_entry == DEAL_ENTRY_IN)
         {
            string symbol   = HistoryDealGetString(deal_ticket, DEAL_SYMBOL);
            long   type     = HistoryDealGetInteger(deal_ticket, DEAL_TYPE);
            double volume   = HistoryDealGetDouble(deal_ticket, DEAL_VOLUME);
            double price    = HistoryDealGetDouble(deal_ticket, DEAL_PRICE);
            double sl       = HistoryDealGetDouble(deal_ticket, DEAL_SL);
            double tp       = HistoryDealGetDouble(deal_ticket, DEAL_TP);
            datetime time   = (datetime)HistoryDealGetInteger(deal_ticket, DEAL_TIME);
            
            string type_str = (type == DEAL_TYPE_BUY) ? "BUY 🟢" : "SELL 🔴";
            
            // Susun format pesan HTML untuk Telegram
            string message = "<b>TRADE EXECUTED (" + type_str + ")</b>\n" +
                             "━━━━━━━━━━━━━━━━━\n" +
                             "📊 <b>Pair:</b> " + symbol + "\n" +
                             "📦 <b>Lot:</b> " + DoubleToString(volume, 2) + "\n" +
                             "💰 <b>Open Price:</b> " + DoubleToString(price, _Digits) + "\n" +
                             "🛑 <b>Stop Loss:</b> " + (sl > 0 ? DoubleToString(sl, _Digits) : "None") + "\n" +
                             "🎯 <b>Take Profit:</b> " + (tp > 0 ? DoubleToString(tp, _Digits) : "None") + "\n" +
                             "⏰ <b>Time:</b> " + TimeToString(time, TIME_DATE|TIME_MINUTES|TIME_SECONDS) + "\n" +
                             "━━━━━━━━━━━━━━━━━";
                             
            SendTelegramMessage(InpBotToken, InpChatID, message);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Fungsi untuk mengirim HTTP POST Request ke Telegram API          |
//+------------------------------------------------------------------+
bool SendTelegramMessage(string token, string chat_id, string message)
{
   string url = "https://api.telegram.org/bot" + token + "/sendMessage";
   string headers = "Content-Type: application/json\r\n";
   char post[], result[];
   
   // Format JSON untuk payload Telegram
   string data = "{\"chat_id\": \"" + chat_id + "\", \"text\": \"" + message + "\", \"parse_mode\": \"HTML\"}";
   
   StringToCharArray(data, post, 0, StringLen(data), CP_UTF8);
   
   ResetLastError();
   int res = WebRequest("POST", url, headers, 5000, post, result, headers);
   
   if(res != 200)
   {
      Print("Gagal mengirim pesan ke Telegram. Error code: ", GetLastError());
      return false;
   }
   return true;
}