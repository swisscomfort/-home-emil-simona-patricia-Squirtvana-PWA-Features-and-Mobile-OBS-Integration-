# Squirtvana PWA - Mobile Streaming Control Center# Squirtvana PWA - Mobile Streaming Control Center



![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

![React](https://img.shields.io/badge/React-18.3.1-blue)![React](https://img.shields.io/badge/React-18.3.1-blue)

![Vite](https://img.shields.io/badge/Vite-6.0-purple)![Vite](https://img.shields.io/badge/Vite-6.0-purple)

![Python Flask](https://img.shields.io/badge/Flask-3.1.1-green)![Python Flask](https://img.shields.io/badge/Flask-3.1.1-green)

![PWA Ready](https://img.shields.io/badge/PWA-Ready-brightgreen)![PWA Ready](https://img.shields.io/badge/PWA-Ready-brightgreen)

![Mobile Friendly](https://img.shields.io/badge/Mobile-Friendly-success)

A powerful **Progressive Web App (PWA)** for mobile streaming control and AI-powered content generation. Control your OBS streams, generate AI content, and monitor system performance directly from your mobile device.

A powerful **Progressive Web App (PWA)** for mobile streaming control and AI-powered content generation. Control your OBS streams, generate AI content, and monitor system performance directly from your mobile device.

## ✨ Features

## ✨ Features

### 🎯 Core Features

### 🎯 Core Features

- 🧠 **GPT Content Generator** - AI-powered content generation using OpenRouter API- 🧠 **GPT DirtyTalk Generator** - AI-powered content generation using OpenRouter API

- 🎵 **Text-to-Speech** - ElevenLabs integration for realistic voice output- 🎵 **Text-to-Speech** - ElevenLabs integration for realistic voice output  

- 📹 **OBS Integration** - Real-time scene switching and stream control- 📹 **OBS Integration** - Scene switching and stream control

- 📊 **System Monitoring** - Live CPU, RAM, and disk usage tracking- 📊 **System Monitoring** - Real-time CPU, RAM, and disk usage

- 📱 **PWA Support** - Installable on iOS and Android devices- 📱 **PWA Support** - Installable on iOS and Android devices

- 🎨 **Modern UI** - Tailwind CSS with glassmorphism effects- 🎨 **Modern UI** - Tailwind CSS with glassmorphism effects

- 🔔 **Telegram Bot** - Stream notifications and alerts- 🔔 **Telegram Bot** - Stream notifications and alerts

- 🌐 **Offline Ready** - Service Worker support for offline functionality- 🌐 **Offline Ready** - Service Worker support for offline functionality



## 📚 Tech Stack## Tech Stack



### Frontend- **React 18** - Modern React with hooks

- **React 18** - Modern UI library with hooks- **Vite** - Fast build tool and dev server

- **Vite 6** - Next-generation build tool with fast refresh- **Tailwind CSS** - Utility-first CSS framework

- **Tailwind CSS** - Utility-first CSS framework- **Lucide React** - Beautiful icon library

- **Lucide React** - Beautiful icon library- **PWA** - Progressive Web App capabilities

- **PWA** - Progressive Web App capabilities

## Development

### Backend

- **Python 3.8+** - Server runtime### Prerequisites

- **Flask 3.1** - Web framework

- **Flask-CORS** - Cross-origin resource sharing- Node.js 18+ 

- **requests** - HTTP client library- npm or pnpm



### External APIs### Installation

- **OpenRouter** - GPT/Claude model access

- **ElevenLabs** - Text-to-speech synthesis```bash

- **Telegram Bot API** - Notifications# Install dependencies

- **OBS WebSocket** - Stream controlnpm install

# or

## 🚀 Quick Startpnpm install

```

### Prerequisites

### Development Server

- **Node.js** 18+

- **Python** 3.8+```bash

- **npm** or **pnpm**# Start development server

npm run dev

### Installation# or

pnpm run dev

#### 1. Clone Repository```



```bashThe app will be available at `http://localhost:5174`

git clone https://github.com/yourusername/squirtvana.git

cd squirtvana### Build for Production

```

```bash

#### 2. Setup Frontend# Build for production

npm run build

```bash# or

# Install dependenciespnpm run build

npm install```



# Create environment fileBuilt files will be in the `dist/` directory.

cp .env.example .env

### Preview Production Build

# Edit .env with your API keys

nano .env```bash

```# Preview production build

npm run preview

#### 3. Setup Backend# or

pnpm run preview

```bash```

# Create virtual environment

python3 -m venv venv## Project Structure

source venv/bin/activate  # Windows: venv\Scripts\activate

```

# Install dependenciessrc/

pip install -r requirements.txt├── components/

```│   └── ui/           # Reusable UI components

│       ├── button.jsx

### Development│       ├── card.jsx

│       ├── select.jsx

#### Start Frontend (Terminal 1)│       └── textarea.jsx

├── lib/

```bash│   └── utils.js      # Utility functions and API calls

npm run dev├── App.jsx           # Main application component

```├── main.jsx          # React entry point

└── index.css         # Global styles and Tailwind imports

Frontend available at: `http://localhost:5174````



#### Start Backend (Terminal 2)## API Integration



```bashThe frontend communicates with the Flask backend via REST API:

source venv/bin/activate

python app.py- **Base URL**: `http://localhost:5000/api` (development)

```- **Production**: `/api` (relative URLs)



Backend available at: `http://localhost:5000`### API Endpoints



### Production Build- `GET /health` - Backend health check

- `POST /gpt/generate` - Generate AI content

```bash- `POST /audio/generate` - Generate speech audio

# Build frontend- `POST /audio/test-voice` - Test voice output

npm run build- `POST /obs/change-scene` - Change OBS scene

- `POST /stream/start` - Start streaming

# Preview production build- `POST /stream/stop` - Stop streaming

npm run preview- `GET /system/stats` - Get system statistics

```

## PWA Features

Built files in `dist/` directory.

- **Installable** - Can be installed on mobile home screen

## 📁 Project Structure- **Responsive** - Optimized for mobile and desktop

- **Offline Ready** - Basic offline functionality

```- **Touch Optimized** - 44px minimum touch targets

squirtvana/

├── public/## Styling

│   ├── index.html              # PWA entry point

│   ├── manifest.json           # PWA configuration- **Dark Theme** - Purple/blue gradient background

│   └── icons/                  # App icons- **Glassmorphism** - Translucent cards with backdrop blur

├── src/- **Mobile First** - Responsive design for all screen sizes

│   ├── components/- **Touch Friendly** - Large buttons and touch targets

│   │   └── ui/                 # Reusable UI components

│   │       ├── button.jsx## Configuration

│   │       ├── card.jsx

│   │       ├── select.jsx### Environment Variables

│   │       └── textarea.jsx

│   ├── lib/The app automatically detects the environment:

│   │   ├── utils.js            # API utilities

│   │   └── api.js              # API client- **Development**: Uses `http://localhost:5000/api`

│   ├── App.jsx                 # Main app component- **Production**: Uses relative `/api` URLs

│   ├── main.jsx                # React entry point

│   └── styles/                 # CSS styles### Customization

├── app.py                      # Flask backend

├── requirements.txt            # Python packages- **Colors**: Edit `tailwind.config.js` and CSS variables in `index.css`

├── package.json                # Node packages- **API Base URL**: Modify `API_BASE_URL` in `src/lib/utils.js`

├── vite.config.js              # Vite configuration- **PWA Settings**: Edit `public/manifest.json`

├── tailwind.config.js          # Tailwind configuration

├── .env.example                # Environment template## Deployment

├── .gitignore                  # Git ignore rules

├── LICENSE                     # MIT License### Static Hosting

└── README.md                   # This file

```1. Build the project: `npm run build`

2. Deploy the `dist/` folder to any static hosting service

## 🔧 Configuration3. Ensure the backend API is accessible



### Environment Variables### Integration with Backend



Copy `.env.example` to `.env` and fill in your credentials:For integrated deployment with the Flask backend:



```env1. Build the frontend: `npm run build`

# OpenRouter API (GPT/Claude)2. Copy `dist/*` to the Flask `static/` directory

VITE_OPENROUTER_KEY=sk-or-v1-xxxxx3. The Flask app will serve the frontend at the root URL



# ElevenLabs (Text-to-Speech)## Browser Support

VITE_ELEVENLABS_KEY=sk_xxxxx

VITE_ELEVENLABS_VOICE_ID=xxxxx- **Modern Browsers**: Chrome 90+, Firefox 88+, Safari 14+

- **Mobile**: iOS Safari 14+, Chrome Mobile 90+

# Telegram Bot- **PWA**: Supported on all modern mobile browsers

VITE_TELEGRAM_API_KEY=xxxxx

## License

# Backend

FLASK_API_URL=http://localhost:5000MIT License - see LICENSE file for details

FLASK_ENV=development

```

**⚠️ IMPORTANT:** Never commit `.env` file with real API keys!

### API Endpoints

#### Backend Routes

- `GET /api/health` - Health check
- `POST /api/gpt/generate` - Generate content
- `POST /api/audio/generate` - Generate speech
- `POST /api/obs/change-scene` - Change OBS scene
- `POST /api/stream/start` - Start stream
- `POST /api/stream/stop` - Stop stream
- `GET /api/system/stats` - System stats

## 📱 PWA Installation

### iOS Safari

1. Open app in Safari
2. Tap **Share** → **Add to Home Screen**
3. Confirm installation

### Android Chrome

1. Open app in Chrome
2. Tap **Menu** (⋮) → **Install app**
3. Confirm installation

## 🍎 Apple App Store Distribution

This PWA can be distributed via:

1. **Web App Wrapper** - Xcode wrapper for App Store
2. **Enterprise Distribution** - Internal iOS app
3. **Web Clip** - Direct Safari bookmark

See [APPLE_STORE_GUIDE.md](./APPLE_STORE_GUIDE.md) for detailed steps.

## 🔐 Security

### Best Practices

- ✅ Use environment variables for secrets
- ✅ Never hardcode API keys
- ✅ Rotate credentials regularly
- ✅ Use HTTPS in production
- ✅ Enable CORS properly
- ✅ Validate inputs server-side
- ✅ Implement rate limiting

### Sensitive Data

- API keys stored in `.env` (never commit)
- Use `.env.example` as template
- Implement secret rotation
- Monitor API usage

## 🤝 Contributing

We welcome contributions! Please:

1. **Fork the repository**
2. **Create feature branch** - `git checkout -b feature/my-feature`
3. **Commit changes** - `git commit -m 'Add my feature'`
4. **Push branch** - `git push origin feature/my-feature`
5. **Open Pull Request**

### Guidelines

- Follow existing code style
- Write clear commit messages
- Test before submitting
- Update documentation

## 📄 License

MIT License - see [LICENSE](./LICENSE) file for details.

## 🆘 Troubleshooting

### Frontend Issues

**App won't start**
```bash
# Clear cache and reinstall
rm -rf node_modules package-lock.json
npm install
npm run dev
```

**Port already in use**
```bash
# Use different port
npm run dev -- --port 5175
```

### Backend Issues

**ModuleNotFoundError**
```bash
# Reinstall dependencies
pip install -r requirements.txt
```

**Port conflict**
```bash
# Use different port
python app.py --port 5001
```

## 📊 Performance

- ⚡ **Build Time:** <200ms (Vite)
- 📱 **Mobile:** 100% responsive
- 🔐 **Security:** Environment-based secrets
- ♿ **Accessibility:** WCAG 2.1 compatible

## 🚀 Roadmap

- [ ] Multi-language support
- [ ] Dark/Light theme toggle
- [ ] Advanced analytics
- [ ] Community templates
- [ ] Native iOS app (via Xcode)
- [ ] Native Android app (React Native)
- [ ] Desktop app (Electron)

## 👥 Authors

- **Squirtvana Team** - Initial development

## 📞 Support

- 📖 [Documentation](./APPLE_STORE_GUIDE.md)
- 🐛 [Report Issues](https://github.com/yourusername/squirtvana/issues)
- 💬 [Start Discussion](https://github.com/yourusername/squirtvana/discussions)

---

**Made with ❤️ by Squirtvana**

[⬆ Back to Top](#squirtvana-pwa---mobile-streaming-control-center)
