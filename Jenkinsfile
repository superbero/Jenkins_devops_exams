pipeline {
    agent any
    environment {
        DOCKER_HUB_REGISTRY = "docker.io"
        DOCKER_HUB_USERNAME = "superbero"
        DOCKER_HUB_PASSWORD = credentials('docker-hub-credentials').password
    }
    stages {
        stage("pre-build") {
            steps {
                echo "login to docker hub"
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
