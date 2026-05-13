pipeline {
    agent any
    
    environment {
        REGISTRY = "crpi-w63lzfggxh0bmatq.cn-beijing.personal.cr.aliyuncs.com"
        IMAGE_NAME = "hestic/hestic"
        ACR_CREDS_ID = "aliyun-acr-creds"
        GIT_CREDS_ID = "github-token"
        // --- 新增配置 ---
        ECS_IP = "39.97.56.212"
        SSH_CREDS_ID = "ecs-ssh-key" // 这是你在 Jenkins 凭据里存私钥的 ID
    }
    stages {
        stage('1. 拉取代码') {
            steps {
                git credentialsId: "${GIT_CREDS_ID}", 
                    url: 'https://github.com/hestic123456-ctrl/git-practice.git',
                    branch: 'main'
            }
        }
        stage('2. 构建镜像') {
            steps {
                bat "docker build -t ${REGISTRY}/${IMAGE_NAME}:%BUILD_ID% ."
            }
        }
        stage('3. 推送到阿里云') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${ACR_CREDS_ID}", passwordVariable: 'ACR_PW', usernameVariable: 'ACR_USR')]) {
                        bat "docker login --username=%ACR_USR% --password=%ACR_PW% ${REGISTRY}"
                        bat "docker push ${REGISTRY}/${IMAGE_NAME}:%BUILD_ID%"
                    }
                }
            }
        }
        // --- 新增阶段：远程部署 ---
        stage('4. 远程部署到 ECS') {
            steps {
                // 使用 sshagent 插件加载你的私钥
                sshagent(credentials: ["${SSH_CREDS_ID}"]) {
                    script {
                        // 定义在远程 ECS 上执行的命令
                        // 1. 登录 ACR 2. 停止并删除旧容器 3. 拉取新镜像 4. 运行新容器
                        // 注意：这里为了安全，ACR 登录密码也可以通过 credentials 传入，或者临时写死测试
                        def remoteCmd = """
                            docker login --username=Hestic --password=你的ACR访问凭证密码 ${REGISTRY}
                            docker stop my-app || true
                            docker rm my-app || true
                            docker pull ${REGISTRY}/${IMAGE_NAME}:${env.BUILD_ID}
                            docker run -d --name my-app -p 80:80 ${REGISTRY}/${IMAGE_NAME}:${env.BUILD_ID}
                        """
                        
                        // 通过 ssh 远程发送指令
                        // -o StrictHostKeyChecking=no 是为了防止第一次连接时弹出 yes/no 确认
                        bat "ssh -o StrictHostKeyChecking=no root@${ECS_IP} \"${remoteCmd}\""
                    }
                }
            }
        }
    }
}
