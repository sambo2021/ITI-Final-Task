pipeline {


    agent {
        kubernetes {
            yamlFile './CI-CD/builder.yaml'
        }
    }
    stages {
     
        
        stage('Kaniko Build & Push Image'){
            steps{
                container('kaniko'){
                    script{
                        sh '''
                        /kaniko/executor --dockerfile `pwd`/CI-CD/dockerfile \
                                        --context `pwd`/CI-CD \
                                        --destination=ec2-34-221-113-21.us-west-2.compute.amazonaws.com/nexus/repository/docker-private-repo/myweb:${BUILD_NUMBER}
                                        --insecure --skip-tls-verify
                        '''
                    }
                }
            }
        }

        stage('Deploy App to Kubernetes') {
            steps{
                container('kubectl'){
                    withCredentials([file(credentialsId: 'mykubeconfig', variable: 'KUBECONFIG')]){
                        sh 'kubectl apply -f CI-CD/nginx.yml '
                    }
                }
            }
        }
        
        
    }

}

// podTemplate(inheritFrom: 'default')
//         {
//             node('app:jenkins'){
//             stage('List Configmaps') {
//                 withKubeConfig([namespace: "tools"]) {
//                 sh 'kubectl get pods'
//                 sh 'kubectl run nginx --image=nginx'
//                 }
//             }
//             }
//         }