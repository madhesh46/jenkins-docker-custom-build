pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "madhesh23/ownimage"
        DOCKER_CREDENTIALS = "dockerhub"
    }

    stages {
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE:$BUILD_NUMBER .'
            }
        }

        stage('Trivy Scan') {
            steps {
                sh '''
                    trivy image --exit-code 0 --severity HIGH,CRITICAL $DOCKER_IMAGE:$BUILD_NUMBER
                    trivy image --exit-code 1 --severity CRITICAL $DOCKER_IMAGE:$BUILD_NUMBER || true
                '''
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: "$DOCKER_CREDENTIALS", usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh '''
                        echo "$PASS" | docker login -u "$USER" --password-stdin
                        docker push $DOCKER_IMAGE:$BUILD_NUMBER
                    '''
                }
            }
        }

        stage('Deploy Container') {
            steps {
                sh '''
                    # Remove any existing container
                    docker rm -f ownimage-container || true

                    # Run container with python app.py to keep it alive
                    docker run -d --name ownimage-container -p 9100:80 $DOCKER_IMAGE:$BUILD_NUMBER python app.py
                '''
            }
        }

        stage('Container Health Check') {
            steps {
                script {
                    def status = sh(script: 'docker inspect -f {{.State.Running}} ownimage-container', returnStdout: true).trim()
                    if (status != 'true') {
                        error "Container ownimage-container is not running!"
                    }
                }
            }
        }

        stage('Clean Up') {
            steps {
                sh '''
                    docker container prune -f
                    docker rmi $DOCKER_IMAGE:$BUILD_NUMBER || true
                '''
            }
        }
    }
}
