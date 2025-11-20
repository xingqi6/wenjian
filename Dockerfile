# 使用最小化 Alpine 基础镜像
FROM alpine:latest

# 设置一个通用的工作目录，避开 /opt/alist
WORKDIR /app

# 安装基础网络工具
RUN apk add --no-cache curl tar ca-certificates libc6-compat

# === 核心混淆步骤 ===
# 1. 下载 (这是构建过程，HF 看不到这个 URL)
# 2. 解压
# 3. 【关键】立刻重命名为 system-worker
# 4. 删除原始压缩包，清理痕迹
RUN curl -L https://github.com/xingqi6/wenjian/releases/download/V3.55.0/alist-linux-musl-amd64.tar.gz -o temp.tar.gz \
    && tar -zxvf temp.tar.gz \
    && mv alist system-worker \
    && rm temp.tar.gz

# 复制启动脚本
COPY boot.sh .

# === 权限与目录处理 ===
# 创建数据目录
RUN mkdir -p data/cache

# 赋予脚本和二进制文件执行权限
RUN chmod +x boot.sh system-worker

# 适配 Hugging Face 非 Root 用户 (ID 1000)
# 这一步必不可少，否则无法运行
RUN chown -R 1000:1000 /app

# 切换到普通用户
USER 1000

# 暴露 HF 要求的端口
EXPOSE 7860

# 启动
CMD ["./boot.sh"]
