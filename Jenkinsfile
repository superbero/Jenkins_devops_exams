pipeline {
    agent any
    environment {
        DOCKER_HUB_REGISTRY = "docker.io"
        USER_INPUT=''
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
                    // git config --global user.name="Onesime Binko"
                    // git config --global user.email="onesimeking@gmail.com"
                }
                checkout scm
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
        stage('Deploying') {
            environment {
                KUBECONFIG = credentials('kubeconfig')
            }
            steps {
                script {
                    def userInput = input(
                        id: 'userInput', message: 'Select an action:',
                        parameters: [
                            choice(name: 'Action', choices: 'Install\nUpgrade\nSkip', description: 'Select an action')
                        ]
                    )
                    
                    if (userInput == 'Install') {
                        echo 'Create Persistant Storage'
                        sh "$kubectl apply -f kubernetes/volumes/persitentvolume.yml"
                        echo 'User selected Install'
                        def namespaces = ['dev', 'staging', 'prod', 'qa']
                        echo 'create namespace dev prod staging QA'
                        for (namespace in namespaces) {
                            sh "kubectl apply -f kubernetes/namespaces/${namespace}.yml"
                        }

                        echo "Deploying"

                        namespaces.each { namespace ->
                        echo "Deploying ${namespace} node"
                        try {
                            sh "$helm install jenkins-${namespace} jenkins-helm-${namespace}/ --values=jenkins-helm-${namespace}/values.yaml -n ${namespace}"

                        } catch(Exception e){
                            echo "Namespace ${namespace} not found, creating..."
                            currentBuild.result = 'UNSTABLE' // Set build result to UNSTABLE
                            sh "$kubectl get all -n ${namespace}"
                            }
                        }
                    } else if (userInput == 'Upgrade') {
                        echo 'User selected Upgrade'
                        // Add your Helm upgrade command here
                        // sh 'helm upgrade my-release ./path/to/chart'
                        sh '''
                        for namespace in "${namespaces[@]}"
                        do
                            echo "Deploying ${namespace} node"
                            $helm upgrade jenkins-${namespace} jenkins-helm-${namespace}/ --values=jenkins-helm-${namespace}/values.yaml -n ${namespace}
                            $kubectl get all -n ${namespace}
                        done
                        '''
                    } else if (userInput == 'Skip') {
                        echo 'User selected to skip this stage'
                        def scriptPath = "deploy.sh"
                        sh "./${scriptPath}"

                    } else {
                        error 'Invalid selection'
                    }
                }
            }
        }
    }
}
