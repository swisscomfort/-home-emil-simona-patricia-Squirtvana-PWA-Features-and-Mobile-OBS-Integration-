import { useState, useEffect } from 'react'
import { Button } from '@/components/ui/button.jsx'
import { Input } from '@/components/ui/input.jsx'
import { Textarea } from '@/components/ui/textarea.jsx'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select.jsx'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card.jsx'
import { Badge } from '@/components/ui/badge.jsx'
import { Separator } from '@/components/ui/separator.jsx'
import { 
  Play, 
  Square, 
  Mic, 
  MessageSquare, 
  Video, 
  VideoOff, 
  Radio,
  Settings,
  Activity,
  Wifi,
  WifiOff,
  Volume2,
  Loader2,
  StopCircle
} from 'lucide-react'
import './App.css'

const API_BASE = '/api'

function App() {
  // State management
  const [prompt, setPrompt] = useState('')
  const [generatedText, setGeneratedText] = useState('')
  const [isGenerating, setIsGenerating] = useState(false)
  const [isGeneratingAudio, setIsGeneratingAudio] = useState(false)
  const [currentAudioUrl, setCurrentAudioUrl] = useState('')
  
  // OBS State
  const [scenes, setScenes] = useState([])
  const [currentScene, setCurrentScene] = useState('')
  const [selectedScene, setSelectedScene] = useState('')
  const [obsConnected, setObsConnected] = useState(false)
  
  // Stream State
  const [isStreaming, setIsStreaming] = useState(false)
  const [isRecording, setIsRecording] = useState(false)
  
  // System State
  const [systemStats, setSystemStats] = useState(null)
  const [telegramStatus, setTelegramStatus] = useState('unknown')
  const [gptStatus, setGptStatus] = useState('unknown')
  const [audioStatus, setAudioStatus] = useState('unknown')

  // Load initial data
  useEffect(() => {
    loadScenes()
    checkStatuses()
    const interval = setInterval(checkStatuses, 30000) // Check every 30 seconds
    return () => clearInterval(interval)
  }, [])

  // API Functions
  const apiCall = async (endpoint, options = {}) => {
    try {
      const response = await fetch(`${API_BASE}${endpoint}`, {
        headers: {
          'Content-Type': 'application/json',
          ...options.headers
        },
        ...options
      })
      return await response.json()
    } catch (error) {
      console.error('API call failed:', error)
      return { error: error.message }
    }
  }

  const generateDirtyTalk = async () => {
    if (!prompt.trim()) return
    
    setIsGenerating(true)
    const result = await apiCall('/gpt/generate', {
      method: 'POST',
      body: JSON.stringify({ prompt })
    })
    
    if (result.success) {
      setGeneratedText(result.generated_text)
      // Auto-update OBS text source
      await apiCall('/obs/text/update', {
        method: 'POST',
        body: JSON.stringify({ 
          source_name: 'DirtyTalk', 
          text: result.generated_text 
        })
      })
    }
    setIsGenerating(false)
  }

  const generateAudio = async (text = generatedText) => {
    if (!text.trim()) return
    
    setIsGeneratingAudio(true)
    const result = await apiCall('/audio/generate', {
      method: 'POST',
      body: JSON.stringify({ text })
    })
    
    if (result.success) {
      setCurrentAudioUrl(result.audio_url)
    }
    setIsGeneratingAudio(false)
  }

  const playAudio = () => {
    if (currentAudioUrl) {
      const audio = new Audio(`${window.location.origin}${currentAudioUrl}`)
      audio.play()
    }
  }

  const testVoice = async () => {
    setIsGeneratingAudio(true)
    const result = await apiCall('/audio/test', { method: 'POST' })
    
    if (result.success) {
      setCurrentAudioUrl(result.audio_url)
      setTimeout(() => {
        const audio = new Audio(`${window.location.origin}${result.audio_url}`)
        audio.play()
      }, 500)
    }
    setIsGeneratingAudio(false)
  }

  const loadScenes = async () => {
    const result = await apiCall('/obs/scenes')
    if (result.success) {
      setScenes(result.scenes)
      setCurrentScene(result.current_scene)
      setObsConnected(true)
    } else {
      setObsConnected(false)
    }
  }

  const switchScene = async () => {
    if (!selectedScene) return
    
    const result = await apiCall('/obs/scene/switch', {
      method: 'POST',
      body: JSON.stringify({ scene_name: selectedScene })
    })
    
    if (result.success) {
      setCurrentScene(selectedScene)
    }
  }

  const toggleStream = async () => {
    const endpoint = isStreaming ? '/stream/stop' : '/stream/start'
    const result = await apiCall(endpoint, { method: 'POST' })
    
    if (result.success) {
      setIsStreaming(!isStreaming)
    }
  }

  const toggleRecording = async () => {
    const endpoint = isRecording ? '/recording/stop' : '/recording/start'
    const result = await apiCall(endpoint, { method: 'POST' })
    
    if (result.success) {
      setIsRecording(!isRecording)
    }
  }

  const checkStatuses = async () => {
    // Check system stats
    const stats = await apiCall('/system/stats')
    if (stats.success) {
      setSystemStats(stats)
    }

    // Check Telegram status
    const telegram = await apiCall('/telegram/status')
    setTelegramStatus(telegram.status || 'error')

    // Check GPT status
    const gpt = await apiCall('/gpt/status')
    setGptStatus(gpt.status || 'error')

    // Check Audio status
    const audio = await apiCall('/audio/status')
    setAudioStatus(audio.status || 'error')

    // Check stream status
    const streamStatus = await apiCall('/stream/status')
    if (streamStatus.success) {
      setIsStreaming(streamStatus.streaming)
    }

    // Check recording status
    const recordingStatus = await apiCall('/recording/status')
    if (recordingStatus.success) {
      setIsRecording(recordingStatus.recording)
    }
  }

  const getStatusColor = (status) => {
    switch (status) {
      case 'active':
      case 'connected':
        return 'bg-green-500'
      case 'error':
      case 'disconnected':
        return 'bg-red-500'
      default:
        return 'bg-yellow-500'
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-900 via-black to-pink-900 text-white p-4">
      <div className="max-w-md mx-auto space-y-6">
        {/* Header */}
        <div className="text-center py-4">
          <h1 className="text-3xl font-bold bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">
            Squirtvana
          </h1>
          <p className="text-sm text-gray-300 mt-1">Mobile Control Center</p>
        </div>

        {/* Status Bar */}
        <Card className="bg-black/50 border-purple-500/30">
          <CardHeader className="pb-3">
            <CardTitle className="text-lg flex items-center gap-2">
              <Activity className="w-5 h-5" />
              System Status
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="grid grid-cols-2 gap-3">
              <div className="flex items-center gap-2">
                <div className={`w-2 h-2 rounded-full ${getStatusColor(obsConnected ? 'connected' : 'disconnected')}`}></div>
                <span className="text-sm">OBS</span>
              </div>
              <div className="flex items-center gap-2">
                <div className={`w-2 h-2 rounded-full ${getStatusColor(gptStatus)}`}></div>
                <span className="text-sm">GPT</span>
              </div>
              <div className="flex items-center gap-2">
                <div className={`w-2 h-2 rounded-full ${getStatusColor(audioStatus)}`}></div>
                <span className="text-sm">Audio</span>
              </div>
              <div className="flex items-center gap-2">
                <div className={`w-2 h-2 rounded-full ${getStatusColor(telegramStatus)}`}></div>
                <span className="text-sm">Telegram</span>
              </div>
            </div>
            
            {systemStats && (
              <div className="text-xs text-gray-400 pt-2 border-t border-gray-700">
                CPU: {systemStats.cpu.usage_percent}% | 
                RAM: {systemStats.memory.usage_percent}% | 
                Disk: {systemStats.disk.usage_percent}%
              </div>
            )}
          </CardContent>
        </Card>

        {/* GPT DirtyTalk Generation */}
        <Card className="bg-black/50 border-purple-500/30">
          <CardHeader>
            <CardTitle className="text-lg flex items-center gap-2">
              <MessageSquare className="w-5 h-5" />
              DirtyTalk Generator
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <Textarea
              placeholder="Enter your prompt for AI generation..."
              value={prompt}
              onChange={(e) => setPrompt(e.target.value)}
              className="bg-gray-800 border-gray-500 text-white placeholder-gray-300 focus:border-purple-400 focus:ring-purple-400"
              rows={3}
            />
            
            <Button 
              onClick={generateDirtyTalk}
              disabled={isGenerating || !prompt.trim()}
              className="w-full bg-purple-600 hover:bg-purple-700"
            >
              {isGenerating ? (
                <>
                  <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                  Generating...
                </>
              ) : (
                <>
                  <MessageSquare className="w-4 h-4 mr-2" />
                  Generate Response
                </>
              )}
            </Button>

            {generatedText && (
              <div className="p-3 bg-gray-800 rounded-lg border border-gray-600">
                <p className="text-sm text-gray-100">{generatedText}</p>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Audio Controls */}
        <Card className="bg-black/50 border-purple-500/30">
          <CardHeader>
            <CardTitle className="text-lg flex items-center gap-2">
              <Volume2 className="w-5 h-5" />
              Audio Controls
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="grid grid-cols-2 gap-3">
              <Button 
                onClick={() => generateAudio()}
                disabled={isGeneratingAudio || !generatedText}
                className="bg-pink-600 hover:bg-pink-700"
              >
                {isGeneratingAudio ? (
                  <Loader2 className="w-4 h-4 animate-spin" />
                ) : (
                  <Mic className="w-4 h-4" />
                )}
              </Button>
              
              <Button 
                onClick={playAudio}
                disabled={!currentAudioUrl}
                className="bg-green-600 hover:bg-green-700"
              >
                <Play className="w-4 h-4" />
              </Button>
            </div>
            
            <Button 
              onClick={testVoice}
              disabled={isGeneratingAudio}
              className="w-full bg-blue-600 hover:bg-blue-700"
            >
              {isGeneratingAudio ? (
                <>
                  <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                  Generating Test...
                </>
              ) : (
                <>
                  <Volume2 className="w-4 h-4 mr-2" />
                  Test Voice
                </>
              )}
            </Button>
          </CardContent>
        </Card>

        {/* OBS Scene Control */}
        <Card className="bg-black/50 border-purple-500/30">
          <CardHeader>
            <CardTitle className="text-lg flex items-center gap-2">
              <Video className="w-5 h-5" />
              Scene Control
            </CardTitle>
            {currentScene && (
              <CardDescription>
                Current: <Badge variant="secondary">{currentScene}</Badge>
              </CardDescription>
            )}
          </CardHeader>
          <CardContent className="space-y-3">
            <Select value={selectedScene} onValueChange={setSelectedScene}>
              <SelectTrigger className="bg-gray-800 border-gray-500 text-white focus:border-purple-400 focus:ring-purple-400">
                <SelectValue placeholder="Select scene..." className="text-white" />
              </SelectTrigger>
              <SelectContent className="bg-gray-800 border-gray-600">
                {scenes.map((scene) => (
                  <SelectItem key={scene} value={scene} className="text-white hover:bg-gray-700 focus:bg-gray-700">
                    {scene}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            
            <Button 
              onClick={switchScene}
              disabled={!selectedScene || selectedScene === currentScene}
              className="w-full bg-orange-600 hover:bg-orange-700"
            >
              <Video className="w-4 h-4 mr-2" />
              Switch Scene
            </Button>
          </CardContent>
        </Card>

        {/* Stream Controls */}
        <Card className="bg-black/50 border-purple-500/30">
          <CardHeader>
            <CardTitle className="text-lg flex items-center gap-2">
              <Radio className="w-5 h-5" />
              Stream & Recording
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="grid grid-cols-2 gap-3">
              <Button 
                onClick={toggleStream}
                className={`${isStreaming ? 'bg-red-600 hover:bg-red-700' : 'bg-green-600 hover:bg-green-700'}`}
              >
                {isStreaming ? (
                  <>
                    <StopCircle className="w-4 h-4 mr-2" />
                    Stop Stream
                  </>
                ) : (
                  <>
                    <Radio className="w-4 h-4 mr-2" />
                    Start Stream
                  </>
                )}
              </Button>
              
              <Button 
                onClick={toggleRecording}
                className={`${isRecording ? 'bg-red-600 hover:bg-red-700' : 'bg-blue-600 hover:bg-blue-700'}`}
              >
                {isRecording ? (
                  <>
                    <Square className="w-4 h-4 mr-2" />
                    Stop Rec
                  </>
                ) : (
                  <>
                    <Video className="w-4 h-4 mr-2" />
                    Start Rec
                  </>
                )}
              </Button>
            </div>
            
            <div className="flex justify-center gap-4 text-sm">
              <div className="flex items-center gap-2">
                <div className={`w-2 h-2 rounded-full ${isStreaming ? 'bg-red-500 animate-pulse' : 'bg-gray-500'}`}></div>
                <span>Live</span>
              </div>
              <div className="flex items-center gap-2">
                <div className={`w-2 h-2 rounded-full ${isRecording ? 'bg-red-500 animate-pulse' : 'bg-gray-500'}`}></div>
                <span>Recording</span>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Refresh Button */}
        <Button 
          onClick={checkStatuses}
          className="w-full bg-gray-700 hover:bg-gray-600"
        >
          <Settings className="w-4 h-4 mr-2" />
          Refresh Status
        </Button>
      </div>
    </div>
  )
}

export default App

