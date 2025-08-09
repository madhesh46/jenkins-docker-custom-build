pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/madhesh46/jenkins-docker-custom-build.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t custom-jenkins-docker-build .
                '''
            }
        }

        stage('Run Docker Container') {
            steps {
                sh '''
                docker run --rm custom-jenkins-docker-build
                '''
            }
        }
    }
}

