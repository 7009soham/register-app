pipeline {
    agent {label 'Jenkins-Agent'}
    tools {
        jdk 'Java17'
        maven 'Maven3'
    }
    stages("Stage1 by SOHAM"){
        
        stage("Author soham -- Cleanup Workspace"){
            steps{
                cleanWs()
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
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube-server') {
                sh '''
                mvn clean verify \
                org.sonarsource.scanner.maven:sonar-maven-plugin:3.11.0.3922:sonar \
                -Dsonar.projectKey=register-app \
                -Dsonar.projectName=register-app
                '''
            }
        }
        }

    }
}