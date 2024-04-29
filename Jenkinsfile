properties([
    parameters([
        choice(choices: ['jenkins', 'ingress-nginx'], name: 'Component')

    ])
])
pipeline {
    agent {
        label 'cicd'
    }

    stages {
                   
        stage('Checkout Helm Chart Repo') {
            steps {
                    checkout([$class: 'GitSCM', branches: [[name: 'origin/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'pankaj210179-dev-git-creds', url: 'TBD']]])
                    stash includes: '**/*', name: 'uc-iac-aws-tf-lz-eks'
                }
            }

        stage('Deploy Helm Chart to Cluster') {
            steps { 
                ansiColor('xterm') {
                    withAWS(role:"arn:aws:iam::068132906153:role/EXLDevopsJenkinsCICDNodeCrossAccountRole", useNode: true) {
                        sh 'aws eks update-kubeconfig --name uc2-automation-eks-cluster'
                        // sh 'curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3'
                        // sh 'sh get-helm-3'
                        // sh 'curl -LO https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl'
                        // sh 'chmod +x kubectl'
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

