# 🚀 NAT Instance Setup in AWS (Cost Optimization)

## 📌 Overview
This guide explains how to replace an expensive NAT Gateway with a cost-effective EC2-based NAT Instance, along with real debugging steps encountered during setup.

---

## 💰 Why NAT Instance?

### Problem:
- NAT Gateway cost was ~ $120+/month for zonal NAT Gateway
- Very high for low traffic usage

### Solution:
- Replace with EC2 NAT Instance

### Result:
- Cost reduced to ~$5–10/month

## 🧱 Architecture

- Public Subnet:
  - NAT Instance (EC2)
  - Internet Gateway

- Private Subnet:
  - Application EC2
  - RDS

- Route:
 - Private Subnet → NAT Instance → Internet

 ## ⚙️ Step 1: Launch NAT Instance

- AMI: Amazon Linux 2
- Instance Type: t3.micro
- Subnet: Public Subnet
- Auto-assign Public IP: Enabled

---

## 🔐 Step 2: Security Group

### Inbound:
- SSH (22) → Your IP
- All Traffic → VPC CIDR (e.g., 10.0.0.0/16)

### Outbound:
- Allow All

---

## 🔧 Step 3: Disable Source/Destination Check
- EC2 → Actions → Networking → Change Source/Destination Check → Disable

## 🖥️ Step 4: Configure NAT (SSH into instance)

### Enable IP Forwarding
- check command.txt file

## Step 5: Update the Route Table
- 0.0.0.0/0 → NAT Instance (eni or instance-id)

## Testing
- From Private EC2
- curl google.com

-----------------------------------

## 🐞 Issue Faced (Important Debugging)
- Problem:
  - NAT instance had internet access
  - Private EC2 could NOT access internet

Investigation Steps:

1. Verified:
  - Route table ✔️
  - Security group ✔️
  - NAT instance internet ✔️

2. Checked iptables:
  - sudo iptables -t nat -L



## ✅ Final Result

Private EC2 → Internet working
NAT fully functional
Huge cost savings achieved

## 🎯 Conclusion

Switching to NAT Instance significantly reduces AWS costs and works efficiently for low to medium workloads when configured correctly.
