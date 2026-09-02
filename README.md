# Notif-Transaksi-MetaTrader

Expert Advisor (EA) MetaTrader 5 yang mengirim notifikasi real-time ke Telegram setiap kali ada eksekusi trade (BUY/SELL). EA memberitahukan detail order — simbol, lot, harga pembukaan, Stop Loss, Take Profit, dan waktu eksekusi — langsung ke chat Telegram tanpa perlu memantau terminal.

## Fitur

- Deteksi eksekusi order otomatis via `OnTradeTransaction()`
- Notifikasi Telegram berformat HTML dengan emoji (🟢 BUY / 🔴 SELL)
- Parameter lengkap: Pair, Lot, Open Price, Stop Loss, Take Profit, Timestamp
- Menggunakan `WebRequest()` bawaan MT5 — tanpa dependensi DLL
- Toggle notifikasi (BUY / SELL) via input EA

## File

| File | Deskripsi |
|------|-----------|
| `MT5_Telegram_Notifier.mq5` | Versi lengkap (disarankan) — input toggle BUY/SELL, handling error lengkap (termasuk peringatan error 4060 WebRequest), escaping JSON, deteksi ulang SL/TP dari posisi |
| `MT5_Notif_Telegram.mq5` | Versi sederhana/minimalis — hanya deteksi entry baru dan kirim pesan, tanpa toggle dan handling error lanjutan |
| `SETUP_GUIDE.md` | Panduan setup lengkap (BotFather, Chat ID, WebRequest) |

Kedua file adalah EA dengan fungsi sama (kirim notifikasi trade ke Telegram), hanya beda tingkat kelengkapan. Saat instalasi, **gunakan salah satu saja** — disarankan `MT5_Telegram_Notifier.mq5`.

## Instalasi Singkat

1. Buat bot di Telegram via `@BotFather` → `/newbot`, salin Bot Token.
2. Cari Chat ID via `@userinfobot`.
3. Salin file `.mq5` ke folder `MQL5\Experts` milik terminal MT5.
4. Aktifkan **Allow WebRequest** dan tambahkan `https://api.telegram.org` di `Tools → Options → Expert Advisors`.
5. Attach EA ke chart, isi **Token** dan **Chat ID** pada input, klik OK.

> **Keamanan:** jangan pernah menaruh Bot Token asli di dalam source code. Isi nilai `InpBotToken` / `InpChatID` saat attach EA.

Detail lengkap: lihat [SETUP_GUIDE.md](SETUP_GUIDE.md).

## Prasyarat

- MetaTrader 5 (Windows / VPS)
- Akun Telegram dengan akses BotFather

## Contoh Notif
<img width="612" height="800" alt="image" src="https://github.com/user-attachments/assets/6329fa34-6501-4711-b8ff-2ce6e060434f" />
