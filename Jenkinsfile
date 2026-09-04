pipeline {
    agent any
   
    tools {
	maven 'Maven'
	}

    stages {
        stage('Checkout') {
            steps {
                Checkout scm
            }
        }
        
        stage('Build') {
            steps {
                // Build the project using Maven
                sh 'mvn clean package'
            }
        }
        
        stage('Test') {
            steps {
                // Run the tests
                sh 'mvn test'
            }
        }
        
        stage('Deploy') {
            steps {
                echo "Deploying application..."
		
		sh 'mkdir Project-deploy'
                sh 'cp *.jar /Project-deploy'
            }
        }
    }
    
    post {
        always {
            // Actions to perform at the end of the pipeline
            // For example, cleaning up workspace, sending notifications, etc.
            cleanWs()
        }
        success {
            // Actions to perform if the pipeline succeeds
            echo 'Pipeline succeeded!'
        }
        failure {
            // Actions to perform if the pipeline fails
            echo 'Pipeline failed!'
        }
    }
}
