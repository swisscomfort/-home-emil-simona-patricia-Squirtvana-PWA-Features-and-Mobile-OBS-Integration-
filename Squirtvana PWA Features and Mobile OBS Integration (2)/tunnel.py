"""
Cloudflare Tunnel Management Routes
Handles secure tunnel creation and management for remote OBS access
"""

import subprocess
import json
import os
import time
import threading
from flask import Blueprint, request, jsonify
from datetime import datetime

tunnel_bp = Blueprint('tunnel', __name__)

# Global tunnel state
tunnel_state = {
    'active': False,
    'url': None,
    'process': None,
    'config_file': None,
    'tunnel_id': None,
    'created_at': None,
    'last_check': None,
    'status': 'stopped'
}

class CloudflareTunnel:
    def __init__(self):
        self.config_dir = os.path.expanduser('~/.cloudflared')
        self.config_file = os.path.join(self.config_dir, 'squirtvana-tunnel.yml')
        self.process = None
        
    def ensure_cloudflared_installed(self):
        """Check if cloudflared is installed"""
        try:
            result = subprocess.run(['cloudflared', '--version'], 
                                  capture_output=True, text=True, timeout=5)
            return result.returncode == 0
        except (subprocess.TimeoutExpired, FileNotFoundError):
            return False
    
    def install_cloudflared(self):
        """Install cloudflared on Fedora"""
        try:
            print("Installing cloudflared...")
            
            # Download and install cloudflared for Fedora
            commands = [
                'curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.rpm -o /tmp/cloudflared.rpm',
                'sudo rpm -i /tmp/cloudflared.rpm'
            ]
            
            for cmd in commands:
                result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
                if result.returncode != 0:
                    print(f"Command failed: {cmd}")
                    print(f"Error: {result.stderr}")
                    return False
            
            return self.ensure_cloudflared_installed()
            
        except Exception as e:
            print(f"Failed to install cloudflared: {str(e)}")
            return False
    
    def create_tunnel_config(self, tunnel_name="squirtvana-obs"):
        """Create tunnel configuration"""
        try:
            # Ensure config directory exists
            os.makedirs(self.config_dir, exist_ok=True)
            
            # Create tunnel configuration
            config = {
                'tunnel': tunnel_name,
                'credentials-file': os.path.join(self.config_dir, f'{tunnel_name}.json'),
                'ingress': [
                    {
                        'hostname': f'{tunnel_name}.trycloudflare.com',
                        'service': 'http://localhost:5000'
                    },
                    {
                        'service': 'http_status:404'
                    }
                ]
            }
            
            # Write config file
            with open(self.config_file, 'w') as f:
                import yaml
                yaml.dump(config, f, default_flow_style=False)
            
            return True
            
        except Exception as e:
            print(f"Failed to create tunnel config: {str(e)}")
            return False
    
    def create_tunnel(self, tunnel_name="squirtvana-obs"):
        """Create a new Cloudflare tunnel"""
        try:
            # Check if cloudflared is installed
            if not self.ensure_cloudflared_installed():
                if not self.install_cloudflared():
                    return False, "Failed to install cloudflared"
            
            # Create tunnel configuration
            if not self.create_tunnel_config(tunnel_name):
                return False, "Failed to create tunnel configuration"
            
            # For quick setup, use trycloudflare (no account needed)
            # In production, you'd use: cloudflared tunnel create <name>
            cmd = [
                'cloudflared', 'tunnel', 
                '--url', 'http://localhost:5000',
                '--name', tunnel_name
            ]
            
            print(f"Starting tunnel with command: {' '.join(cmd)}")
            
            # Start tunnel process
            self.process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            # Wait for tunnel URL (timeout after 30 seconds)
            tunnel_url = None
            start_time = time.time()
            
            while time.time() - start_time < 30:
                if self.process.poll() is not None:
                    # Process ended
                    stdout, stderr = self.process.communicate()
                    return False, f"Tunnel process failed: {stderr}"
                
                # Check for tunnel URL in output
                try:
                    line = self.process.stdout.readline()
                    if line and 'trycloudflare.com' in line:
                        # Extract URL from output
                        import re
                        url_match = re.search(r'https://[a-zA-Z0-9-]+\.trycloudflare\.com', line)
                        if url_match:
                            tunnel_url = url_match.group(0)
                            break
                except:
                    pass
                
                time.sleep(0.5)
            
            if tunnel_url:
                tunnel_state['active'] = True
                tunnel_state['url'] = tunnel_url
                tunnel_state['process'] = self.process
                tunnel_state['tunnel_id'] = tunnel_name
                tunnel_state['created_at'] = datetime.now().isoformat()
                tunnel_state['status'] = 'active'
                
                return True, tunnel_url
            else:
                self.stop_tunnel()
                return False, "Failed to get tunnel URL"
                
        except Exception as e:
            return False, f"Tunnel creation failed: {str(e)}"
    
    def stop_tunnel(self):
        """Stop the active tunnel"""
        try:
            if self.process:
                self.process.terminate()
                try:
                    self.process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    self.process.kill()
                    self.process.wait()
                
                self.process = None
            
            tunnel_state['active'] = False
            tunnel_state['url'] = None
            tunnel_state['process'] = None
            tunnel_state['status'] = 'stopped'
            
            return True, "Tunnel stopped successfully"
            
        except Exception as e:
            return False, f"Failed to stop tunnel: {str(e)}"
    
    def get_tunnel_status(self):
        """Get current tunnel status"""
        if self.process and self.process.poll() is None:
            tunnel_state['status'] = 'active'
            tunnel_state['last_check'] = datetime.now().isoformat()
        else:
            tunnel_state['status'] = 'stopped'
            tunnel_state['active'] = False
            tunnel_state['url'] = None
        
        return tunnel_state

# Global tunnel manager
tunnel_manager = CloudflareTunnel()

@tunnel_bp.route('/create', methods=['POST'])
def create_tunnel():
    """Create a new Cloudflare tunnel"""
    data = request.get_json() or {}
    tunnel_name = data.get('name', 'squirtvana-obs')
    
    if tunnel_state['active']:
        return jsonify({
            'error': 'Tunnel already active',
            'current_url': tunnel_state['url']
        }), 400
    
    try:
        success, result = tunnel_manager.create_tunnel(tunnel_name)
        
        if success:
            return jsonify({
                'success': True,
                'message': 'Tunnel created successfully',
                'tunnel_url': result,
                'tunnel_name': tunnel_name,
                'created_at': tunnel_state['created_at'],
                'instructions': {
                    'obs_websocket': f'{result}/ws',
                    'web_interface': result,
                    'api_base': f'{result}/api'
                }
            })
        else:
            return jsonify({'error': result}), 500
            
    except Exception as e:
        return jsonify({'error': f'Tunnel creation failed: {str(e)}'}), 500

@tunnel_bp.route('/stop', methods=['POST'])
def stop_tunnel():
    """Stop the active tunnel"""
    if not tunnel_state['active']:
        return jsonify({'error': 'No active tunnel to stop'}), 400
    
    try:
        success, message = tunnel_manager.stop_tunnel()
        
        if success:
            return jsonify({
                'success': True,
                'message': message
            })
        else:
            return jsonify({'error': message}), 500
            
    except Exception as e:
        return jsonify({'error': f'Failed to stop tunnel: {str(e)}'}), 500

@tunnel_bp.route('/status', methods=['GET'])
def get_tunnel_status():
    """Get current tunnel status"""
    try:
        status = tunnel_manager.get_tunnel_status()
        
        return jsonify({
            'active': status['active'],
            'url': status['url'],
            'tunnel_id': status['tunnel_id'],
            'status': status['status'],
            'created_at': status['created_at'],
            'last_check': status['last_check'],
            'uptime': None if not status['created_at'] else str(
                datetime.now() - datetime.fromisoformat(status['created_at'])
            ) if status['active'] else None
        })
        
    except Exception as e:
        return jsonify({'error': f'Failed to get tunnel status: {str(e)}'}), 500

@tunnel_bp.route('/restart', methods=['POST'])
def restart_tunnel():
    """Restart the tunnel"""
    try:
        # Stop existing tunnel
        if tunnel_state['active']:
            tunnel_manager.stop_tunnel()
            time.sleep(2)  # Wait for cleanup
        
        # Start new tunnel
        data = request.get_json() or {}
        tunnel_name = data.get('name', 'squirtvana-obs')
        
        success, result = tunnel_manager.create_tunnel(tunnel_name)
        
        if success:
            return jsonify({
                'success': True,
                'message': 'Tunnel restarted successfully',
                'tunnel_url': result,
                'tunnel_name': tunnel_name
            })
        else:
            return jsonify({'error': result}), 500
            
    except Exception as e:
        return jsonify({'error': f'Tunnel restart failed: {str(e)}'}), 500

@tunnel_bp.route('/logs', methods=['GET'])
def get_tunnel_logs():
    """Get tunnel logs"""
    try:
        if not tunnel_state['active'] or not tunnel_manager.process:
            return jsonify({'error': 'No active tunnel'}), 400
        
        # Get recent output from tunnel process
        # Note: In a production setup, you'd want to log to files
        return jsonify({
            'status': 'active',
            'message': 'Tunnel is running',
            'url': tunnel_state['url'],
            'pid': tunnel_manager.process.pid if tunnel_manager.process else None
        })
        
    except Exception as e:
        return jsonify({'error': f'Failed to get tunnel logs: {str(e)}'}), 500

@tunnel_bp.route('/config', methods=['GET'])
def get_tunnel_config():
    """Get tunnel configuration"""
    try:
        config_info = {
            'config_dir': tunnel_manager.config_dir,
            'config_file': tunnel_manager.config_file,
            'cloudflared_installed': tunnel_manager.ensure_cloudflared_installed(),
            'supported_features': [
                'HTTP tunneling',
                'WebSocket support',
                'Automatic HTTPS',
                'No account required (trycloudflare)',
                'Temporary tunnels'
            ]
        }
        
        return jsonify(config_info)
        
    except Exception as e:
        return jsonify({'error': f'Failed to get config: {str(e)}'}), 500

