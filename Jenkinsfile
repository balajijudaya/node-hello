env.DOCKER_IMAGE
env.STAGE_DNS

def envDeploy(environment){
    sh 'terraform init -backend-config="' + environment + '-backend.tfvars"'
	sh "terraform plan -var-file=\"" + environment + ".tfvars\"" 
    sh "terraform apply -auto-approve -var-file=\"" + environment + ".tfvars\"" 
    sh "export STAGE_DNS=$(terraform output alb_dns_name)"
}

pipeline {
    agent any
    environment {
        EMAIL_TO = 'testuser@host.com'
    }
    stages {
        stage('Install Node Dependencies') {
            steps {
                sh 'npm install'
            }
        }
        stage('Run Unit Tests') { 
            steps {
                sh 'npm test' 
            }
        }
        stage('Build Node App Docker Image') {
            steps {
                script {
                    DOCKER_IMAGE = docker.build("XXXXXXXXXXXX.dkr.ecr.eu-west-1.amazonaws.com/node-hello-app")
                }
            }
        }
        stage('Push Docker Image To ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                credentialsId: 'jenkins_aws_user']]) {
                    sh 'eval $(aws ecr get-login --no-include-email --region eu-west-1)'
                    script {
                        DOCKER_IMAGE.push()
                    }
                }
            }
        }
        stage('Deploy To Stage environment through terraform') {
            steps {
                println "Deploying to Stage environment"
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                credentialsId: 'jenkins_aws_user']]) {
                    envDeploy('stage')
                }
            }
        }
        stage('Run Regresession Suite on Stage Environment') {
            steps {
                println "Running regression suite against " + env.STAGE_DNS
                sh 'npm run func-test'
            }
        }
        stage('Approval For Prod Deployment') {
            steps {
                script {
                    def userInput = input(id: 'confirm', message: 'Promote To Prod?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Promote to prod', name: 'confirm'] ])
                }
            }
        }
        stage('Deploy To Prod environment through terraform') {
            steps {
                println "Deploying to prod environment"
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                credentialsId: 'jenkins_aws_user']]) {
                    envDeploy('prod')
                }
            }
        }
    }
    post {
        failure {
            emailext body: 'Check console output at $BUILD_URL to view the results. \n\n ${CHANGES} \n\n -------------------------------------------------- \n${BUILD_LOG, maxLines=100, escapeHtml=false}', 
                    to: EMAIL_TO, 
                    subject: 'Build failed in Jenkins: $PROJECT_NAME - #$BUILD_NUMBER'
        }
    }
}