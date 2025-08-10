pipeline {
    agent any
    environment {
        IMAGE_NAME = "madhesh23/custom-build"
        IMAGE_TAG = "v1"
        TRIVY_SEVERITY = "HIGH,CRITICAL"
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
                    // Run Trivy scan; save results; allow build to continue
                    sh "trivy image --severity ${TRIVY_SEVERITY} ${IMAGE_NAME}:${IMAGE_TAG} || true"
                }
            }
        }

        stage('Push Docker Image') {
            when {
                expression {
                    // Only push if branch is main
                    env.BRANCH_NAME == "main" || env.GIT_BRANCH == "origin/main"
                }
            }
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                        sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Run Container (Post-Deployment)') {
            when {
                expression {
                    // Only run container if image was built and pushed
                    return sh(script: "docker images -q ${IMAGE_NAME}:${IMAGE_TAG}", returnStdout: true).trim() != ''
                }
            }
            steps {
                script {
                    // Stop & remove any existing container with same name
                    sh "docker rm -f myapp_v1 || true"
                    sh "docker run -d --name myapp_v1 --restart unless-stopped -p 9100:80 ${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    // Remove dangling images and stopped containers
                    sh "docker container prune -f"
                    sh "docker image prune -af"
                }
            }
        }
    }
    post {
        failure {
            echo 'Pipeline failed. Please check the logs.'
        }
        success {
            echo 'Pipeline completed successfully with Docker build, scan, push, deployment, and cleanup!'
        }
    }
}
