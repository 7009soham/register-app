pipeline {
    agent {label 'Jenkins-Agent'}
    tools {
        jdk 'Java17'
        maven 'Maven3'
    }
    stages{
        
        stage("Author soham -- Cleanup Workspace"){
            steps{
                cleanWS()
            }
        }
        stage("Checkout from SCM"){
            steps {
                git branch: 'main', credentialsId: 'github', url:'https://github.com/7009soham/register-app'
            }
        }
        stage("Build Application"){
            steps {
                sh "mvn clean package"
            }

       }
       stage("Test Application"){
           steps {
                 sh "mvn test"
           }
       }
    }
}