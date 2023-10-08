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
        stage('User Input') {
            steps {
                script {
                    def userInput = input(
                        id: 'userInput', message: 'Select an action:',
                        parameters: [
                            choice(name: 'Action', choices: 'Install\nUpgrade\nSkip', description: 'Select an action')
                        ]
                    )
                    
                    // if (userInput == 'Install') {
                    //     echo 'User selected Install'
                    //     // Add your Helm install command here
                    //     // sh 'helm install my-release ./path/to/chart'
                    // } else if (userInput == 'Upgrade') {
                    //     echo 'User selected Upgrade'
                    //     // Add your Helm upgrade command here
                    //     // sh 'helm upgrade my-release ./path/to/chart'
                    // } else if (userInput == 'Skip') {
                    //     echo 'User selected to skip this stage'
                    // } else {
                    //     error 'Invalid selection'
                    // }
                    
                    echo "User selected: ${userInput}"
                    env.USER_INPUT = userInput

                }
            }
        }

        stage('Conditional Stage') {
            when {
                expression { env.USER_INPUT == 'Skip' }
            }
            steps {
                echo("user input {$env.USER_INPUT}")
                echo 'This stage will only run if user did not choose to skip'
                // Add your stage steps here
            }
        }

        stage("create namespace"){
            environment {
                kubeconfig = credentials('kubernetes-config')
            }
            when{
                expression { env.USER_INPUT == 'Install' }
                
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
                                $kubectl delete -f kubernetes/namespaces/${namespace}.yml
                                echo 'Recreate from new ... ${namespace}'
                                $kubectl apply -f kubernetes/namespaces/${namespace}.yml
                            else
                                echo 'Create ${namespace} namespace'
                                $kubectl apply -f kubernetes/namespaces/${namespace}.yml >2&1 /dev/null 
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
            when{
                expression { env.USER_INPUT == 'Install' }
            }
            steps{
                script {
                    sh '''
                    set +e
                    rm -rf jenkins-helm-dev/templates/*
                    cp -f values.yaml jenkins-helm-dev/values.yaml
                    cp -rf templates jenkins-helm-dev/

                    rm -f jenkins-helm-prod/templates/*
                    cp -f values.yaml jenkins-helm-prod/values.yaml
                    sed -i '' 's/namespace: dev/namespace: prod/g' jenkins-helm-prod/values.yaml
                    cp -rf templates jenkins-helm-prod/


                    rm -f jenkins-helm-staging/templates/*
                    cp -f values.yaml jenkins-helm-staging/values.yaml
                    sed -i '' 's/namespace: dev/namespace: staging/g' jenkins-helm-staging/values.yaml
                    cp -rf templates jenkins-helm-staging/


                    git add .
                    git commit -m "Helm charts configuration"
                    git push origin master
                    '''
                }
            }
        }
        stage("deploy installation") {
            when{
                expression { env.USER_INPUT == 'Install' }
            }
            steps {
                echo "deploy"
                sh '''
                namespaces=('dev' 'prod' 'staging')
                for for namespace in "${namespaces[@]}"
                do
                echo "Deploying ${namespace} node"
                $helm install jenkins-${namespace} jenkins-helm-${namespace} --values=jenkins-helm-${namespace}/values.yaml -n ${namespace}
                $kubectl get all -n ${namespace}
                done
                '''
            }
        }
    }
}
