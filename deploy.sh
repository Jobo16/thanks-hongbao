#!/bin/bash

# 检查是否以root权限运行
if [ "$EUID" -ne 0 ]; then 
    echo "请使用root权限运行此脚本"
    exit 1
fi

# 设置项目路径
PROJECT_DIR="/www/wwwroot/redpacket_thanks"
LOG_DIR="/www/wwwlogs"
VENV_DIR="$PROJECT_DIR/venv"

# 创建必要的目录
echo "创建项目目录和日志目录..."
mkdir -p $PROJECT_DIR
mkdir -p $LOG_DIR
chown -R www:www $PROJECT_DIR
chown -R www:www $LOG_DIR

# 安装必要的系统包
echo "安装系统依赖..."
apt-get update
apt-get install -y python3-venv python3-pip

# 创建并激活虚拟环境
echo "创建Python虚拟环境..."
python3 -m venv $VENV_DIR
source $VENV_DIR/bin/activate

# 停止已存在的gunicorn进程
echo "检查并停止已存在的进程..."
if [ -f "$PROJECT_DIR/gunicorn.pid" ]; then
    pid=$(cat "$PROJECT_DIR/gunicorn.pid")
    if kill -0 $pid 2>/dev/null; then
        echo "停止已存在的gunicorn进程..."
        kill $pid
        sleep 2
    fi
fi

# 安装Python依赖
echo "安装Python依赖..."
$VENV_DIR/bin/pip install --upgrade pip
$VENV_DIR/bin/pip install flask==3.0.0
$VENV_DIR/bin/pip install requests==2.31.0
$VENV_DIR/bin/pip install gunicorn==21.2.0
$VENV_DIR/bin/pip install gevent==23.9.1

# 设置权限
echo "设置文件权限..."
chown -R www:www $PROJECT_DIR
chmod -R 755 $PROJECT_DIR

# 创建启动脚本
echo "创建启动脚本..."
cat > $PROJECT_DIR/start.sh << 'EOL'
#!/bin/bash
source /www/wwwroot/redpacket_thanks/venv/bin/activate
cd /www/wwwroot/redpacket_thanks
exec gunicorn -c gunicorn_config.py app:app
EOL

chmod +x $PROJECT_DIR/start.sh
chown www:www $PROJECT_DIR/start.sh

# 启动应用
echo "启动应用..."
cd $PROJECT_DIR
sudo -u www $PROJECT_DIR/start.sh

# 检查启动状态
sleep 2
if [ -f "$PROJECT_DIR/gunicorn.pid" ]; then
    echo "应用启动成功！"
    echo "可以通过以下命令查看日志："
    echo "tail -f $LOG_DIR/redpacket_thanks_access.log"
    echo "tail -f $LOG_DIR/redpacket_thanks_error.log"
else
    echo "应用启动失败，请检查日志文件"
    exit 1
fi
