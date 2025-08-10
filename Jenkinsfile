pipeline {
    agent any
    environment {
        IMAGE_NAME = "madhesh23/custom-build"
        IMAGE_TAG = "v1"
    }
    stages {
        stage('Checkout SCM') {
            steps {
                checkout([$class: 'GitSCM', 
                          branches: [[name: '*/main']], 
                          userRemoteConfigs: [[url: 'https://github.com/madhesh46/jenkins-docker-custom-build.git', credentialsId: '93ec6fd9-1e40-41e3-81c4-50baaeddc1c4']]])
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }
        stage('Scan Image with Trivy') {
            steps {
                script {
                    // Run trivy scan but never fail the build
                    sh "trivy image --severity HIGH,CRITICAL ${IMAGE_NAME}:${IMAGE_TAG} || true"
                }
            }
        }
        stage('Push Docker Image') {
            when {
                expression { 
                    // Only push if previous stages succeeded (excluding trivy failure which is ignored)
                    currentBuild.result == null || currentBuild.result == 'SUCCESS' 
                }
            }
            steps {
                script {
                    sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }
    }
    post {
        failure {
            echo 'Pipeline failed. Please check the logs.'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
    }
}

