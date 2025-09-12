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

        stage('Terraform Init & Validate') {
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
                            echo "🔹 Terraform Init"
                            terraform init
                            echo "🔹 Terraform Validate"
                            terraform validate
                        '''
                    }
                }
            }
        }

        stage('Terraform Plan') {
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
                            echo "🔹 Terraform Plan"
                            terraform plan -out=tfplan
                        '''
                    }
                }
            }
        }

        stage('Approval for Terraform Apply') {
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
                        script {
                            try {
                                sh '''
                                    set -e
                                    echo "🔹 Terraform Apply"
                                    terraform apply -auto-approve tfplan
                                    # Capture bastion public IP
                                    echo "BASTION_IP=$(terraform output -raw bastion_public_ip)" > ../bastion_ip.env
                                '''
                            } catch (err) {
                                echo "⚠️ Terraform Apply aborted or failed, proceeding with Ansible role."
                            }
                        }
                    }
                }
            }
        }

        stage('Configure MySQL with Ansible') {
            steps {
                dir('Terraform-MySQL-Deploy/ansible') {
                    withCredentials([
                        sshUserPrivateKey(credentialsId: 'ssh_key', keyFileVariable: 'SSH_KEY'),
                        [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']
                    ]) {
                        sh '''
                            set -e
                            BASTION_IP=$(cut -d= -f2 ../bastion_ip.env)
                            echo "Waiting for SSH on bastion $BASTION_IP..."
                            until nc -zv $BASTION_IP 22 >/dev/null 2>&1; do
                                echo "SSH not ready, waiting 30s..."
                                sleep 30
                            done
                            echo "SSH ready, running Ansible..."

                            export ANSIBLE_HOST_KEY_CHECKING=False
                            export ANSIBLE_SSH_COMMON_ARGS="-o ProxyCommand='ssh -i $SSH_KEY -W %h:%p ubuntu@$BASTION_IP' -o StrictHostKeyChecking=no"

                            ansible-playbook -i mysql-infra-setup/inventory/inventory_aws_ec2.yml \
                                             mysql-infra-setup/sql_playbook.yml \
                                             --extra-vars "bastion_ip=${BASTION_IP}" \
                                             -u ubuntu \
                                             --private-key $SSH_KEY
                        '''
                    }
                }
            }
        }

        stage('Approval for Final Destroy') {
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    input message: '⚠️ Approve Final Terraform Destroy?'
                }
            }
        }

        stage('Terraform Destroy (Final Cleanup)') {
            steps {
                dir('Terraform-MySQL-Deploy/terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials-id',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh '''
                            set -e
                            echo "🔹 Terraform Destroy"
                            terraform destroy -auto-approve || echo "Nothing to destroy"
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
