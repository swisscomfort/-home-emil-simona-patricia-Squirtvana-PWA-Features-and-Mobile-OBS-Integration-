import os
from flask import Blueprint, request, jsonify
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()

gpt_bp = Blueprint('gpt', __name__)

# Initialize OpenRouter client
try:
    client = OpenAI(
        base_url="https://openrouter.ai/api/v1",
        api_key=os.getenv("OPENROUTER_KEY"),
    )
except Exception as e:
    print(f"Warning: OpenAI client initialization failed: {e}")
    client = None

@gpt_bp.route('/gpt/generate', methods=['POST'])
def generate_dirtytalk():
    """Generate DirtyTalk content using GPT"""
    try:
        if not client:
            return jsonify({'error': 'GPT service not available'}), 500
            
        data = request.get_json()
        user_prompt = data.get('prompt', '')
        
        if not user_prompt:
            return jsonify({'error': 'Prompt is required'}), 400
        
        # System prompt for DirtyTalk generation
        system_prompt = """You are a seductive AI assistant that generates explicit, erotic content for adult entertainment. 
        Create passionate, sensual responses that are direct and arousing. Use explicit language and be creative with scenarios.
        Keep responses between 50-200 words. Focus on creating immersive, first-person experiences."""
        
        completion = client.chat.completions.create(
            model="anthropic/claude-3.5-sonnet",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt}
            ],
            max_tokens=300,
            temperature=0.8
        )
        
        generated_text = completion.choices[0].message.content
        
        return jsonify({
            'success': True,
            'generated_text': generated_text,
            'prompt': user_prompt
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@gpt_bp.route('/gpt/status', methods=['GET'])
def gpt_status():
    """Check GPT service status"""
    try:
        if not client:
            return jsonify({
                'status': 'error',
                'error': 'Client not initialized'
            }), 500
            
        # Test API connection
        test_completion = client.chat.completions.create(
            model="anthropic/claude-3.5-sonnet",
            messages=[{"role": "user", "content": "Test"}],
            max_tokens=10
        )
        
        return jsonify({
            'status': 'active',
            'model': 'anthropic/claude-3.5-sonnet',
            'connection': 'ok'
        })
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'error': str(e)
        }), 500

