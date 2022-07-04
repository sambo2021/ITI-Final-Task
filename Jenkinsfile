// pipeline {


//     agent {
//         kubernetes {
//             yamlFile './CI-CD/builder.yaml'
//         }
//     }
//     stages {
        
//         stage('Kaniko Build & Push Image'){
//             steps{
//                 container('kaniko'){
//                     script{
//                         sh '''
//                         /kaniko/executor --dockerfile `pwd`/CI-CD/dockerfile \
//                                         --context `pwd`/CI-CD \
//                                         --destination=docker-private-repo/myweb:${BUILD_NUMBER}
//                         '''
//                     }
//                 }
//             }
//         }

//         stage('Deploy App to Kubernetes') {
//             steps{
//                 container('kubectl'){
//                     withCredentials([file(credentialsId: 'mykubeconfig', variable: 'KUBECONFIG')]){
//                         sh 'kubectl apply -f CI-CD/nginx.yml '
//                     }
//                 }
//             }
//         }
        
        
//     }

// }

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



pipeline {
    
    agent { kubernetes }
    
    environment {
        imageName = "myapp"
        registryCredentials = "nexus"
        registry = "ec2-34-221-113-21.us-west-2.compute.amazonaws.com/nexus"
        dockerImage = ''
    }
    
    stages {
      
    
    // Building Docker images
    stage('Building image') {
      steps{
        script {
          dockerImage = docker.build("myapp","-f ./CI-CD/dockerfile")
        }
      }
    }

    // Uploading Docker images into Nexus Registry
    stage('Uploading to Nexus') {
     steps{  
         script {
             docker.withRegistry( 'http://'+registry, registryCredentials ) {
             dockerImage.push('latest')
          }
        }
      }
    }
    
 
      
   
    }
}