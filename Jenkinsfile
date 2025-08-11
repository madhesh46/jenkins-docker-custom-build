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
                git 'https://github.com/madhesh46/jenkins-docker-custom-build.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    """
                }
            }
        }

        stage('Login to DockerHub') {
            steps {
                script {
                    sh """
                    echo "${DOCKERHUB_CREDENTIALS_PSW}" | docker login -u "${DOCKERHUB_CREDENTIALS_USR}" --password-stdin
                    """
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    sh """
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    sh """
                    docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true
                    docker logout
                    """
                }
            }
        }
    }
}
