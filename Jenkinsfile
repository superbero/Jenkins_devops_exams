pipeline {
    agent any
    environment {
        DOCKER_HUB_REGISTRY = "docker.io"
        DOCKER_HUB_USERNAME = credentials('docker-credentials').username
        DOCKER_HUB_PASSWORD = credentials('docker-credentials').password
    }
    stages {
        stage("pre-build") {
            steps {
                script {
                    sh "echo 'login to docker hub'"
                }
                
            }
        }
        stage("build") {
            steps {
                echo "building"
            }
        }
        stage("deploy") {
            steps {
                echo "deploy"
            }
        }
    }
}
