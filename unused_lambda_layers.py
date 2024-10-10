import os

import boto3
os.environ['AWS_PROFILE'] = "detalytics"
#os.environ['AWS_DEFAULT_REGION'] = "ap-southeast-1"
os.environ['AWS_DEFAULT_REGION'] = "eu-west-3"
# Initialize boto3 clients for Lambda
lambda_client = boto3.client('lambda')


def list_all_lambda_functions():
    """List all Lambda functions in the account"""
    functions = []
    paginator = lambda_client.get_paginator('list_functions')
    for page in paginator.paginate():
        functions.extend(page['Functions'])
    return functions


def list_all_layers():
    """List all Lambda layers"""
    layers = []
    paginator = lambda_client.get_paginator('list_layers')
    for page in paginator.paginate():
        layers.extend(page['Layers'])
    return layers


def get_layer_arns_from_functions(functions):
    """Extract layer ARNs used by all Lambda functions"""
    used_layer_arns = set()
    for function in functions:
        function_name = function['FunctionName']
        try:
            response = lambda_client.get_function_configuration(FunctionName=function_name)
            layers = response.get('Layers', [])
            for layer in layers:
                used_layer_arns.add(layer['Arn'])
        except Exception as e:
            print(f"Error fetching configuration for function {function_name}: {e}")
    return used_layer_arns


def delete_unused_layers(all_layers, used_layer_arns):
    """Delete layers that are not used by any Lambda functions"""
    for layer in all_layers:
        layer_arn = layer['LayerArn']
        layer_name = layer['LayerName']

        # Check if the layer is unused
        if layer_arn not in used_layer_arns:
            try:
                print(f"Deleting unused layer: {layer_name} {layer['LatestMatchingVersion']['Version']}")
                lambda_client.delete_layer_version(LayerName=layer_name,
                                                   VersionNumber=layer['LatestMatchingVersion']['Version'])
            except Exception as e:
                print(f"Error deleting layer {layer_name}: {e}")


if __name__ == "__main__":
    # Step 1: List all Lambda functions
    lambda_functions = list_all_lambda_functions()

    # Step 2: Get all layers attached to Lambda functions
    used_layers = get_layer_arns_from_functions(lambda_functions)

    # Step 3: List all Lambda layers in the account
    all_layers = list_all_layers()

    # Step 4: Delete unused Lambda layers
    delete_unused_layers(all_layers, used_layers)