pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "madhesh23/ownimage"
        DOCKER_TAG = "${BUILD_NUMBER}"
        DOCKERHUB_CREDENTIALS = "dockerhub"
    }

    stages {
        stage('Day 1: Run Build inside Docker Container') {
            steps {
                script {
                    docker.image('python:3.12-slim').inside {
                        sh 'python --version'
                        sh 'echo "Running inside Docker container for Day 1 task"'
                        sh 'ls -l'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
            }
        }

        stage('Trivy Scan') {
            steps {
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
                    sh 'docker rm -f ownimage-container || true'
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
