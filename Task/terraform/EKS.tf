resource "aws_iam_role" "iam-role" {
 name = "test_eks_iam_role"

 path = "/"

 assume_role_policy = jsonencode(
{
	"Version": "2012-10-17",
	"Statement": [
    
		{
			Action = "sts:AssumeRole",
			Effect = "Allow",
			"Principal": {
              Service = "ec2.amazonaws.com"
            },
			"Action": "sts:AssumeRole"
		}
	]


})
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
 role    = aws_iam_role.iam-role.name
}
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
 role    = aws_iam_role.iam-role.name
}
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
 role    = aws_iam_role.iam-role.name
}



resource "aws_eks_cluster" "eks-cluster" {
 name = "test-eks-cluster"
 role_arn = aws_iam_role.iam-role.arn

 vpc_config {
  subnet_ids = [ "subnet-0e5401dcdf10f3428", "subnet-0d7dc475263cdd10a", "subnet-002f82cf5066c69fd" ]
 }

 depends_on = [
  aws_iam_role.iam-role,
 ]
}

resource "aws_eks_node_group" "worker-node" {
  cluster_name  = aws_eks_cluster.eks-cluster.name
  node_group_name = "workernodes"
  node_role_arn  = aws_iam_role.workernodes.arn
  subnet_ids   = ["subnet-0e5401dcdf10f3428", "subnet-0d7dc475263cdd10a", "subnet-002f82cf5066c69fd"]
  instance_types = ["t2.small"]
 
  scaling_config {
   desired_size = 1
   max_size   = 1
   min_size   = 1
  }
 
  depends_on = [
   aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
   aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
   #aws_iam_role_policy_attachment.AmazonEC2ContainerRegistry,
  ]
 }