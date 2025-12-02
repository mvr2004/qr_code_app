# 📱 QR Code App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-blue?style=for-the-badge)

**A modern, feature-rich QR Code management application built with Flutter**

[🇬🇧 English](#-english) • [🇵🇹 Português](#-português)

</div>

---

## 🎬 App Demo Video
Check out the app in action!

[![QR Code App Demo](https://img.youtube.com/vi/qtw561y2tVM/0.jpg)](https://youtu.be/qtw561y2tVM)

---

## 🇬🇧 English

### 📖 About

QR Code App is a comprehensive mobile application for managing QR Codes. Whether you need to scan existing codes, generate new ones, or organize your collection, this app provides an intuitive and elegant solution.

### ✨ Key Features

- **📸 QR Code Scanner**
  - Real-time camera scanning with visual guidance
  - Instant QR code recognition and parsing
  - Torch/flashlight toggle for low-light conditions
  - Automatic save functionality with color customization

- **🎨 QR Code Generator**
  - Create custom QR codes from text, URLs, and more
  - Choose from 12+ color themes
  - Custom titles and descriptions
  - Instant preview of generated codes

- **📚 Smart Library Management**
  - Save and organize all your QR codes
  - Advanced search with real-time filtering
  - Quick actions: copy, share, delete
  - Sort by creation date, title, or type

- **🎯 Intelligent Content Detection**
  - Automatic detection of content type (URL, email, phone, WiFi, etc.)
  - Context-aware actions for each type
  - One-tap actions (call, email, open link, connect to WiFi)

- **🌐 Multi-language Interface**
  - Full support for English and Portuguese
  - Easy language switching
  - All UI elements translated

- **🎨 Modern Design**
  - Material Design 3
  - Dark and Light theme support
  - Smooth animations and transitions
  - Color-coded QR codes for easy identification

### 🛠️ Technologies & Dependencies

#### Core Framework
- **Flutter 3.x** - Cross-platform UI framework
- **Dart 3.x** - Programming language

#### Key Packages

| Package | Purpose |
|---------|---------|
| `mobile_scanner` | QR code scanning via camera |
| `qr_flutter` | QR code generation and rendering |
| `shared_preferences` | Local data persistence |
| `provider` | State management |
| `url_launcher` | Open URLs, emails, phone numbers |
| `share_plus` | Share QR codes with other apps |

### 🚀 Getting Started

#### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode
- A physical device or emulator with camera support

#### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/qr-code-app.git
cd qr-code-app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

### 📋 Permissions

#### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" />
```

#### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan QR codes</string>
```

### 🗂️ Project Structure

```
lib/
├── models/
│   └── qr_code_item.dart        # QR Code data model
├── screens/
│   ├── home_screen.dart         # Main navigation
│   ├── qr_scanner_tab.dart      # Scanner interface
│   ├── qr_generator_tab.dart    # Generator interface
│   ├── qr_list_tab.dart         # Library view
│   └── qr_detail_screen.dart    # Detail view
├── services/
│   ├── storage_service.dart     # Local persistence
│   └── localization_service.dart # i18n support
├── widgets/
│   └── qr_content_widget.dart   # Smart content display
└── main.dart                     # App entry point
```

### 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

### 👨‍💻 Author

**Marco Vicente**

---

## 🇵🇹 Português

### 📖 Sobre

QR Code App é uma aplicação móvel completa para gestão de QR Codes. Seja para ler códigos existentes, gerar novos ou organizar a sua coleção, esta app oferece uma solução intuitiva e elegante.

### ✨ Funcionalidades Principais

- **📸 Leitor de QR Codes**
  - Leitura em tempo real com guia visual
  - Reconhecimento e análise instantânea
  - Lanterna integrada para ambientes escuros
  - Guardar automaticamente com personalização de cores

- **🎨 Gerador de QR Codes**
  - Crie QR codes personalizados a partir de texto, URLs e mais
  - Escolha entre mais de 12 cores
  - Títulos e descrições personalizadas
  - Pré-visualização instantânea

- **📚 Gestão Inteligente de Biblioteca**
  - Guarde e organize todos os seus QR codes
  - Pesquisa avançada com filtragem em tempo real
  - Ações rápidas: copiar, partilhar, eliminar
  - Ordenar por data, título ou tipo

- **🎯 Deteção Inteligente de Conteúdo**
  - Deteção automática do tipo de conteúdo (URL, email, telefone, WiFi, etc.)
  - Ações contextuais para cada tipo
  - Ações com um toque (ligar, enviar email, abrir link, conectar WiFi)

- **🌐 Interface Multi-idioma**
  - Suporte completo para Português e Inglês
  - Mudança fácil de idioma
  - Todos os elementos da UI traduzidos

- **🎨 Design Moderno**
  - Material Design 3
  - Suporte para tema escuro e claro
  - Animações e transições suaves
  - QR codes codificados por cores para fácil identificação

### 🛠️ Tecnologias e Dependências

#### Framework Base
- **Flutter 3.x** - Framework UI multiplataforma
- **Dart 3.x** - Linguagem de programação

#### Pacotes Principais

| Pacote | Finalidade |
|---------|---------|
| `mobile_scanner` | Leitura de QR codes via câmera |
| `qr_flutter` | Geração e renderização de QR codes |
| `shared_preferences` | Persistência local de dados |
| `provider` | Gestão de estado |
| `url_launcher` | Abrir URLs, emails, números de telefone |
| `share_plus` | Partilhar QR codes com outras apps |

### 🚀 Como Começar

#### Pré-requisitos
- Flutter SDK (3.0.0 ou superior)
- Dart SDK (3.0.0 ou superior)
- Android Studio / Xcode
- Dispositivo físico ou emulador com suporte para câmera

#### Instalação

1. **Clone o repositório**
```bash
git clone https://github.com/seuusuario/qr-code-app.git
cd qr-code-app
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Execute a aplicação**
```bash
flutter run
```

### 📋 Permissões

#### Android
Adicione ao `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" />
```

#### iOS
Adicione ao `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Esta aplicação precisa de acesso à câmera para ler QR codes</string>
```

### 🗂️ Estrutura do Projeto

```
lib/
├── models/
│   └── qr_code_item.dart        # Modelo de dados do QR Code
├── screens/
│   ├── home_screen.dart         # Navegação principal
│   ├── qr_scanner_tab.dart      # Interface do scanner
│   ├── qr_generator_tab.dart    # Interface do gerador
│   ├── qr_list_tab.dart         # Vista da biblioteca
│   └── qr_detail_screen.dart    # Vista de detalhes
├── services/
│   ├── storage_service.dart     # Persistência local
│   └── localization_service.dart # Suporte i18n
├── widgets/
│   └── qr_content_widget.dart   # Widget QR reutilizável
└── main.dart                     # Ponto de entrada da app
```

### 📄 Licença

Este projeto está licenciado sob a Licença MIT - consulte o arquivo LICENSE para detalhes.

### 👨‍💻 Autor

**Marco Vicente**

---

<div align="center">

RDS 2025

</div>