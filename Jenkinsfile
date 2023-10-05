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
        stage('Checkout') {
            steps {
                // Check out the Git repository
                script {
                    git branch: 'master', url: 'https://github.com/superbero/Jenkins_devops_exams.git'
                }
            }
        }
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
            environment {
                kubeconfig = credentials('kubernetes-config')
            }
            steps{
                script{
                    sh '''
                    set +e
                    namespaces=('dev' 'staging' 'prod')
                    echo 'create namespace dev prod staging'
                    for namespace in "${namespaces[@]}"
                    do
                        $kubectl get namespace $namespace
                            if [[ $? -eq 0 ]]; then
                                echo 'Deleting the ${namespace} namespace if exist'
                                $kubectl delete -f kubernetes/dev/namespaces/${namespace}.yml
                                echo 'Recreate from new ... ${namespace}'
                                $kubectl apply -f kubernetes/dev/namespaces/${namespace}.yml
                            else
                                echo 'Create ${namespace} namespace'
                                $kubectl apply -f kubernetes/dev/namespaces/${namespace}.yml >2&1 /dev/null 
                            fi
                    done

                    for namespace in "${namespaces[@]}"
                    do
                        $kubectl get all -n ${namespace}
                    done
                    '''
                }
            }   
        }
        stage ("Helm Charts Configuration"){
            steps{
                script {
                    sh '''
                    rm -f jenkins-helm-dev/templates/*
                    cp -f values.yaml jenkins-helm-dev/values.yaml

                    rm -f jenkins-helm-prod/templates/*
                    cp -f values.yaml jenkins-helm-prod/values.yaml

                    rm -f jenkins-helm-staging/templates/*
                    cp -f values.yaml jenkins-helm-staging/values.yaml

                    git add .
                    git commit -m "Helm charts configuration"
                    git push origin master
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
