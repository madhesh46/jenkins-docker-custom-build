pipeline {
    agent any
    environment {
        IMAGE_NAME = "madhesh23/custom-build"
        IMAGE_TAG = "v1"
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
            }
        }
        stage('Scan Image with Trivy') {
            steps {
                sh 'trivy image --exit-code 1 --severity HIGH,CRITICAL $IMAGE_NAME:$IMAGE_TAG'
            }
        }
        stage('Login to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                sh 'docker push $IMAGE_NAME:$IMAGE_TAG'
            }
        }
        stage('Run Docker Container') {
            steps {
                sh 'docker run --rm $IMAGE_NAME:$IMAGE_TAG echo "Container started successfully"'
            }
        }
        stage('Run and Stop Container') {
            steps {
                sh '''
                docker run -d --name mycontainer $IMAGE_NAME:$IMAGE_TAG
                sleep 10
                docker stop mycontainer
                docker rm mycontainer
                '''
            }
        }
    }
    post {
        always {
            sh 'docker logout'
        }
    }
}

