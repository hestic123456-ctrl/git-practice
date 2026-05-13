pipeline {
    agent any
    
    environment {
        REGISTRY = "crpi-w63lzfggxh0bmatq.cn-beijing.personal.cr.aliyuncs.com"
        IMAGE_NAME = "hestic/hestic"
        ACR_CREDS_ID = "aliyun-acr-creds"
        GIT_CREDS_ID = "github-token"
        ECS_IP = "39.97.56.212"
        SSH_CREDS_ID = "ecs-ssh-key"
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
        stage('4. 远程部署到 ECS') {
            steps {
                script {
                    withCredentials([
                        sshUserPrivateKey(credentialsId: "${SSH_CREDS_ID}", keyFileVariable: 'SSH_KEY'),
                        usernamePassword(credentialsId: "${ACR_CREDS_ID}", passwordVariable: 'ACR_PW', usernameVariable: 'ACR_USR')
                    ]) {
                        bat """
                            ssh -i %SSH_KEY% -o StrictHostKeyChecking=no root@${ECS_IP} "docker login --username=%ACR_USR% --password=%ACR_PW% ${REGISTRY} && docker stop my-app; docker rm my-app; docker pull ${REGISTRY}/${IMAGE_NAME}:%BUILD_ID% && docker run -d --name my-app -p 80:80 ${REGISTRY}/${IMAGE_NAME}:%BUILD_ID%"
                        """
                    }
                }
            }
        }
    }
}
