properties([
    parameters([
        choice(choices: ['jenkins', 'ingress-nginx', 'sonarqube', 'external-secrets'], name: 'Component')
    ])
])

pipeline {
    agent any
    stages {
        stage('Checkout Helm Chart Repo') {
            steps {
                 git branch: 'main', credentialsId: 'Siri-GitHub', url: 'https://github.com/siri2645/UCI-Helm-Charts.git'
            }
        }

        stage('Deploy Helm Charts to Cluster') {
            steps {
                     // Configure AWS credentials
                       withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'my-aws-credentials-id', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                            sh '/usr/local/bin/aws eks update-kubeconfig --name lucky-eks-cluster'
                       
                        script {
                            if (params.Component == 'jenkins') {
                                sh '''
                                    cd jenkins
                                    sh install-jenkins.sh
                                '''
                            } else if (params.Component == 'ingress-nginx') {
                                sh '''
                                   ls
                                   cd ingress-nginx
                                   ls
                                   sh install-ingress-nginx.sh
                                ''' 
                            } else if (params.Component == 'sonarqube') {
                                sh '''
                                    cd sonarqube
                                    sh sonar-install.sh
                                    '''
                             } else if (params.Component == 'external-secrets') {
                                sh '''
                                   cd External-Secrets
                                   sh secret-manager.sh
                                   '''
                             }
                        }
                    }
                }
            }       
        } 
   }
