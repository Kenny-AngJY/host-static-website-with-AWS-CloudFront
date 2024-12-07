# import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info(f"The event is: {event}")
    logger.info(f"The context is: {context}")
    request = event['Records'][0]['cf']['request']
    headers = request['headers']

    # Get the viewer's country code from the CloudFront headers
    country = headers.get('cloudfront-viewer-country', [{'value': None}])[0]['value']

    url = headers.get('referer', [{'value': None}])[0]['value']

    # if not url:
    #   logger.info(f"url is: {url}")
    #   return request

    # first_slash = url.find('/')
    # second_slash = url.find('/', first_slash + 1)
    # third_slash = url.find('/', second_slash + 1)

    # if third_slash != -1:
    #     # Return the part of the string after the third "/"
    #     path = url[third_slash + 1:]
    # else:
    #     # If there is no third "/", return an empty string or handle it as needed
    #     path = ""

    if (country == "SG") & ("index.html" in request['uri']):
        request['uri'] = '/en/index.html'

    return request

    # logger.info([{"cloudfront-viewer-country" : country }, {"url": url}, {"path" : path}])

    # Set default redirect URL
    # redirect_url = 'https://www.kennyangjy.com/index.html'

    # # Determine the redirect URL based on the country code
    # # If request is from Germany (DE), show content in English
    # if country == 'DE':
    #     redirect_url = 'https://www.kennyangjy.com/en/index.html'
    #     headers["referer"] = path
    # # else, show content in Germany
    # else:
    #     redirect_url = 'https://www.kennyangjy.com/de/index.html'
    #     headers["referer"] = path

    # Return a redirect response
    response = {
        'status': '302',
        'statusDescription': 'Found',
        'headers': {
            'location': [{
                'key': 'Location',
                'value': 'https://www.google.com'
            }]
        }
    }

    return response
