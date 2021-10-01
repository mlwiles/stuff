import githubcommon

owner = "OWNER"
repoName = "REPO"
token = "REDACTED"

githubcommon.getGitOpenIssues(owner, repoName, token)
