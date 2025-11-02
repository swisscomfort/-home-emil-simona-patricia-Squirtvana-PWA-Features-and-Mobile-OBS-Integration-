import os
import requests
from flask import Blueprint, request, jsonify, send_file
from dotenv import load_dotenv

load_dotenv()

audio_bp = Blueprint('audio', __name__)

ELEVENLABS_API_KEY = os.getenv("ELEVENLABS_API_KEY")
ELEVENLABS_VOICE_ID = os.getenv("ELEVENLABS_VOICE_ID")
ELEVENLABS_URL = f"https://api.elevenlabs.io/v1/text-to-speech/{ELEVENLABS_VOICE_ID}"

# Create audio directory if it doesn't exist
AUDIO_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'static', 'audio')
os.makedirs(AUDIO_DIR, exist_ok=True)

@audio_bp.route('/audio/generate', methods=['POST'])
def generate_audio():
    """Generate audio from text using ElevenLabs"""
    try:
        data = request.get_json()
        text = data.get('text', '')
        
        if not text:
            return jsonify({'error': 'Text is required'}), 400
        
        headers = {
            "Accept": "audio/mpeg",
            "Content-Type": "application/json",
            "xi-api-key": ELEVENLABS_API_KEY
        }
        
        payload = {
            "text": text,
            "model_id": "eleven_monolingual_v1",
            "voice_settings": {
                "stability": 0.5,
                "similarity_boost": 0.5
            }
        }
        
        response = requests.post(ELEVENLABS_URL, json=payload, headers=headers)
        
        if response.status_code == 200:
            # Save audio file
            audio_filename = "output.mp3"
            audio_path = os.path.join(AUDIO_DIR, audio_filename)
            
            with open(audio_path, 'wb') as f:
                f.write(response.content)
            
            return jsonify({
                'success': True,
                'audio_url': f'/api/audio/file/{audio_filename}',
                'text': text
            })
        else:
            return jsonify({'error': 'Failed to generate audio'}), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@audio_bp.route('/audio/file/<filename>', methods=['GET'])
def serve_audio(filename):
    """Serve audio files"""
    try:
        audio_path = os.path.join(AUDIO_DIR, filename)
        if os.path.exists(audio_path):
            return send_file(audio_path, mimetype='audio/mpeg')
        else:
            return jsonify({'error': 'Audio file not found'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@audio_bp.route('/audio/test', methods=['POST'])
def test_voice():
    """Test voice output with a predefined message"""
    try:
        test_text = "Hello, this is a voice test for the Squirtvana PWA. Audio generation is working perfectly."
        
        headers = {
            "Accept": "audio/mpeg",
            "Content-Type": "application/json",
            "xi-api-key": ELEVENLABS_API_KEY
        }
        
        payload = {
            "text": test_text,
            "model_id": "eleven_monolingual_v1",
            "voice_settings": {
                "stability": 0.5,
                "similarity_boost": 0.5
            }
        }
        
        response = requests.post(ELEVENLABS_URL, json=payload, headers=headers)
        
        if response.status_code == 200:
            # Save test audio file
            audio_filename = "test_voice.mp3"
            audio_path = os.path.join(AUDIO_DIR, audio_filename)
            
            with open(audio_path, 'wb') as f:
                f.write(response.content)
            
            return jsonify({
                'success': True,
                'audio_url': f'/api/audio/file/{audio_filename}',
                'text': test_text
            })
        else:
            return jsonify({'error': 'Failed to generate test audio'}), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@audio_bp.route('/audio/status', methods=['GET'])
def audio_status():
    """Check ElevenLabs service status"""
    try:
        headers = {
            "xi-api-key": ELEVENLABS_API_KEY
        }
        
        # Test API connection by getting voice info
        voice_url = f"https://api.elevenlabs.io/v1/voices/{ELEVENLABS_VOICE_ID}"
        response = requests.get(voice_url, headers=headers)
        
        if response.status_code == 200:
            voice_data = response.json()
            return jsonify({
                'status': 'active',
                'voice_name': voice_data.get('name', 'Unknown'),
                'voice_id': ELEVENLABS_VOICE_ID,
                'connection': 'ok'
            })
        else:
            return jsonify({
                'status': 'error',
                'error': 'Failed to connect to ElevenLabs API'
            }), 500
            
    except Exception as e:
        return jsonify({
            'status': 'error',
            'error': str(e)
        }), 500

