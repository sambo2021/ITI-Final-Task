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
                                        --destination=nexus-repo-svc1.tools.svc.cluster.local:8082/myweb:lts \
                                        --insecure \
                                        --skip-tls-verify
                        '''
                    }
                }
            }
        }

        stage('Deploy App to Kubernetes') {
            steps{
                container('kubectl'){
                    withCredentials([file(credentialsId: 'mykubeconfig', variable: 'KUBECONFIG')]){
                        // sh 'kubectl run -it  mysql --env MYSQL_ROOT_PASSWORD="password"  --port=3306  --image=mysql:5.6 -n dev'
                        sh 'kubectl apply -f ./CI-CD/mysql.yaml'
                        sh 'kubectl apply -f ./CI-CD/app.yaml'
                      
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