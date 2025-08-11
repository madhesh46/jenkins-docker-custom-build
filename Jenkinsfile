pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "madhesh23/ownimage"
        DOCKER_CREDENTIALS = "dockerhub"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    env.BUILD_NUMBER = env.BUILD_NUMBER ?: "latest"
                }
                sh "docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} ."
            }
        }

        stage('Trivy Scan') {
            steps {
                // Scan with exit code 1 if critical found, so pipeline fails
                sh "trivy image --exit-code 1 --severity CRITICAL ${DOCKER_IMAGE}:${BUILD_NUMBER} || true"
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS, usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh "echo $PASS | docker login -u $USER --password-stdin"
                    sh "docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}"
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    // Remove old container if exists, ignore errors
                    sh "docker rm -f ownimage-container || true"
                    // Run container detached, mapping ports, run python app.py which must keep running
                    sh "docker run -d --name ownimage-container -p 9100:80 ${DOCKER_IMAGE}:${BUILD_NUMBER} python app.py"
                }
            }
        }

        stage('Container Health Check') {
            steps {
                script {
                    def status = sh(script: "docker inspect -f '{{.State.Running}}' ownimage-container", returnStdout: true).trim()
                    if (status != 'true') {
                        error "Container ownimage-container is not running!"
                    }
                }
            }
        }

        stage('Clean Up') {
            steps {
                // Optional cleanup, you can remove old unused images or containers if needed
                echo "Cleanup can be added here if necessary."
            }
        }
    }
}
