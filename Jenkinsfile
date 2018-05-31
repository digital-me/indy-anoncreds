#!groovy

// Load Jenkins shared library common to all Indy projects
def libIndy = [
	remote:			'https://github.com/digital-me/indy-jenkins-pipeline-lib.git',
	branch:				'devel_bear',
	credentialsId:	'bot-ci-dgm-rsa',
]

library(
	identifier:		"libIndy@${libIndy.branch}",
	retriever:		modernSCM([
		$class:				'GitSCMSource',
		remote:			libIndy.remote,
		credentialsId:	libIndy.credentialsId
	])
)

// Load Jenkins lazy shared library until we merge its features in the main one
def libLazy = [
	remote:			'https://github.com/digital-me/jenkins-lib-lazy.git',
	branch:				'devel_bear',
	credentialsId:	null,
]

library(
	identifier:		"libLazy@${libLazy.branch}",
	retriever:		modernSCM([
		$class:				'GitSCMSource',
		remote:			libLazy.remote,
		credentialsId:	libLazy.credentialsId
	])
)

// Initialize configuration
lazyConfig(
    name: 'indy-anoncreds',
    inLabels: [ 'centos-7', 'ubuntu-16', ],
    noPoll: '(.+_.+)',									// Don't poll private nor deploy branches
    env: [
        DRYRUN: false,
		BUILD_DIR: 'dist',								// directory where the packages and repos will be build
        REPO_USER: 'root',
		REPO_HOST: 'orion1.boxtel',
		REPO_DIR: '/var/www/html/indy',
		REPO_BRANCH: 'master',
        REPO_CRED: 'bot-ci-dgm',
        VERSION: '1.0.46',
    ],
)

// CI Pipeline - as long as the common library can be loaded
// Validate the code
lazyStage {
    name = 'validate'
    tasks = [
		run: [
			'common.sh',
			'flake.sh',
		],
		in: '*',
		on: 'docker'
	]
}

// Test the code
lazyStage {
    name = 'test'
    tasks = [
        run: [
			'common.sh',
			'pytest.sh',
		],
		in: '*',
		on: 'docker',
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
        run: [
			'common.sh',
			'indy-anoncreds.sh',
			'pbc.sh indy-0.5.14 https://github.com/digital-me/pbc.git',
			'3rd-parties.sh',
		],
        in: '*', on: 'docker',
        post: {
            archiveArtifacts(artifacts: "${env.BUILD_DIR}/**", onlyIfSuccessful: true)
        },
    ]
}

// Publish the packages
lazyStage {
    name = 'publish'
    tasks = [
        pre: {
            sshagent(credentials: [env.REPO_CRED]) {
				// Downloading existing packages and cleaning current metadata
				sh("mkdir -p ${env.BUILD_DIR}/dists/${env.LAZY_LABEL}")
				sh("scp -qpBC -r ${env.REPO_USER}@${env.REPO_HOST}:${env.REPO_DIR}/dists/${env.LAZY_LABEL}/${env.REPO_BRANCH} ${env.BUILD_DIR}/dists/${env.LAZY_LABEL}")
				sh("rm -f ${env.BUILD_DIR}/dists/${env.LAZY_LABEL}/${env.REPO_BRANCH}/*/Packages* ${env.BUILD_DIR}/dists/${env.LAZY_LABEL}/${env.REPO_BRANCH}/repodata/*.gz || true")
				sh("pwd && ls -lAR ${env.BUILD_DIR}")
            }
            unarchive(mapping:["${env.BUILD_DIR}/" : '.'])
        },
        run: [
			'common.sh',
			'repos.sh',
			'install.sh indy-anoncreds',
		],
        in: '*', on: 'docker',
        post: {
            sshagent(credentials: [env.REPO_CRED]) {
				// Purging existing metadata before publishing
				sh("ssh -o BatchMode=yes ${env.REPO_USER}@${env.REPO_HOST} \"cd ${env.REPO_DIR}/dists/${env.LAZY_LABEL}/${env.REPO_BRANCH} && rm -f */Packages* repodata/*.gz || true\"")
				sh("scp -qpBC -r ${env.BUILD_DIR}/dists/${env.LAZY_LABEL}/${env.REPO_BRANCH} ${env.REPO_USER}@${env.REPO_HOST}:${env.REPO_DIR}/dists/${env.LAZY_LABEL}")
            }
        },
    ]
}
