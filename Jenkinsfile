pipeline {
    agent any
    environment {
        DOCKER_HUB_REGISTRY = "docker.io"
        // docker = "/usr/local/bin/docker"
        // docker = "/Users/admin/.jenkins/tools/org.jenkinsci.plugins.docker.commons.tools.DockerTool/docker/bin/docker"
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
                        sh '''
                        $docker --version
                        $docker login -u $DOCKER_HUB_USERNAME -p $DOCKER_HUB_PASSWORD
                        '''
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
        stage("push to docker hub") {
            steps {
                sh '''
                $docker push superbero/movie-service:latest
                $docker push superbero/cast-service:latest
                '''
            }
        }
        stage("configuration kubernetes"){
            steps{
                sh '''
                echo 'config kubernetes'
                $kubectl version
                '''
            }
        }
        stage("create namespace"){
            steps{
                script{
                    sh '''
                    namespaces=('dev' 'staging' 'prod')
                    echo 'create namespace dev prod staging'
                    for namespace in "${namespaces[@]}"
                    do
                            if [[ $kubectl get namespace $namespace ]]; then
                                $kubectl delete -f kubernetes/dev/namespaces/${namespace}.yml
                            else
                                $kubectl apply -f kubernetes/dev/namespaces/${namespace}.yml
                            fi
                    done
                    '''
                }
            }   
        }
        stage ("Prepare helm template"){
            steps{
                script {
                    sh '''
                    $helm version
                    '''
                }
            }
        }
        stage("deploy") {
            steps {
                echo "deploy"
            }
        }
    }
}
