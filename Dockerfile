FROM node:18-alpine

# 设置工作目录
WORKDIR /app

COPY package.json ./

# 安装依赖
RUN npm install --production

# 复制应用程序代码
COPY . .

# 创建配置文件目录
RUN mkdir -p /app/config

# 暴露端口
EXPOSE 1883 8884 8007

# 启动应用
CMD ["node", "app.js"]