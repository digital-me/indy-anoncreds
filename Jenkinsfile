#!groovy

// Load Jenkins shared library common to all projects
def libCmn = [
	remote:		'https://github.com/digital-me/jenkins-lib-lazy.git',
	branch:		'devel',
	credentialsId:	null,
]

// Load mandatory common shared library
echo 'Trying to load common library...'
library(
	identifier: "libCmn@${libCmn.branch}",
	retriever: modernSCM([
		$class: 'GitSCMSource',
		remote: libCmn.remote,
		credentialsId: libCmn.credentialsId
	])
)
echo 'Common shared library loaded'

// Initialize configuration
lazyConfig(
    name: 'indy-anoncreds',
    dists: [ 'centos-7', 'ubuntu-16', ],
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
            archiveArtifacts(artifacts: 'dist/*', onlyIfSuccessful: true)
        },
    ]
}
