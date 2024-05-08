properties([
    parameters([
        choice(choices: ['jenkins', 'ingress-nginx'], name: 'Component')
    ])
])

pipeline {
    agent any
    stages {
        stage('Checkout Helm Chart Repo') {
            steps {
                 git branch: 'main', credentialsId: 'GitHub', url: 'https://github.com/siri2645/UCI-Helm-Charts.git'
            }
        }

        stage('Deploy Helm Chart to Cluster') {
            steps {
                     withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-cred', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                            sh 'aws eks update-kubeconfig --name siri-eks-cluster'
                        }
                       
                        script {
                            if (params.Component == 'jenkins') {
                                sh 'cd jenkins'
                                sh 'sh install-jenkins.sh'
                            } else if (params.Component == 'ingress-nginx') {
                                sh 'cd ingress-nginx'
                                sh 'sh install-ingress-nginx.sh'
                            }
                        }
                    }
                }
            }       
        }

