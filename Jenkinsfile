pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
        IMAGE_NAME = "madhesh23/ownimage"
        IMAGE_TAG = "v1"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/madhesh46/jenkins-docker-custom-build.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                script {
                    sh '''
                    trivy image --exit-code 0 --severity HIGH,CRITICAL ${IMAGE_NAME}:${IMAGE_TAG}
                    trivy image --exit-code 1 --severity CRITICAL ${IMAGE_NAME}:${IMAGE_TAG} || true
                    '''
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    sh "echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin"
                    sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    sh '''
                    docker stop ownimage_container || true
                    docker rm ownimage_container || true
                    docker run -d --name ownimage_container --restart unless-stopped -p 9100:80 ${IMAGE_NAME}:${IMAGE_TAG}
                    '''
                }
            }
        }

        stage('Clean Up Unused Images/Containers') {
            steps {
                script {
                    sh '''
                    docker system prune -af || true
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished. Checked out main branch, built & pushed ${IMAGE_NAME}:${IMAGE_TAG}, deployed and cleaned up."
        }
    }
}
