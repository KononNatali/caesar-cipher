pipeline {
    agent any
    stages {
        stage ('Test') {
            steps {
                sh './gradlew test'
            }
        }
        //Build and package the project
        stage ('Build') {
            steps {
                sh './gradlew build'
            }
        }
        //Outputs the result of the final build
        stage ('Deploy/Show Output'){
            steps {
                echo 'Deploying/Outputing .....'
                sh 'java -jar build/libs/caesar-cipher.jar'
            }  
        }
        //Releasing the build version of the project into repo 
        stage ('Release') {
            steps {
                withCredentials([string(credentialsId: 'github_token', variable: 'GITHUB_TOKEN')])
                {

                script {
                    //Retrieveing the latest git version tag and assiging it to the variable TAG
                    TAG = sh (
                    script: 'git describe --tags | awk -F - \'{print $1}\'',
                    returnStdout: true).trim()
                    echo "Tag value: ${TAG}"
                    RELEASE = sh (script: """
                    curl -X POST \
                        -H "Authorization: token ${GITHUB_TOKEN}" \
                        -d '{"tag_name": "${TAG}","target_commitish": "main","name": "Release Initial","body": "First release","draft": false,"prerelease": false}' "https://api.github.com/repos/KononNatali/caesar-cipher/releases"|jq -r .id
                        """,
                    returnStdout: true).trim()
                    echo "Release value: ${RELEASE}"
                    // Pushing the build file into the latest release
                    // Uses uploads api of github
                    sh (script: """
                    curl -s -X POST \
                            -H "Authorization: token ${GITHUB_TOKEN}" \
                            --header "Content-Type: application/octet-stream" \
                            --data-binary @"build/libs/caesar-cipher.jar" https://uploads.github.com/repos/KononNatali/caesar-cipher/releases/${RELEASE}/assets?name=caesar-cipher.jar
                        """,
                    returnStdout: false)
                }

                }
            }
        }

    }
    //Post build activity of Jenkins to archive the artifacts
    post {
        always {
            archiveArtifacts artifacts: 'build/libs/caesar-cipher.jar', onlyIfSuccessful: true
        }
    }
    
   }