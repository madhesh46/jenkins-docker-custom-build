pipeline {
    agent any

    triggers {
        pollSCM('*/2 * * * *') // Every 2 minutes
    }

    environment {
        DOCKER_IMAGE = "madhesh23/ownimage"
        DOCKER_CREDENTIALS = "dockerhub"
    }

    stages {
        stage('SCM Polling') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE:$BUILD_NUMBER .'
            }
        }

        stage('Run Container') {
            steps {
                sh '''
                    docker rm -f myapp || true
                    docker run -d --name myapp -p 9100:80 $DOCKER_IMAGE:$BUILD_NUMBER
                '''
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

        stage('Clean Up') {
            steps {
                sh '''
                    docker rm -f myapp || true
                    docker rmi $DOCKER_IMAGE:$BUILD_NUMBER || true
                '''
            }
        }
    }
}
