# MQTT+UDP 到 WebSocket 桥接服务

## 项目概述

[原项目](https://github.com/xinnan-tech/xiaozhi-mqtt-gateway)是基于虾哥开源的 [MQTT+UDP 到 WebSocket 桥接服务](https://github.com/78/xiaozhi-mqtt-gateway)，进行了修改，以适应[xiaozhi-esp32-server](https://github.com/xinnan-tech/xiaozhi-esp32-server)

在原项目基础上，本项目添加了 Docker 部署支持，没有合并到原项目的计划

## 部署使用

本项目采用的部署过程参考[原项目使用说明](https://github.com/xinnan-tech/xiaozhi-esp32-server/blob/main/docs/mqtt-gateway-integration.md)。

### 需要开放以下端口

- `8007`：TCP
- `1883`：TCP
- `8884`: UDP

### 需要修改配置文件

1. 将 `config/mqtt.json.example` 复制到宿主机，并修改 `docker-compose.yml` 中的挂载路径 
2. 按实际情况修改 `config/mqtt.json` 中的配置项，主要关注 `chat_servers` 字段
3. 按实际情况检查、修改 `docker-compose.yml` 中的环境变量配置、路径等

### 启动服务

```shell
docker-compose up -d
```

正常启动时，控制台有如下日志：

```
配置已更新 /app/config/mqtt.json
MQTT 服务器正在监听端口 1883
UDP 服务器正在监听 ip:8884
管理API服务启动在端口 8007
API今日临时密钥: Authorization: Bearer xxx...
```

至此服务部署步骤完成，可以返回[原教程第二部分](https://github.com/xinnan-tech/xiaozhi-esp32-server/blob/main/docs/mqtt-gateway-integration.md)继续后续操作（单模块部署需查看第三部分）

## 设备管理接口说明

### 接口认证

API请求需要在请求头中包含有效的`Authorization: Bearer xxx`令牌，令牌生成规则如下：

1. 获取当前日期，格式为`yyyy-MM-dd`（例如：2025-09-15）
2. 获取.env文件中配置的`MQTT_SIGNATURE_KEY`值
3. 将日期字符串与MQTT_SIGNATURE_KEY连接（格式：`日期+MQTT_SIGNATURE_KEY`）
4. 对连接后的字符串进行SHA256哈希计算
5. 哈希结果即为当日有效的Bearer令牌

**注意**：服务启动时会自动计算并打印当日的临时密钥，方便测试使用。


### 接口1 设备指令下发API，支持MCP指令并返回设备响应
``` shell
curl --location --request POST 'http://localhost:8007/api/commands/lichuang-dev@@@a0_85_e3_f4_49_34@@@aeebef32-f0ef-4bce-9d8a-894d91bc6932' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer your_daily_token' \
--data-raw '{"type": "mcp", "payload": {"jsonrpc": "2.0", "id": 1, "method": "tools/call", "params": {"name": "self.get_device_status", "arguments": {}}}}'
```

### 接口2 设备状态查询API，支持查询设备是否在线

``` shell
curl --location --request POST 'http://localhost:8007/api/devices/status' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer your_daily_token' \
--data-raw '{
    "deviceIds": [
        "lichuang-dev@@@a0_85_e3_f4_49_34@@@aeebef32-f0ef-4bce-9d8a-894d91bc6932"
    ]
}'
```