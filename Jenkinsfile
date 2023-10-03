pipeline {
    agent any
    environment {
        DOCKER_HUB_REGISTRY = "docker.io"
        docker = "/Users/admin/.jenkins/tools/org.jenkinsci.plugins.docker.commons.tools.DockerTool/"
        // DOCKER_HUB_USERNAME = credentials('docker-credentials').username
        // DOCKER_HUB_PASSWORD = credentials('docker-credentials').password
    }
    tools {
        // Define the Docker tool installation named 'docker' (You may have to configure this in Jenkins)
        dockerTool 'docker'
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
