pipeline {
    agent any
    environment {
        DOCKER_HUB_REGISTRY = "docker.io"
        docker = "/usr/local/bin/docker"
        // DOCKER_HUB_USERNAME = credentials('docker-credentials').username
        // DOCKER_HUB_PASSWORD = credentials('docker-credentials').password
    }
    
    stages {
        stage("pre-build") {
            steps {
                script {
                    sh "echo 'login to docker hub'"
                    // sh 'docker --version'
                    withCredentials([usernamePassword(credentialsId: 'docker-credentials', usernameVariable: 'DOCKER_HUB_USERNAME', passwordVariable: 'DOCKER_HUB_PASSWORD')]) {
                        // sh "docker login -u $DOCKER_HUB_USERNAME -p $DOCKER_HUB_PASSWORD $DOCKER_HUB_REGISTRY"
                            sh '$docker --version'
                        }
                    }
                }
                
            }
        stage("build docker images") {
            steps {
                sh '''
                echo "building movie-service image"
                ls
                cd movie-service
                $docker build . -t superbero/movie-service:latest
                echo "building cast-service image"
                cd ..
                cd cast-service
                $docker build . -t superbero/cast-service:latest
                '''
            }
        }
        stage("deploy") {
            steps {
                echo "deploy"
            }
        }
    }
}
