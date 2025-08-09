pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    docker.withRegistry('', '') {
                        // Build Docker image with BuildKit enabled and cache mount for pip
                        sh '''
                        DOCKER_BUILDKIT=1 docker build \
                          --progress=plain \
                          --cache-from=type=local,src=/tmp/.buildx-cache \
                          --cache-to=type=local,dest=/tmp/.buildx-cache-new,mode=max \
                          -t madhesh23/custom-build:v1 .
                        # Replace /tmp/.buildx-cache with a persistent volume if needed
                        rm -rf /tmp/.buildx-cache && mv /tmp/.buildx-cache-new /tmp/.buildx-cache
                        '''
                    }
                }
            }
        }
    }
}

