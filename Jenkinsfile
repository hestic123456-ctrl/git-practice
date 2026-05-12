pipeline {
    agent any
    
    environment {
        // 换成你自己的阿里云 ACR 地址
        REGISTRY = "crpi-w63lzfggxh0bmatq.cn-beijing.personal.cr.aliyuncs.com/hestic/hestic"
        IMAGE_NAME = "hestic/hestic"
        // 凭据 ID，一会儿要在 Jenkins 界面创建
        ACR_CREDS_ID = "aliyun-acr-creds"
        GIT_CREDS_ID = "github-token"
    }

    stages {
        stage('1. 拉取代码') {
            steps {
                git credentialsId: "${GIT_CREDS_ID}", url: 'https://github.com/hestic123456-ctrl/git-practice.git'
            }
        }

        stage('2. 构建镜像') {
            steps {
                // Windows 下建议用 bat
                bat "docker build -t ${REGISTRY}/${IMAGE_NAME}:%BUILD_ID% ."
            }
        }
        stage('推送到阿里云') {
            steps {
                script {
                     // 1. 这里填你在 Jenkins 界面起的 ID
                     withCredentials([usernamePassword(credentialsId: 'aliyun-acr-creds', passwordVariable: 'ACR_PW', usernameVariable: 'ACR_USR')]) {
                
                     // 2. 这里的 ACR_USR 和 ACR_PW 是临时变量名，随便起，只要跟下面一致就行
                     // 3. Jenkins 会自动把你在界面填的 hestic 和 密码 塞进这两个变量里
                     bat "docker login --username=%ACR_USR% --password=%ACR_PW% ${REGISTRY}"
                
                     // 4. 执行推送
                     bat "docker push ${REGISTRY}/${IMAGE_NAME}:%BUILD_ID%"
                   }
               }
            }
        }
    }
}
