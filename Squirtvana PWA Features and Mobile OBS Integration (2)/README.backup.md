# Squirtvana PWA - Mobile Streaming Control Center

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![React](https://img.shields.io/badge/React-18.3.1-blue)
![Vite](https://img.shields.io/badge/Vite-6.0-purple)
![Python Flask](https://img.shields.io/badge/Flask-3.1.1-green)
![PWA Ready](https://img.shields.io/badge/PWA-Ready-brightgreen)
![Mobile Friendly](https://img.shields.io/badge/Mobile-Friendly-success)

A powerful **Progressive Web App (PWA)** for mobile streaming control and AI-powered content generation. Control your OBS streams, generate AI content, and monitor system performance directly from your mobile device.

## ✨ Features

### 🎯 Core Features
- 🧠 **GPT DirtyTalk Generator** - AI-powered content generation using OpenRouter API
- 🎵 **Text-to-Speech** - ElevenLabs integration for realistic voice output  
- 📹 **OBS Integration** - Scene switching and stream control
- 📊 **System Monitoring** - Real-time CPU, RAM, and disk usage
- 📱 **PWA Support** - Installable on iOS and Android devices
- 🎨 **Modern UI** - Tailwind CSS with glassmorphism effects
- 🔔 **Telegram Bot** - Stream notifications and alerts
- 🌐 **Offline Ready** - Service Worker support for offline functionality

## Tech Stack

- **React 18** - Modern React with hooks
- **Vite** - Fast build tool and dev server
- **Tailwind CSS** - Utility-first CSS framework
- **Lucide React** - Beautiful icon library
- **PWA** - Progressive Web App capabilities

## Development

### Prerequisites

- Node.js 18+ 
- npm or pnpm

### Installation

```bash
# Install dependencies
npm install
# or
pnpm install
```

### Development Server

```bash
# Start development server
npm run dev
# or
pnpm run dev
```

The app will be available at `http://localhost:5174`

### Build for Production

```bash
# Build for production
npm run build
# or
pnpm run build
```

Built files will be in the `dist/` directory.

### Preview Production Build

```bash
# Preview production build
npm run preview
# or
pnpm run preview
```

## Project Structure

```
src/
├── components/
│   └── ui/           # Reusable UI components
│       ├── button.jsx
│       ├── card.jsx
│       ├── select.jsx
│       └── textarea.jsx
├── lib/
│   └── utils.js      # Utility functions and API calls
├── App.jsx           # Main application component
├── main.jsx          # React entry point
└── index.css         # Global styles and Tailwind imports
```

## API Integration

The frontend communicates with the Flask backend via REST API:

- **Base URL**: `http://localhost:5000/api` (development)
- **Production**: `/api` (relative URLs)

### API Endpoints

- `GET /health` - Backend health check
- `POST /gpt/generate` - Generate AI content
- `POST /audio/generate` - Generate speech audio
- `POST /audio/test-voice` - Test voice output
- `POST /obs/change-scene` - Change OBS scene
- `POST /stream/start` - Start streaming
- `POST /stream/stop` - Stop streaming
- `GET /system/stats` - Get system statistics

## PWA Features

- **Installable** - Can be installed on mobile home screen
- **Responsive** - Optimized for mobile and desktop
- **Offline Ready** - Basic offline functionality
- **Touch Optimized** - 44px minimum touch targets

## Styling

- **Dark Theme** - Purple/blue gradient background
- **Glassmorphism** - Translucent cards with backdrop blur
- **Mobile First** - Responsive design for all screen sizes
- **Touch Friendly** - Large buttons and touch targets

## Configuration

### Environment Variables

The app automatically detects the environment:

- **Development**: Uses `http://localhost:5000/api`
- **Production**: Uses relative `/api` URLs

### Customization

- **Colors**: Edit `tailwind.config.js` and CSS variables in `index.css`
- **API Base URL**: Modify `API_BASE_URL` in `src/lib/utils.js`
- **PWA Settings**: Edit `public/manifest.json`

## Deployment

### Static Hosting

1. Build the project: `npm run build`
2. Deploy the `dist/` folder to any static hosting service
3. Ensure the backend API is accessible

### Integration with Backend

For integrated deployment with the Flask backend:

1. Build the frontend: `npm run build`
2. Copy `dist/*` to the Flask `static/` directory
3. The Flask app will serve the frontend at the root URL

## Browser Support

- **Modern Browsers**: Chrome 90+, Firefox 88+, Safari 14+
- **Mobile**: iOS Safari 14+, Chrome Mobile 90+
- **PWA**: Supported on all modern mobile browsers

## License

MIT License - see LICENSE file for details

