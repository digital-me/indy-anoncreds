#!groovy

// Load Jenkins shared libraries common to all projects
def libCmn = [
	remote:		'https://github.com/digital-me/jenkins-lib-lazy.git',
	branch:		'master',
	credentialsId:	null,
]

library(
	identifier: "libCmn@${libCmn.branch}",
	retriever: modernSCM([
		$class: 'GitSCMSource',
		remote: libCmn.remote,
		credentialsId: libCmn.credentialsId
	])
)

// Define the directory where the package will be build
def buildDir = 'dist'

// Initialize configuration
lazyConfig(
    name: 'indy-anoncreds',
    inLabels: [ 'centos-7', 'ubuntu-16', ],
    noPoll: '(.+_.+)',   // Don't poll private nor deploy branches
    env: [ DRYRUN: false, REPO_DEST: 'orion.boxtel:/var/mrepo/indy', ],
)

// CI Pipeline - as long as the common library can be loaded
// Validate the code
lazyStage {
    name = 'validate'
    tasks = [ run: 'inside.sh', in: '*', on: 'docker' ]
}

// Test the code
lazyStage {
    name = 'test'
    tasks = [
        run: 'inside.sh', in: '*', on: 'docker',
        args: '--network host',
        post: {
            archiveArtifacts(artifacts: 'test-results/*.txt', allowEmptyArchive: true)
            junit(testResults: 'test-results/*.xml', allowEmptyResults: true)
	},
    ]
}

// Package the code
lazyStage {
    name = 'package'
    tasks = [
        run: [ 'build-indy-anoncreds.sh', 'build-3rd-parties.sh', ],
        in: '*', on: 'docker',
        post: {
            archiveArtifacts(artifacts: "${buildDir}/**", onlyIfSuccessful: true)
        },
    ]
}

// Publish the packages
lazyStage {
    name = 'publish'
    tasks = [
        pre: {
            unarchive(mapping:["${buildDir}/" : '.'])
        },
        run: [ 'repos.sh', ],
        in: [ 'centos-7', ], on: 'docker',
        post: {
            sh("ls -lA ${buildDir}/*")
            sshagent(credentials: ['bot-ci-dgm']) {
                sh("scp -r ${buildDir} root@orion1.boxtel:/var/tmp")
            }
        },
    ]
}
