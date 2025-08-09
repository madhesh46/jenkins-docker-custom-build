pipeline {
    agent any
    environment {
        IMAGE_NAME = "madhesh23/custom-build"
        IMAGE_TAG = "v1"
        DOCKERHUB_CREDENTIALS = "dockerhub"
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
            }
        }
        stage('Login to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: DOCKERHUB_CREDENTIALS, usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh 'echo $PASSWORD | docker login -u $USERNAME --password-stdin'
                }
            }
        }
        stage('Push to DockerHub') {
            steps {
                sh 'docker push $IMAGE_NAME:$IMAGE_TAG'
            }
        }
        stage('Cleanup') {
            steps {
                sh 'docker rmi $IMAGE_NAME:$IMAGE_TAG || true'
            }
        }
    }
}


