pipeline {
    agent any
    
    environment {
        REGISTRY = "crpi-w63lzfggxh0bmatq.cn-beijing.personal.cr.aliyuncs.com/hestic/hestic"
        IMAGE_NAME = "hestic/hestic"
        ACR_CREDS_ID = "aliyun-acr-creds"
        GIT_CREDS_ID = "github-token"
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
        stage('推送到阿里云') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'aliyun-acr-creds', passwordVariable: 'ACR_PW', usernameVariable: 'ACR_USR')]) {
                        bat "docker login --username=%ACR_USR% --password=%ACR_PW% ${REGISTRY}"
                        bat "docker push ${REGISTRY}/${IMAGE_NAME}:%BUILD_ID%"
                    }
                }
            }
        }
    }
}
