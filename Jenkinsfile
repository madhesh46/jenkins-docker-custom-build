cat <<EOF > Jenkinsfile
pipeline {
    agent any
    environment {
        IMAGE_NAME = "madhesh23/custom-build"
        IMAGE_TAG = "v1"
    }
    stages {
        stage('Checkout Source') {
            steps {
                git branch: 'main', url: 'https://github.com/madhesh46/jenkins-docker-custom-build.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
                    docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }
        stage('Verify Image Locally') {
            steps {
                script {
                    sh "docker run --rm ${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }
    }
    post {
        success {
            echo "Docker image ${IMAGE_NAME}:${IMAGE_TAG} built successfully."
        }
        failure {
            echo "Build failed. Check logs for details."
        }
    }
}
EOF
