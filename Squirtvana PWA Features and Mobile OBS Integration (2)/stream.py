import json
import websocket
from flask import Blueprint, request, jsonify
import time

stream_bp = Blueprint('stream', __name__)

# Import OBS connection functions from obs.py
from src.routes.obs import send_obs_request, connect_obs

@stream_bp.route('/stream/start', methods=['POST'])
def start_stream():
    """Start OBS live stream"""
    try:
        response = send_obs_request("StartStream")
        
        if response:
            return jsonify({
                'success': True,
                'action': 'stream_started',
                'message': 'Live stream started successfully'
            })
        else:
            return jsonify({'error': 'Failed to start stream'}), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@stream_bp.route('/stream/stop', methods=['POST'])
def stop_stream():
    """Stop OBS live stream"""
    try:
        response = send_obs_request("StopStream")
        
        if response:
            return jsonify({
                'success': True,
                'action': 'stream_stopped',
                'message': 'Live stream stopped successfully'
            })
        else:
            return jsonify({'error': 'Failed to stop stream'}), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@stream_bp.route('/stream/status', methods=['GET'])
def stream_status():
    """Get current stream status"""
    try:
        response = send_obs_request("GetStreamStatus")
        
        if response and response.get("d", {}).get("responseData"):
            data = response["d"]["responseData"]
            return jsonify({
                'success': True,
                'streaming': data.get("outputActive", False),
                'duration': data.get("outputDuration", 0),
                'bytes': data.get("outputBytes", 0),
                'frames': data.get("outputSkippedFrames", 0)
            })
        else:
            return jsonify({'error': 'Failed to get stream status'}), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@stream_bp.route('/recording/start', methods=['POST'])
def start_recording():
    """Start OBS recording"""
    try:
        response = send_obs_request("StartRecord")
        
        if response:
            return jsonify({
                'success': True,
                'action': 'recording_started',
                'message': 'Recording started successfully'
            })
        else:
            return jsonify({'error': 'Failed to start recording'}), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@stream_bp.route('/recording/stop', methods=['POST'])
def stop_recording():
    """Stop OBS recording"""
    try:
        response = send_obs_request("StopRecord")
        
        if response:
            return jsonify({
                'success': True,
                'action': 'recording_stopped',
                'message': 'Recording stopped successfully'
            })
        else:
            return jsonify({'error': 'Failed to stop recording'}), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@stream_bp.route('/recording/status', methods=['GET'])
def recording_status():
    """Get current recording status"""
    try:
        response = send_obs_request("GetRecordStatus")
        
        if response and response.get("d", {}).get("responseData"):
            data = response["d"]["responseData"]
            return jsonify({
                'success': True,
                'recording': data.get("outputActive", False),
                'duration': data.get("outputDuration", 0),
                'bytes': data.get("outputBytes", 0),
                'paused': data.get("outputPaused", False)
            })
        else:
            return jsonify({'error': 'Failed to get recording status'}), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@stream_bp.route('/recording/pause', methods=['POST'])
def pause_recording():
    """Pause OBS recording"""
    try:
        response = send_obs_request("PauseRecord")
        
        if response:
            return jsonify({
                'success': True,
                'action': 'recording_paused',
                'message': 'Recording paused successfully'
            })
        else:
            return jsonify({'error': 'Failed to pause recording'}), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@stream_bp.route('/recording/resume', methods=['POST'])
def resume_recording():
    """Resume OBS recording"""
    try:
        response = send_obs_request("ResumeRecord")
        
        if response:
            return jsonify({
                'success': True,
                'action': 'recording_resumed',
                'message': 'Recording resumed successfully'
            })
        else:
            return jsonify({'error': 'Failed to resume recording'}), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@stream_bp.route('/stats', methods=['GET'])
def get_stats():
    """Get OBS statistics"""
    try:
        response = send_obs_request("GetStats")
        
        if response and response.get("d", {}).get("responseData"):
            stats = response["d"]["responseData"]
            return jsonify({
                'success': True,
                'cpu_usage': stats.get("cpuUsage", 0),
                'memory_usage': stats.get("memoryUsage", 0),
                'fps': stats.get("activeFps", 0),
                'render_missed_frames': stats.get("renderMissedFrames", 0),
                'output_skipped_frames': stats.get("outputSkippedFrames", 0)
            })
        else:
            return jsonify({'error': 'Failed to get OBS stats'}), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

