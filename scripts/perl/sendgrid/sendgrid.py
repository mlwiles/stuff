#python --version
#sudo easy_install pip
#pip install sendgrid
#echo "export SENDGRID_API_KEY='REDACTED'" > sendgrid.env
#echo "sendgrid.env" >> .gitignore
#source ./sendgrid.env
#vi sendgridtest.py
#python sendgridtest.py


# using SendGrid's Python Library
# https://github.com/sendgrid/sendgrid-python
# https://github.com/sendgrid/sendgrid-python/blob/master/proposals/mail-helper-refactor.md
import sendgrid
import os
from sendgrid.helpers.mail import *

sg = sendgrid.SendGridAPIClient(apikey=os.environ.get('SENDGRID_API_KEY'))
from_email = Email("mwiles@us.ibm.com")
to_email = Email("mwiles@us.ibm.com")
subject = "Sending with SendGrid Module to multiple recipients"
content = Content("text/plain", "Sent from a python script")
mail = Mail(from_email, subject, to_email, content)

mail.personalizations[0].add_to(Email("mike.lee.wiles@gmail.com"))
mail.personalizations[0].add_to(Email("jaylani@us.ibm.com"))
mail.personalizations[0].add_to(Email("namaster@us.ibm.com"))
mail.personalizations[0].add_to(Email("rharmswo@ca.ibm.com"))

response = sg.client.mail.send.post(request_body=mail.get())
print(response.status_code)
print(response.body)
print(response.headers)
