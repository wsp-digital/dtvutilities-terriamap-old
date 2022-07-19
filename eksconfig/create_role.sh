aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy-dtvutilities-test --policy-document file://iam_policy.json

eksctl utils associate-iam-oidc-provider --region=ap-southeast-2 --cluster=dtvutilities-test --approve

eksctl create iamserviceaccount \
  --cluster=dtvutilities-test \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name "AmazonEKSLoadBalancerControllerRole-dtvutilities-test" \
  --attach-policy-arn=arn:aws:iam::940728446396:policy/AWSLoadBalancerControllerIAMPolicy-dtvutilities-test \
  --approve
