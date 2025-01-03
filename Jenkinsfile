pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials'
        DOCKER_REGISTRY = 'localhost:5000'
        IMAGE_NAME = "francescogalanti/flask-app-example"
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Set Docker Image Tag') {
            steps {
                script {
                    def branch = sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()
                    def sha = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    def tag = 'latest'

                    if (branch == 'main') {
                        tag = 'latest'
                    } else if (branch == 'develop') {
                        tag = "develop-${sha}"
                    } else if (env.GIT_TAG) {
                        tag = env.GIT_TAG
                    }
                    env.IMAGE_TAG = tag
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    try {
                        docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                    } catch (Exception e) {
                        error "Docker build failed: ${e.message}"
                    }
                }
            }
        }
        stage('Docker Push') {
            steps {
                script {
                    if (env.DOCKERHUB_CREDENTIALS) {
                        docker.withRegistry('https://index.docker.io/v1/', "${DOCKERHUB_CREDENTIALS}") {
                            def image = docker.image("${IMAGE_NAME}:${IMAGE_TAG}")
                            try {
                                image.push()
                            } catch (Exception e) {
                                error "Docker push failed: ${e.message}"
                            }
                        }
                    } 
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
