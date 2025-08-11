pipeline {
    agent any
    environment {
        IMAGE_NAME = "madhesh23/custom-build"
        IMAGE_TAG = "v1"
        TRIVY_SEVERITY = "HIGH,CRITICAL"
    }
    stages {
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
pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub'   // Your Jenkins credentials ID
        IMAGE_NAME = 'madhesh23/ownimage'
        IMAGE_TAG = "v${BUILD_NUMBER}"
    }

    stages {

        stage('Day 1: Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Day 2: Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Day 3: Trivy Vulnerability Scan') {
            steps {
                script {
                    sh """
                    trivy image --severity HIGH,CRITICAL --exit-code 0 \
                    --no-progress ${IMAGE_NAME}:${IMAGE_TAG} | tee trivy_report.txt
                    """
                }
            }
        }

        stage('Day 3: Push to DockerHub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        """
                    }
                }
            }
        }

        stage('Day 4: Run Container Post Deployment') {
            steps {
                script {
                    // Stop old container if exists
                    sh "docker rm -f ownimage_container || true"

                    // Run new container
                    sh "docker run -d --name ownimage_container --restart unless-stopped -p 9100:80 ${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Day 5: Cleanup Unused Docker Resources') {
            steps {
                script {
                    sh '''
                    docker container prune -f
                    docker image prune -af
                    '''
                }
            }
        }
    }
}
