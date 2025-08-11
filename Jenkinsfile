pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "madhesh23/ownimage"
        DOCKER_TAG = "${BUILD_NUMBER}"
        DOCKERHUB_CREDENTIALS = "dockerhub"  // Your Jenkins credential ID for DockerHub
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[url: 'https://github.com/madhesh46/jenkins-docker-custom-build.git']]
                ])
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
            }
        }

        stage('Trivy Scan') {
            steps {
                // Continue even if vulnerabilities found (change --exit-code if needed)
                sh "trivy image --exit-code 1 --severity CRITICAL ${DOCKER_IMAGE}:${DOCKER_TAG} || true"
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS}", passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    sh "echo $PASS | docker login -u $USER --password-stdin"
                    sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    // Remove old container if exists
                    sh 'docker rm -f ownimage-container || true'

                    // Run container in detached mode, exposing port 9100
                    sh "docker run -d --name ownimage-container -p 9100:80 ${DOCKER_IMAGE}:${DOCKER_TAG} python app.py"
                }
            }
        }

        stage('Container Health Check') {
            steps {
                script {
                    def status = sh(script: "docker inspect -f '{{.State.Running}}' ownimage-container", returnStdout: true).trim()
                    if (status != 'true') {
                        error "Container ownimage-container is not running!"
                    } else {
                        echo "Container is running successfully."
                    }
                }
            }
        }

        stage('Clean Up') {
            steps {
                echo "No cleanup needed or add your cleanup commands here"
            }
        }
    }
}
