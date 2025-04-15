from flask import Flask, render_template, request, jsonify
import requests
import os
from dotenv import load_dotenv
import json

# 加载环境变量
load_dotenv()

app = Flask(__name__)

# GLM-4 API配置
API_KEY = os.getenv('GLM_API_KEY')
if not API_KEY:
    raise ValueError("请设置环境变量GLM_API_KEY")

API_URL = "https://open.bigmodel.cn/api/paas/v4/chat/completions"

def generate_prompt(identity, emotion, length, style):
    # 构建提示词
    prompt = f"""请你帮我生成一段红包感谢语，要求如下：
1. 身份：{identity}
2. 情感基调：{emotion}
3. 长度要求：{length}
4. 表达风格：{style}

请直接输出感谢语内容，不要包含任何额外的解释或说明。"""
    
    return prompt

def call_glm4_api(prompt):
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    
    data = {
        "model": "GLM-4-Flash-250414",
        "messages": [
            {"role": "user", "content": prompt}
        ],
        "temperature": 0.7,
        "top_p": 0.7,
        "max_tokens": 1500,
        "stream": False,
    }
    
    try:
        response = requests.post(API_URL, headers=headers, json=data)
        if response.status_code == 200:
            result = response.json()
            return result['choices'][0]['message']['content'].strip()
        else:
            return f"API调用失败：{response.status_code} - {response.text}"
    except Exception as e:
        return f"发生错误：{str(e)}"

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/generate', methods=['POST'])
def generate():
    data = request.json
    identity = data.get('identity', '')
    emotion = data.get('emotion', '50')
    length = data.get('length', '50')
    style = data.get('style', '现代简约')
    
    prompt = generate_prompt(identity, emotion, length, style)
    result = call_glm4_api(prompt)
    
    return jsonify({'result': result})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
