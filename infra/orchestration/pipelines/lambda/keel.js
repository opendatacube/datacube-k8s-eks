// Load the SDK for JavaScript
var AWS = require('aws-sdk');
// Set the region 
AWS.config.update({region: 'ap-southeast-2'});

var https = require("https");

exports.handler = async (event) => {
    let responseCode = 200;
    let responseBody = "Successfully forwarded to Pipeline";

    const body = JSON.parse(event.body);

    if (body["type"] !== "release update" ||
        body["level"] !== "success") {
        responseCode = 400;
        responseBody = "Expected successful update";
    } else {
        // Forward to pipelines if successful deployment
        const postBody = JSON.stringify({
            "target": {
                "ref_type": "branch",
                "type": "pipeline_ref_target",
                "ref_name": "master",
                "selector": {
                    "type":"custom",
                    "pattern":"keel-tests"
                }
            }
        });

        const postOptions = {
              hostname: process.env["PIPELINE_HOST"],
              auth: process.env["BITBUCKET_PIPELINE_USERNAME"] + ":" + process.env["BITBUCKET_PIPELINE_APP_PASSWORD"],
              port: 443,
              path: process.env["PIPELINE_PATH"],
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                'Content-Length': postBody.length
              }
        };

        const pipelinePromise = new Promise((res, rej) => {
            const pipelineRequest = https.request(postOptions, (result) => {
                const body = [];
                result.on('data', (chunk) => body.push(chunk));
                result.on('end', () => {
                    console.log(body.join(''));
                    res(body.join(''));
                });
            });
            pipelineRequest.on('error', (error) => {
                console.log("Pipeline POST error " + error);
                rej(error);
            });
            pipelineRequest.write(postBody);
            pipelineRequest.end();
        });

        try {
            console.log("Pipeline request sent");
            console.log(postOptions);
            await pipelinePromise;
        } catch(e) {
            console.log("Error sending POST");
            responseCode = 500;
        }
    }

    const response = {
        statusCode: responseCode,
        body: JSON.stringify(responseBody)
    };
    return response;
};
