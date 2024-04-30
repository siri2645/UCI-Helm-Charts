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
                        // sh 'curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3'
                        // sh 'sh get-helm-3'
                        // sh 'curl -LO https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl'
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

