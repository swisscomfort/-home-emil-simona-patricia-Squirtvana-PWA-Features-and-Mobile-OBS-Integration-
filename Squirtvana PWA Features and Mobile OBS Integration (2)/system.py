import os
import psutil
import requests
from flask import Blueprint, jsonify
from dotenv import load_dotenv

load_dotenv()

system_bp = Blueprint('system', __name__)

TELEGRAM_API_KEY = os.getenv("TELEGRAM_API_KEY")
TELEGRAM_BASE_URL = f"https://api.telegram.org/bot{TELEGRAM_API_KEY}"

@system_bp.route('/system/stats', methods=['GET'])
def get_system_stats():
    """Get system resource usage statistics"""
    try:
        # CPU usage
        cpu_percent = psutil.cpu_percent(interval=1)
        
        # Memory usage
        memory = psutil.virtual_memory()
        memory_percent = memory.percent
        memory_used = memory.used / (1024**3)  # GB
        memory_total = memory.total / (1024**3)  # GB
        
        # Disk usage
        disk = psutil.disk_usage('/')
        disk_percent = (disk.used / disk.total) * 100
        disk_used = disk.used / (1024**3)  # GB
        disk_total = disk.total / (1024**3)  # GB
        
        # Network stats
        network = psutil.net_io_counters()
        
        # Process count
        process_count = len(psutil.pids())
        
        return jsonify({
            'success': True,
            'cpu': {
                'usage_percent': round(cpu_percent, 2),
                'cores': psutil.cpu_count()
            },
            'memory': {
                'usage_percent': round(memory_percent, 2),
                'used_gb': round(memory_used, 2),
                'total_gb': round(memory_total, 2)
            },
            'disk': {
                'usage_percent': round(disk_percent, 2),
                'used_gb': round(disk_used, 2),
                'total_gb': round(disk_total, 2)
            },
            'network': {
                'bytes_sent': network.bytes_sent,
                'bytes_recv': network.bytes_recv,
                'packets_sent': network.packets_sent,
                'packets_recv': network.packets_recv
            },
            'processes': process_count
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@system_bp.route('/system/processes', methods=['GET'])
def get_top_processes():
    """Get top CPU and memory consuming processes"""
    try:
        processes = []
        
        for proc in psutil.process_iter(['pid', 'name', 'cpu_percent', 'memory_percent']):
            try:
                proc_info = proc.info
                if proc_info['cpu_percent'] > 0 or proc_info['memory_percent'] > 0:
                    processes.append(proc_info)
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                pass
        
        # Sort by CPU usage
        processes.sort(key=lambda x: x['cpu_percent'], reverse=True)
        top_processes = processes[:10]  # Top 10 processes
        
        return jsonify({
            'success': True,
            'top_processes': top_processes
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@system_bp.route('/telegram/status', methods=['GET'])
def telegram_status():
    """Check Telegram bot status"""
    try:
        # Test bot connection
        response = requests.get(f"{TELEGRAM_BASE_URL}/getMe", timeout=10)
        
        if response.status_code == 200:
            bot_info = response.json()
            if bot_info.get('ok'):
                bot_data = bot_info['result']
                return jsonify({
                    'status': 'active',
                    'bot_name': bot_data.get('first_name', 'Unknown'),
                    'username': bot_data.get('username', 'Unknown'),
                    'bot_id': bot_data.get('id', 'Unknown'),
                    'connection': 'ok'
                })
        
        return jsonify({
            'status': 'error',
            'error': 'Failed to connect to Telegram API'
        }), 500
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'error': str(e)
        }), 500

@system_bp.route('/telegram/updates', methods=['GET'])
def telegram_updates():
    """Get recent Telegram bot updates"""
    try:
        response = requests.get(f"{TELEGRAM_BASE_URL}/getUpdates?limit=5", timeout=10)
        
        if response.status_code == 200:
            updates_data = response.json()
            if updates_data.get('ok'):
                updates = updates_data['result']
                return jsonify({
                    'success': True,
                    'updates_count': len(updates),
                    'recent_updates': updates
                })
        
        return jsonify({
            'error': 'Failed to get Telegram updates'
        }), 500
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@system_bp.route('/health', methods=['GET'])
def health_check():
    """Overall system health check"""
    try:
        # Check system resources
        cpu_percent = psutil.cpu_percent(interval=1)
        memory_percent = psutil.virtual_memory().percent
        disk_percent = (psutil.disk_usage('/').used / psutil.disk_usage('/').total) * 100
        
        # Determine health status
        health_status = "healthy"
        warnings = []
        
        if cpu_percent > 80:
            health_status = "warning"
            warnings.append("High CPU usage")
        
        if memory_percent > 80:
            health_status = "warning"
            warnings.append("High memory usage")
        
        if disk_percent > 90:
            health_status = "critical"
            warnings.append("Low disk space")
        
        return jsonify({
            'status': health_status,
            'warnings': warnings,
            'metrics': {
                'cpu_percent': round(cpu_percent, 2),
                'memory_percent': round(memory_percent, 2),
                'disk_percent': round(disk_percent, 2)
            },
            'timestamp': psutil.boot_time()
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@system_bp.route('/uptime', methods=['GET'])
def get_uptime():
    """Get system uptime"""
    try:
        boot_time = psutil.boot_time()
        uptime_seconds = psutil.time.time() - boot_time
        
        days = int(uptime_seconds // 86400)
        hours = int((uptime_seconds % 86400) // 3600)
        minutes = int((uptime_seconds % 3600) // 60)
        
        return jsonify({
            'success': True,
            'uptime_seconds': int(uptime_seconds),
            'uptime_formatted': f"{days}d {hours}h {minutes}m",
            'boot_time': boot_time
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

