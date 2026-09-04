pipeline {
    agent any

    tools {
        maven 'Maven' 
    }

    environment {
        DB_USER = 'arun'
        DB_NAME = 'ecommjava'
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Pull source tracking configurations directly from the repository hook
                checkout scm
            }
        }

        stage('Database Initialization') {
            steps {
                echo 'Checking and preparing MySQL database environments...'
                sh "mysql -u arun -p 'Popp77038@arun' -e 'CREATE DATABASE IF NOT EXISTS ${DB_NAME};'"
                // Ensures your system pipeline user 'arun' keeps valid schema permissions
                sh " mysql -u arun -p 'Popp77038@arun' -e \"GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost'; FLUSH PRIVILEGES;\""
                
                echo 'Seeding initial database schemas...'
                // If a starting database structure exists in the repo, apply it natively
                script {
                    if (fileExists('basedata.sql')) {
                        sh "mysql -u arun -p 'Popp77038@arun' ${DB_NAME} < basedata.sql"
                    } else {
                        echo 'basedata.sql file not detected, skipping manual sql seed.'
                    }
                }
            }
        }

        stage('Maven Clean & Compile') {
            steps {
                echo 'Cleaning workspace and compiling source classes...'
                sh 'mvn clean compile'
            }
        }

        stage('Execute Unit Tests') {
            steps {
                echo 'Running project test automation suite...'
                // Executes tests using the newly fixed local database parameters
                sh 'mvn test'
            }
            post {
                always {
                    // Automatically parses target/surefire-reports to render visual test UI inside Jenkins
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }

        stage('Package Application') {
            steps {
                echo 'Packaging application artifact into executable format...'
                // Bundles classes into target executable packages, skipping tests to save time
                sh 'mvn package -DskipTests=true'
            }
            post {
                success {
                    // Archives your compiled war or jar file inside the build history dashboard
                    archiveArtifacts artifacts: '**/target/*.war, **/target/*.jar', fingerprint: true
                }
            }
        }
    }

    post {
        success {
            echo '🎉 CI Build Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed during execution. Review the specific stage breakdown logs above.'
        }
    }
}
