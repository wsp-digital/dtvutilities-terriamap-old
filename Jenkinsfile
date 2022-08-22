pipeline {

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['test','uat'], description: 'Environment Name deployment target')
    }

    environment {
        PROJECT                         = 'terria'
        AWS_DEFAULT_REGION              = 'ap-southeast-2'
        VERSION                         = 'latest'
        AWS_ACCOUNT_ID                  = '263056682855'
        ECRREPO                         = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
        IMAGE                           = "${CONTAINER_NAME}:latest"
    }

    agent { label 'large_docker_builder' }

    stages {

        stage('Initialize') {
            steps {
                script {
                    VERSION = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                    CONTAINER_NAME "${env.ENVIRONMENT == "uat" ? "${PROJECT}" : "${PROJECT}-test"}"
                    IMAGE = "$CONTAINER_NAME:${VERSION}"
                    currentBuild.displayName = "#${env.BUILD_ID}-${VERSION}"
                }
            }
        }

        stage('Docker Build and Push') {
            steps {
                script {
                    def customImage = docker.build( "${ECRREPO}/${IMAGE}")
                    sh("aws ecr --region ${AWS_DEFAULT_REGION} get-login-password | docker login --username AWS --password-stdin ${ECRREPO}")
                    customImage.push()
                }
            }
            post {
                always { sh "docker rmi ${ECRREPO}/$IMAGE | true" }
            }
        }

        stage('Deploy') {
            stages {
                stage("AWS") {
                    when { anyOf { branch 'master'; branch 'dev' } }
                    steps {
                        script {
                            step([$class     : 'CopyArtifact',
                                  projectName: 'Devops/devops-iac-templates/master',
                                  filter     : "devops-cloudformation.tar.gz"])

                            sh('tar xf devops-cloudformation.tar.gz')

                            lock(resource: "deploy-${TARGET_ENV}", inversePrecedence: true) {
                                dir("cloudformation") {
                                    sh """
                                        scripts/assume-jenkins-role.sh ${AWS_ACCOUNT_ID}
                                        AWS_PROFILE=${env.JOB_NAME} make --directory=projects/${PROJECT} deploy ENVIRONMENT=${env.ENVIRONMENT} VERSION=${VERSION}
                                    """
                                }
                                milestone()
                            }
                        }
                    }
                }
            }
        }
    }
}
