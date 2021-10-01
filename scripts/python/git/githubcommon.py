import json, requests

def getGitOpenIssues(pOwner, pRepo, pToken):
  query_url = f"https://api.github.ibm.com/repos/{pOwner}/{pRepo}/issues"
  params = {
      "state": "open",
  }
  headers = {'Authorization': f'token {pToken}'}

  resp = requests.get(query_url, headers=headers, params=params)
  data = resp.content
  issues = json.loads(data)

  #print(issues)
  for issue in issues:
    print(issue['title'], issue['url'])