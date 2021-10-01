import json, requests

def getZenhubPipelines(pRepoId, pToken):
  query_url = f"https://zenhub.ibm.com/p1/repositories/{pRepoId}/board?access_token={pToken}"

  resp = requests.get(query_url)
  data = resp.content
  pipelines = json.loads(data)

  #print(pipelines)
  for pipeline in pipelines['pipelines']:
    print(pipeline['name'], pipeline['id']) 


