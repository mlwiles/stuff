# import the standard JSON parser
import json
# import the REST library
from restful_lib import Connection

base_url = "https://sdaldir01.vmware-solutions.cloud.ibm.com/api/"

conn = Connection(base_url, username="mwiles@st.dir", password="REDACTED")

# the rest library can't distinguish between a property and a list of properties with one element.
# this function converts a json object into a list with many, one, or no elements
# o is the dictionary containing the list
# key is the key containing the list (if any)
def toList(o, key):
    if isinstance(o,dict):
        elements = o[key]
        if not isinstance(elements,list):
            return [elements]
        else:
            return elements
    else:
        return []

# a function to get api version

# a function to get the uncompleted reviwers for a single review
def uncompletedReviewers(review):
    id = review[u'permaId'][u'id']
    resp = conn.request_get("/api/versions", args={}, headers={'content-type':'application/json', 'accept':'application/json'})
    status = resp[u'headers']['status']
    if status == '200' or status == '304':
        reviewers = toList(json.loads(resp[u'body'])[u'reviewers'],u'reviewer')
        return map(lambda r: r[u'displayName'], reviewers)
    else:
        return []

# get a dictionary containing the response to the GET request
# we specify JSON as the format as that is easy to parse in Python
resp = conn.request_get("/filter/allOpenReviews", args={}, headers={'content-type':'application/json', 'accept':'application/json'})

status = resp[u'headers']['status']
# check that we either got a successful response (200) or a previously retrieved, but still valid response (304)
if status == '200' or status == '304':
    reviews = toList(json.loads(resp[u'body'])[u'reviews'],u'reviewData')
    reviewerLists = map(uncompletedReviewers,reviews)
    reviewers = reduce(lambda a, b: set(a).union(set(b)), reviewerLists, set())
    print 'Incomplete Reviewers: '
    for r in reviewers:
        print '    ',r
else:
    print 'Error status code: ', status