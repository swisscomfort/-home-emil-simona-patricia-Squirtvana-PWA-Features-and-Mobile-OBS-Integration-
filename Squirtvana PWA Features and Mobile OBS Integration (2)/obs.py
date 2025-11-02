import json
import websocket
from flask import Blueprint, request, jsonify
from threading import Thread
import time

obs_bp = Blueprint('obs', __name__)

# OBS WebSocket configuration
OBS_WS_URL = "ws://localhost:4455"
obs_ws = None
obs_connected = False

def connect_obs():
    """Connect to OBS WebSocket"""
    global obs_ws, obs_connected
    try:
        obs_ws = websocket.WebSocket()
        obs_ws.connect(OBS_WS_URL)
        obs_connected = True
        return True
    except Exception as e:
        obs_connected = False
        return False

def send_obs_request(request_type, request_data=None):
    """Send request to OBS WebSocket"""
    global obs_ws, obs_connected
    
    if not obs_connected:
        if not connect_obs():
            return None
    
    try:
        request_id = str(int(time.time() * 1000))
        message = {
            "op": 6,
            "d": {
                "requestType": request_type,
                "requestId": request_id,
                "requestData": request_data or {}
            }
        }
        
        obs_ws.send(json.dumps(message))
        
        # Wait for response
        response = obs_ws.recv()
        return json.loads(response)
        
    except Exception as e:
        obs_connected = False
        return None

@obs_bp.route('/obs/scenes', methods=['GET'])
def get_scenes():
    """Get list of available OBS scenes"""
    try:
        response = send_obs_request("GetSceneList")
        
        if response and response.get("d", {}).get("responseData"):
            scenes = response["d"]["responseData"]["scenes"]
            scene_names = [scene["sceneName"] for scene in scenes]
            current_scene = response["d"]["responseData"]["currentProgramSceneName"]
            
            return jsonify({
                'success': True,
                'scenes': scene_names,
                'current_scene': current_scene
            })
        else:
            return jsonify({'error': 'Failed to get scenes from OBS'}), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@obs_bp.route('/obs/scene/switch', methods=['POST'])
def switch_scene():
    """Switch to a specific OBS scene"""
    try:
        data = request.get_json()
        scene_name = data.get('scene_name', '')
        
        if not scene_name:
            return jsonify({'error': 'Scene name is required'}), 400
        
        response = send_obs_request("SetCurrentProgramScene", {
            "sceneName": scene_name
        })
        
        if response:
            return jsonify({
                'success': True,
                'scene_name': scene_name
            })
        else:
            return jsonify({'error': 'Failed to switch scene'}), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@obs_bp.route('/obs/text/update', methods=['POST'])
def update_text_source():
    """Update text source in OBS"""
    try:
        data = request.get_json()
        source_name = data.get('source_name', 'DirtyTalk')
        text = data.get('text', '')
        
        response = send_obs_request("SetInputSettings", {
            "inputName": source_name,
            "inputSettings": {
                "text": text
            }
        })
        
        if response:
            return jsonify({
                'success': True,
                'source_name': source_name,
                'text': text
            })
        else:
            return jsonify({'error': 'Failed to update text source'}), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@obs_bp.route('/obs/sources', methods=['GET'])
def get_sources():
    """Get list of available text sources"""
    try:
        response = send_obs_request("GetInputList", {
            "inputKind": "text_gdiplus_v2"
        })
        
        if response and response.get("d", {}).get("responseData"):
            inputs = response["d"]["responseData"]["inputs"]
            source_names = [inp["inputName"] for inp in inputs]
            
            return jsonify({
                'success': True,
                'text_sources': source_names
            })
        else:
            return jsonify({'error': 'Failed to get text sources from OBS'}), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@obs_bp.route('/obs/status', methods=['GET'])
def obs_status():
    """Check OBS connection status"""
    try:
        if connect_obs():
            response = send_obs_request("GetVersion")
            if response:
                version_data = response.get("d", {}).get("responseData", {})
                return jsonify({
                    'status': 'connected',
                    'obs_version': version_data.get("obsVersion", "Unknown"),
                    'websocket_version': version_data.get("obsWebSocketVersion", "Unknown")
                })
        
        return jsonify({
            'status': 'disconnected',
            'error': 'Cannot connect to OBS WebSocket'
        }), 500
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'error': str(e)
        }), 500

@obs_bp.route('/obs/reconnect', methods=['POST'])
def reconnect_obs():
    """Reconnect to OBS WebSocket"""
    try:
        global obs_connected
        obs_connected = False
        
        if connect_obs():
            return jsonify({
                'success': True,
                'status': 'reconnected'
            })
        else:
            return jsonify({'error': 'Failed to reconnect to OBS'}), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

