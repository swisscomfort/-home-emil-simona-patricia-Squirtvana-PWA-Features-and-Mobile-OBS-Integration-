#!/usr/bin/env python3
"""
Squirtvana PWA - Simple Terminal Version
Einfache Flask-App mit OBS-Integration
"""

import os
import json
import subprocess
import requests
from flask import Flask, render_template, request, jsonify, send_from_directory
from flask_cors import CORS

app = Flask(__name__, static_folder='static', template_folder='templates')
CORS(app)

# API Keys (aus Umgebungsvariablen oder direkt hier)
OPENROUTER_KEY = "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"
ELEVENLABS_KEY = "sk_226e2f2cec752de5561266ae5043937dc08a7e52597ec069"
ELEVENLABS_VOICE = "21m00Tcm4TlvDq8ikWAM"

@app.route('/')
def index():
    """Hauptseite - PWA Interface"""
    return render_template('index.html')

@app.route('/api/health')
def health():
    """Health Check"""
    return jsonify({'status': 'ok', 'message': 'Squirtvana PWA läuft!'})

@app.route('/api/gpt', methods=['POST'])
def generate_text():
    """GPT DirtyTalk Generator"""
    try:
        data = request.get_json()
        prompt = data.get('prompt', '')
        
        if not prompt:
            return jsonify({'error': 'Kein Prompt angegeben'}), 400
        
        # OpenRouter API Call
        headers = {
            'Authorization': f'Bearer {OPENROUTER_KEY}',
            'Content-Type': 'application/json'
        }
        
        payload = {
            'model': 'anthropic/claude-3-haiku',
            'messages': [
                {'role': 'user', 'content': f'Generate a flirty response: {prompt}'}
            ],
            'max_tokens': 150
        }
        
        response = requests.post(
            'https://openrouter.ai/api/v1/chat/completions',
            headers=headers,
            json=payload,
            timeout=30
        )
        
        if response.status_code == 200:
            result = response.json()
            generated_text = result['choices'][0]['message']['content']
            
            # OBS Text aktualisieren
            update_obs_text(generated_text)
            
            return jsonify({
                'success': True,
                'text': generated_text
            })
        else:
            return jsonify({'error': 'GPT API Fehler'}), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/audio', methods=['POST'])
def generate_audio():
    """ElevenLabs Audio Generator"""
    try:
        data = request.get_json()
        text = data.get('text', '')
        
        if not text:
            return jsonify({'error': 'Kein Text angegeben'}), 400
        
        # ElevenLabs API Call
        url = f"https://api.elevenlabs.io/v1/text-to-speech/{ELEVENLABS_VOICE}"
        headers = {
            'xi-api-key': ELEVENLABS_KEY,
            'Content-Type': 'application/json'
        }
        
        payload = {
            'text': text,
            'model_id': 'eleven_monolingual_v1',
            'voice_settings': {
                'stability': 0.5,
                'similarity_boost': 0.5
            }
        }
        
        response = requests.post(url, headers=headers, json=payload, timeout=30)
        
        if response.status_code == 200:
            # Audio-Datei speichern
            audio_path = os.path.join(app.static_folder, 'output.mp3')
            with open(audio_path, 'wb') as f:
                f.write(response.content)
            
            return jsonify({
                'success': True,
                'audio_url': '/static/output.mp3'
            })
        else:
            return jsonify({'error': 'Audio API Fehler'}), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/obs/scene', methods=['POST'])
def change_obs_scene():
    """OBS Szene wechseln"""
    try:
        data = request.get_json()
        scene = data.get('scene', '')
        
        # OBS CLI Command (obs-cli oder obs-websocket-py)
        result = subprocess.run([
            'obs-cli', 'scene', 'switch', scene
        ], capture_output=True, text=True, timeout=10)
        
        if result.returncode == 0:
            return jsonify({
                'success': True,
                'message': f'Szene gewechselt zu: {scene}'
            })
        else:
            return jsonify({'error': 'OBS Szenen-Wechsel fehlgeschlagen'}), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/obs/stream', methods=['POST'])
def control_stream():
    """Stream starten/stoppen"""
    try:
        data = request.get_json()
        action = data.get('action', '')  # 'start' oder 'stop'
        
        if action == 'start':
            result = subprocess.run(['obs-cli', 'streaming', 'start'], 
                                  capture_output=True, text=True, timeout=10)
        elif action == 'stop':
            result = subprocess.run(['obs-cli', 'streaming', 'stop'], 
                                  capture_output=True, text=True, timeout=10)
        else:
            return jsonify({'error': 'Ungültige Aktion'}), 400
        
        if result.returncode == 0:
            return jsonify({
                'success': True,
                'message': f'Stream {action} erfolgreich'
            })
        else:
            return jsonify({'error': f'Stream {action} fehlgeschlagen'}), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/system')
def system_stats():
    """System-Status"""
    try:
        # CPU, RAM, Disk mit einfachen Shell-Commands
        cpu = subprocess.run(['top', '-bn1'], capture_output=True, text=True)
        cpu_usage = "N/A"
        if cpu.returncode == 0:
            # CPU-Wert extrahieren (vereinfacht)
            lines = cpu.stdout.split('\n')
            for line in lines:
                if 'Cpu(s)' in line:
                    cpu_usage = line.split()[1]
                    break
        
        # RAM
        mem = subprocess.run(['free', '-h'], capture_output=True, text=True)
        ram_usage = "N/A"
        if mem.returncode == 0:
            lines = mem.stdout.split('\n')
            if len(lines) > 1:
                ram_line = lines[1].split()
                if len(ram_line) > 2:
                    ram_usage = f"{ram_line[2]}/{ram_line[1]}"
        
        # Disk
        disk = subprocess.run(['df', '-h', '/'], capture_output=True, text=True)
        disk_usage = "N/A"
        if disk.returncode == 0:
            lines = disk.stdout.split('\n')
            if len(lines) > 1:
                disk_line = lines[1].split()
                if len(disk_line) > 4:
                    disk_usage = disk_line[4]
        
        return jsonify({
            'cpu': cpu_usage,
            'ram': ram_usage,
            'disk': disk_usage,
            'status': 'active'
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

def update_obs_text(text):
    """OBS Text-Quelle aktualisieren"""
    try:
        # OBS CLI Command für Text-Update
        subprocess.run([
            'obs-cli', 'source', 'text', 'DirtyTalk', text
        ], capture_output=True, timeout=5)
    except:
        pass  # Ignoriere Fehler

@app.route('/static/<path:filename>')
def static_files(filename):
    """Statische Dateien servieren"""
    return send_from_directory(app.static_folder, filename)

if __name__ == '__main__':
    # Statische Ordner erstellen
    os.makedirs(os.path.join(os.path.dirname(__file__), 'static'), exist_ok=True)
    os.makedirs(os.path.join(os.path.dirname(__file__), 'templates'), exist_ok=True)
    
    print("🚀 Squirtvana PWA startet...")
    print("📱 Frontend: http://localhost:5000")
    print("🔌 API: http://localhost:5000/api/health")
    print("Press Ctrl+C to stop")
    
    app.run(host='0.0.0.0', port=5000, debug=True)

