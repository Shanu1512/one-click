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

        stage('Terraform Init & Plan') {
            steps {
                dir('terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials-id',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh '''
                            set -e
                            terraform init -reconfigure
                            terraform plan -out=tfplan
                        '''
                    }
                }
            }
        }

        stage('Approval for Apply') {
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    input message: '✅ Approve Terraform Apply?'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials-id',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh '''
                            set -e
                            # terraform apply -auto-approve tfplan
                            # Export the new bastion public IP
                            export BASTION_IP=$(terraform output -raw bastion_public_ip)
                            echo "BASTION_IP=${BASTION_IP}" > ../bastion_ip.env
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
                [$class: 'AmazonWebServicesCredentialsBinding',
                 credentialsId: 'aws-credentials-id',
                 accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                 secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']
            ]) {
                sh '''
                    #!/bin/bash
                    set -e

                    # Ensure we are using bash explicitly
                    BASTION_ENV="../bastion_ip.env"
                    if [ -f "$BASTION_ENV" ]; then
                        source "$BASTION_ENV"
                    else
                        echo "ERROR: $BASTION_ENV not found!"
                        exit 1
                    fi

                    echo "Using BASTION_IP=${BASTION_IP}"

                    ansible-playbook -i mysql-infra-setup/inventory/inventory_aws_ec2.yml \
                        mysql-infra-setup/sql_playbook.yml \
                        -u ubuntu --private-key "$SSH_KEY" \
                        --extra-vars "bastion_ip=${BASTION_IP}"
                '''
            }
        }
    }
}


        stage('Approval for Destroy') {
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    input message: '⚠️ Approve Terraform Destroy?'
                }
            }
        }

        stage('Terraform Destroy') {
            steps {
                dir('terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials-id',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh '''
                            set -e
                            terraform destroy -auto-approve
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            echo '🚀 Pipeline finished.'
        }
    }
}
