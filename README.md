# Occamy 1.0 + Open WebUI + Open Terminal (Windows 7 / 10 / 11)

Windows 7 (64-bit), Windows 10 ve Windows 11 üzerinde **Occamy 1.0 (agent.gguf)** modelini, **Open WebUI** arayüzünü ve **Open Terminal** eklentisini tek tıkla kurup çalıştıran taşınabilir pakettir.

---

## 💻 Sistem Gereksinimleri

* **İşletim Sistemi:** Windows 7 SP1 (64-bit - KB3063858 yüklü), Windows 10 veya Windows 11
* **RAM:** En az 16 GB (32 GB ve üzeri önerilir)
* **Ekran Kartı (VRAM):** En az 8 GB NVIDIA GPU (Hibrit CPU+GPU MoE desteği mevcuttur)
* **Depolama:** En az 30 GB boş disk alanı (`agent.gguf` modeli ~21.4 GB yer kaplar)

---

## 🚀 Kurulum ve Başlatma

1. **Releases** bölümünden tam paketi (`.rar`) indirin ve boş bir klasöre (örneğin `C:\Occamy-AI`) çıkarın.
2. **`Kurulum_ve_Baslat.bat`** dosyasına sağ tıklayıp **"Yönetici olarak çalıştır"** seçeneğini seçin.
   * *Script otomatik olarak:* Windows 7 ise **VxKex** ve **Python 3.11.18** kurulumlarını yapar, sanal ortamı (`OpenWebUI\env`) uyarlar, **Occamy 1.0 (`agent.gguf`)** modelini indirir ve 3 terminali birden başlatır.
   * *(Not: Temiz Windows 7'de VxKex ilk kez kurulduysa bilgisayarı yeniden başlatıp `Kurulum_ve_Baslat.bat` dosyasını tekrar çalıştırın.)*
3. Kurulum tamamlandıktan sonraki günlük kullanımlarda doğrudan **`Baslat.bat`** dosyasına çift tıklayarak sistemi başlatabilirsiniz.

---

## ⚙️ Open WebUI Yapılandırması

Sistem açıldıktan sonra tarayıcınızdan **`http://localhost:8080`** adresine girip yerel yönetici hesabınızı oluşturun ve aşağıdaki iki ayarı yapın:

### 1. Open Terminal Bağlantısını Açma
1. Sol alt köşedeki profil simgenize tıklayın -> **Yönetici Paneli (Admin Panel)** -> **Ayarlar (Settings)** -> **Entegrasyonlar (Integrations)** sekmesine girin.
2. **Open Terminal** bölümünde **`+`** butonuna tıklayın ve bilgileri girin:
   * **URL:** `http://127.0.0.1:8000`
   * **API Key:** `Baslat.bat` dosyasındaki `OPEN_TERMINAL_KEY` değeri (varsayılan: `BURAYA_ANAHTAR_GIRIN` — güvenlik için kendi şifrenizle değiştirmeniz önerilir)
   * **Auth:** `Bearer`
3. **Kaydet (Save)** butonuna basın.

### 2. Web Aramasını (Web Search) Açma
1. **Yönetici Paneli (Admin Panel)** -> **Ayarlar (Settings)** -> **Web Araması (Web Search)** bölümüne girin.
2. **Web Aramasını Etkinleştir (Enable Web Search)** anahtarını açık konuma getirin.
3. **Arama Motoru (Web Search Engine)** olarak ücretsiz ve API anahtarı gerektirmeyen **`duckduckgo`** (veya kendi anahtarınızla `tavily` / `google_pse` / `searxng`) seçeneğini seçin.
4. Sağ alttan **Kaydet (Save)** butonuna basın. Sohbet ekranındaki **`+` (veya Web)** simgesinden web aramasını aktif ederek kullanabilirsiniz.

---

## 📁 Klasör Yapısı

* `Kurulum_ve_Baslat.bat` — Eksik bağımlılıkları (VxKex, Python 3.11, venv, model) kuran ana kurucu
* `Baslat.bat` — Llama-Server (`11434`), Open WebUI (`8080`) ve Open Terminal (`8000`) servislerini başlatır
* `llama-cpp-7/` — Vulkan/CUDA destekli `llama-server` motoru
* `OpenWebUI/` — Web arayüzü ve Python sanal ortamı
* `models/` — İndirilen `agent.gguf` modelinin bulunduğu klasör
* `WORKSPACE/` — Open Terminal'in çalıştığı güvenli çalışma dizini
