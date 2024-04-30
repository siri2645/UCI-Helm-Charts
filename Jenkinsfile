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
                 git branch: 'main', url: 'https://github.com/siri2645/UCI-Helm-Charts.git'
            }
        }

        stage('Deploy Helm Chart to Cluster') {
            steps {
                        sh 'aws eks update-kubeconfig --name siri-eks-cluster'
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

