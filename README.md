# ddns-aws

This is a DDNS (Dynamic DNS) tool to update your domain with your router current IP. The project has two components:

- The server, which gets the IP from headers, check if it has changed (based on _last_ip_ query parameter) and set the Route53 domain record pointing to the IP.
- The client, which periodically calls the server with the _last_ip_ query parameter and set it with the response.

## How to use it?

### Server deployment

The server is a AWS lambda function created with serverless framework. To deploy it some env variables should be set and then the deploy command should be run:

```
cd lambda
export HOSTED_ZONE_ID=<YOUR HOSTED ZONE ID>
export RECORD_NAME=<YOUR RECORD NAME: foo.example.com>
serverless deploy --stage pro --env production
```

**WARNING:** AWS user has to be logged-in on the system and the user need the required permissions to deploy with serverless framework.

The result of the deploy command will return a URL and an API key that should be saved to configure the client.

### Client configuration

The client is a bash script. Additional files are provided to configure systemctl service and timer. The client could be configured in something like a Raspberry PI that is always running.

Follow the next steps to configure the client:

- Replace _<API_KEY>_ and _\<URL>_ from _client/ddns-aws-client.service_.
- Move _client/ddns-aws-client.sh_ to _/usr/bin/_.
- Move _client/ddns-aws-client.service_ and _client/ddns-aws-client.timer_ to _/etc/systemd/system/_.
- `sudo systemctl disable ddns-aws-client`
- `sudo systemctl enable ddns-aws-client.timer`

It can be checked that the timer is running with command: `sudo systemctl status ddns-aws-client`.

# Docker

Run client executing the following command:

```
docker run ddns-aws-client:latest -v /tmp/ddns_cache/:/tmp/ddns_cache/ --api-key <API_KEY> --url <URL>
```
