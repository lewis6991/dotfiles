setlocal commentstring=//%s

setlocal errorformat+=
    \%PErrors\ encountered\ validating\ %f:,
    \%EWorkflowScript:\ %l:\ %m\ column\ %c.,%-C%.%#,%Z

" Requires JENKINS_URL and JENKINS_CLI environment variables
let &makeprg='java -jar $JENKINS_CLI declarative-linter < %'
