import json, requests
import zenhubcommon

repoId = "REDOID"
token = "REDACTED"

zenhubcommon.getZenhubPipelines(repoId, token)
