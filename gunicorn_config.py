import multiprocessing

# 监听地址和端口
bind = "0.0.0.0:5000"

# 工作进程数
workers = multiprocessing.cpu_count() * 2 + 1

# 工作模式
worker_class = 'gevent'

# 最大并发量
worker_connections = 1000

# 进程名称前缀
proc_name = 'redpacket_thanks'

# 访问日志和错误日志
accesslog = "/www/wwwlogs/redpacket_thanks_access.log"
errorlog = "/www/wwwlogs/redpacket_thanks_error.log"

# 日志级别
loglevel = 'info'

# 后台运行
daemon = True

# 进程pid记录文件
pidfile = "/www/wwwroot/redpacket_thanks/gunicorn.pid"
