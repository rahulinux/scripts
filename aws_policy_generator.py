#!/usr/bin/python

# import boto3
import argparse
import json
import os
from pprint import pprint

def parse_arguments():
  parser = argparse.ArgumentParser()
  parser.add_argument("-r", "--region", help="region",
                      action="store",
                      default="us-east-1")
  parser.add_argument("-c", "--component", help="component",
                      action="store",
                      default="component")
  parser.add_argument("-s", "--services", help="services",
                      action="store",
                      default="services")
  return parser.parse_args()


def merge_json(input_files,output_file="output.json"):
    # removing old output file
    if os.path.isfile(output_file):
         os.remove(output_file)
    # read json file from current dir
    policy_number = 0
    output = {
               "Version": "2012-10-17",
               "Statement": []
             }
    for file in input_files:
        file = file + ".json"
        if os.path.isfile(file):
            # Read file content
            with open(file,"r") as f:
                file_content = json.load(f)
            for i, policy in enumerate(file_content["Statement"]):
                if "Sid" in policy:
                    policy["Sid"] = "Sid" + str(policy_number)
                if "Resource" in policy:
                    if type(policy["Resource"]) == list:
                        for j,resource in enumerate(policy["Resource"]):
                           if "REGION_HERE" in policy["Resource"][j]:
                              policy["Resource"][j] = policy["Resource"][j].replace("REGION_HERE",args.region)
                           if "COMPONENT_NAME_HERE" in policy["Resource"][j]:
                              policy["Resource"][j] = policy["Resource"][j].replace("COMPONENT_NAME_HERE",args.component)
                    else:
                       if "REGION_HERE" in policy["Resource"]:
                           policy["Resource"] = policy["Resource"].replace("REGION_HERE",args.region)
                       if "COMPONENT_NAME_HERE" in policy["Resource"]:
                           policy["Resource"] = policy["Resource"].replace("COMPONENT_NAME_HERE",args.component)
                output["Statement"].append(policy)
                policy_number += 1
        else:
            print "Policy does not exists"
    print output
    # Write file content
    with open(output_file,"a") as json_file:
      json.dump(output, json_file,indent=4, sort_keys=True)
      print "file has been updated"


if __name__ == '__main__':
  args = parse_arguments()
  my_services = args.services.split(",")
  print args.region
  print args.component
  merge_json(my_services)
