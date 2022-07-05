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
                                        --destination=10.111.188.201:8082/myweb:v${BUILD_NUMBER}
                                        --insecure --skip-tls-verify
                        '''
                    }
                }
            }
        }

        // stage('Deploy App to Kubernetes') {
        //     steps{
        //         container('kubectl'){
        //             withCredentials([file(credentialsId: 'mykubeconfig', variable: 'KUBECONFIG')]){
        //                 sh 'kubectl apply -f CI-CD/nginx.yml '
        //             }
        //         }
        //     }
        // }
        
        
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