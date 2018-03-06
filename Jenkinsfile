#!groovy

// Load Jenkins shared library common to all projects
def libCmn = [
	remote:		'https://code.in.digital-me.nl/git/DEVops/JenkinsLibLazy.git',
	branch:		'priv_devel',
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
def config = initConfig('indy-anoncreds')

// CI Pipeline - as long as the common library can be loaded

// Validate the code
stageDockerPar(
	'validate',
	config,
)

// Test the code
stageDockerPar(
	'test',
	config,
	'--network host',
)

// Package the code
stageDockerPar(
	'package',
	config,
	'',
	[
		'build-indy-anoncreds.sh',
		'build-3rd-parties.sh',
	]
)
