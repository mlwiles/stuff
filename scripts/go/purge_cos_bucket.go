package main

import (
    "github.com/IBM/ibm-cos-sdk-go/aws/credentials/ibmiam"
    "github.com/IBM/ibm-cos-sdk-go/aws"
    "github.com/IBM/ibm-cos-sdk-go/aws/session"
    "github.com/IBM/ibm-cos-sdk-go/service/s3"
    "fmt"
)

// Constants for IBM COS values
const (
    apiKey            = "REDACTED"
    serviceInstanceID = "crn:v1:bluemix:public:cloud-object-storage:global:a/REDACTED:REDACTED::" // "crn:v1:bluemix:public:cloud-object-storage:global:a/<CREDENTIAL_ID_AS_GENERATED>:<SERVICE_ID_AS_GENERATED>::"
    authEndpoint      = "https://iam.cloud.ibm.com/identity/token"
    serviceEndpoint   = "s3.us-east.cloud-object-storage.appdomain.cloud" // eg "https://s3.us.cloud-object-storage.appdomain.cloud"
    bucketLocation    = "us-east" // eg "us"
)

func main() {

    // Create config
    conf := aws.NewConfig().
    WithRegion("us-standard").
    WithEndpoint(serviceEndpoint).
    WithCredentials(ibmiam.NewStaticCredentials(aws.NewConfig(), authEndpoint, apiKey, serviceInstanceID)).
    WithS3ForcePathStyle(true)

    // Create client
    sess := session.Must(session.NewSession())
    client := s3.New(sess, conf)

    counter := 0
    loop := 0
    for loop < 1 { //infinite loop :(
        // Bucket Names
        Bucket := "vcd-dalha1-veeam"
        Input := &s3.ListObjectsV2Input{
            Bucket: aws.String(Bucket),
        }
        
        res, _ := client.ListObjectsV2(Input)

        for _, item := range res.Contents {
            input := &s3.DeleteObjectInput{
                    Bucket: aws.String(Bucket),
                    Key:    aws.String(*item.Key),
                } 
            counter = counter + 1
            client.DeleteObject(input)
            fmt.Printf("counter=%d\n", counter)
        }
    }  
}