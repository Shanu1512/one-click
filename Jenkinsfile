pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        PATH = "/var/lib/jenkins/ansible-venv/bin:${env.PATH}"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Shanu1512/one-click.git'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir('terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials-id'
                    ]]) {
                        sh '''
                            set -e
                            terraform init
                        '''
                    }
                }
            }
        }

        stage('Check Dynamic Inventory') {
            steps {
                dir('ansible') {
                    withCredentials([
                        sshUserPrivateKey(credentialsId: 'ssh_key', keyFileVariable: 'SSH_KEY'),
                        [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']
                    ]) {
                        sh '''
                            set -e
                            export ANSIBLE_PYTHON_INTERPRETER=/usr/bin/python3
                            ansible-inventory -i mysql-infra-setup/inventory/inventory_aws_ec2.yml --list
                        '''
                    }
                }
            }
        }

        stage('Configure MySQL with Ansible') {
            steps {
                dir('ansible') {
                    withCredentials([
                        sshUserPrivateKey(credentialsId: 'ssh_key', keyFileVariable: 'SSH_KEY'),
                        [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']
                    ]) {
                        sh '''
                            set -e
                            ansible-playbook -i mysql-infra-setup/inventory/inventory_aws_ec2.yml \
                                mysql-infra-setup/sql_playbook.yml \
                                -u ubuntu --private-key $SSH_KEY
                        '''
                    }
                }
            }
        }
    }

   post {
        always {
            echo 'Pipeline finished.'
        }
    }
}
