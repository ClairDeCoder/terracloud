# terracloud
Terraforming AWS

This file contains all code to (nearly) completely deploy an S3 website behind a Cloudfront distribution. Before getting started here, you will need to purchase a domain name. This Terraform file assumes you have a domain name that is hosted within Route 53. If you do not, comment out the Route 53 section.

Your bucket name must match your domain name!

The ACM certificate is already commented out, and Cloudfront is currently set to use a default certificate. If you would like your own, uncomment the ACM cert section, and uncomment line 387, while commenting out line 388. Requesting an ACM cert will take some time, which will cause your Terraform deployment to take some time.

Variables:
Line 24: Create your bucket name
Line 41: "./webfiles/" refers to a directory created within Terraform's working directory, you must create this directory yourself and add your website content within here. "webfiles" dir can have any name, it does not matter.
Line 279: Name your CF Origina Access Control
Line 370: Add/Remove countries for whitelisting
