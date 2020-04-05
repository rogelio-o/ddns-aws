import { APIGatewayEvent } from "aws-lambda";
import AWS, { Route53 } from "aws-sdk";

if (!process.env.HOSTED_ZONE_ID) {
  throw new Error("Env variable HOSTED_ZONE_ID is required.");
}

if (!process.env.RECORD_NAME) {
  throw new Error("Env variable RECORD_NAME is required.");
}

const route53: Route53 = new AWS.Route53();

const updateRecordSet = (
  params: Route53.Types.ChangeResourceRecordSetsRequest
): Promise<Route53.Types.ChangeResourceRecordSetsResponse> => {
  return new Promise((resolve, reject) => {
    route53.changeResourceRecordSets(params, (err, data) => {
      if (err) {
        reject(err);
      } else {
        resolve(data);
      }
    });
  });
};

const checkAuthorization = (authorizationHeader?: string): boolean => {
  if (!authorizationHeader) {
    return false;
  }

  var encodedCreds = authorizationHeader.split(" ")[1];
  var plainCreds = new Buffer(encodedCreds, "base64").toString().split(":");
  var username = plainCreds[0];
  var password = plainCreds[1];

  return (
    process.env.AUTH_USERNAME === username &&
    process.env.AUTH_PASSWORD === password
  );
};

const set = async (event: APIGatewayEvent) => {
  const authorizationHeader = event.headers.Authorization;

  if (!checkAuthorization(authorizationHeader)) {
    return {
      statusCode: 403,
    };
  }

  const ip = event.requestContext.identity.sourceIp;
  try {
    await updateRecordSet({
      HostedZoneId: process.env.HOSTED_ZONE_ID || "",
      ChangeBatch: {
        Changes: [
          {
            Action: "UPSERT",
            ResourceRecordSet: {
              Name: process.env.RECORD_NAME || "",
              Type: "A",
              TTL: 300,
              ResourceRecords: [
                {
                  Value: ip,
                },
              ],
            },
          },
        ],
      },
    });

    return {
      statusCode: 200,
      body: JSON.stringify({
        return_message: ip,
        return_status: "success",
      }),
    };
  } catch (e) {
    return {
      statusCode: 500,
      body: JSON.stringify({
        return_message: e.message,
        return_status: "error",
      }),
    };
  }
};

export const handle = async (event: APIGatewayEvent) => {
  if (
    event.httpMethod === "POST" &&
    (event.path === "" || event.path === "/")
  ) {
    return set(event);
  } else {
    return {
      statusCode: 404,
    };
  }
};
