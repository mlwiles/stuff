import requests, base64

username = "mwiles@st.dir"
password = "REDACTED"
userpass = username + ':' + password
encoded_u = base64.b64encode(userpass.encode())
#headers = {"Authorization" : "Basic %s" % encoded_u}
print("Authorization: Basic %s" % encoded_u)

#REDACTED

#Enterprise manager APIs
#Failed:
#curl -v -k -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Basic REDACTED" -X POST https://dalhaveecuem01.st.dir:9398/api/sessionMngr/?v=latest
#Primed:
#curl -v -k -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Basic REDACTED" -X POST https://dalhaveecuem01.st.dir:9398/api/sessionMngr/?v=1_4
#Worked previously failed:
#curl -v -k -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Basic REDACTED" -X POST https://dalhaveecuem01.st.dir:9398/api/sessionMngr/?v=latest
